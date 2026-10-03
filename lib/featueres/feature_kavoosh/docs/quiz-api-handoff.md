# Quiz API — Handoff for the App (Flutter/Dart) Agent

This document describes the user-facing Quiz APIs deployed on the Poortak backend so the app agent can integrate the full Quiz experience: browse categories → list quizzes → attempt setup → answer flow → result.

The app agent is free to decide how to integrate (Dio/http client, repository pattern, state management, etc.) — this doc only defines the contract.

## General conventions

- Base URL is the backend server, e.g. `https://<host>/api/v1`. All routes below are relative to that.
- Auth: `Authorization: Bearer <accessToken>` header (same user token used by other app flows).
  - `Optional`-auth endpoints return `lastAttempt: null` when unauthenticated instead of failing (401).
- Language: send `x-lang: fa` (default) or `en` header — error messages are localized.
- Success responses are wrapped: `{ "ok": true, "data": <payload>, "meta": { "count": <number> } }` where `meta` appears only for paginated endpoints.
- Errors: HTTP 4xx/5xx with `{ "ok": false, "message": <string or string[]> }`. `message` may be an array (validation errors) — join it for display.
- IDs are UUID strings.
- All quiz questions have 2..N answer options and exactly one correct answer.

### Types shorthand

```
QuizSummary {
  id, title, description, order, thumbnailId, publishedAt,
  categoryId,
  category: { id, title },
  questionCount,          // total questions of the quiz
  lastAttempt: LastAttempt | null,
}

LastAttempt {
  attemptId,              // active/completed attempt UUID
  status,                 // 'Completed' | 'Started'
  state,                  // convenience: 'completed' | 'in-progress'
  questionCount,          // questions selected in that attempt
  score,                  // percentage 0..100 ('Completed' attempts; null for 'Started')
  completedAt,            // null for in-progress
  answered, correct, wrong,
}
```

Icon coloring on the quiz list (design decision): green = completed with a passing score (client-defined threshold, e.g. `score >= 70`), orange/red = completed but failed or in-progress, none = `lastAttempt == null`.

## Flow overview

1. `GET /quiz/categories` — list of flat (1-level) quiz categories.
2. `GET /quiz/categories/{categoryId}/quizzes?page&size` — published quizzes of a category, each with the user's `lastAttempt` result.
3. `POST /quiz/{quizId}/start` — body `{ "questionCount": 20 }`; creates (or resumes) an attempt with a **random** subset of questions. Returns the first question.
4. UI: show question + answers one by one, progress bar `answered / total` from `stats`.
5. `POST /quiz/attempt/{attemptId}/answer` — submit an answer; response includes correctness, the correct answer id, and updated stats + no next question (fetch resume state, or call again with the next question from the state endpoint).
6. `GET /quiz/attempt/{attemptId}` — fetch current attempt state anytime (app restart / resume): pending question + stats.
7. `PATCH /quiz/attempt/{attemptId}/finish` — completes the attempt, returns final summary.
8. `GET /quiz/{quizId}/result` — result of the latest attempt of that quiz.

---

## Endpoints

### 1) Quiz categories

`GET /quiz/categories`

`data: Array<{ id, title, description, type: 'CATEGORY', order, thumbnailId: string | null, backgroundImageId: string | null, quizCount }>`

- Flat list only (no nesting); categories with 0 published quizzes are filtered out.
- `thumbnailId`/`backgroundImageId` are File UUIDs (nullable) — resolve images through the existing file/image endpoint used elsewhere in the app.

### 2) Quizzes of a category

`GET /quiz/categories/{categoryId}/quizzes?page=1&size=20(optional: query)`

- Paginated: `meta.count` is the total.
- Ordered by admin-defined `order`.

`data: QuizSummary[]` — each item includes `lastAttempt` (see above):

```json
{
  "ok": true,
  "meta": { "count": 42 },
  "data": [{
    "id": "…", "title": "فعل‌های پرکاربرد", "description": "…",
    "thumbnailId": "…",
    "categoryId": "…", "category": { "id": "…", "title": "گرامر" },
    "questionCount": 120,
    "publishedAt": "2026-09-01T00:00:00.000Z",
    "lastAttempt": {
      "attemptId": "…", "status": "Completed", "state": "completed",
      "questionCount": 20, "score": 85, "completedAt": "…",
      "answered": 20, "correct": 17, "wrong": 3
    }
  }]
}
```

- `lastAttempt` is the **latest attempt** of the current user for that quiz (`null` if never attempted).
- If `state == 'in-progress'`, the app should offer "ادامه آزمون" instead of signing a new attempt; calling `start` again resumes.

### 3) Quiz detail

`GET /quiz/{quizId}`

`data: QuizSummary` (same item shape as above, plus `lastAttempt` when authenticated).

### 4) Start (or resume) an attempt

`POST /quiz/{quizId}/start` — **requires auth**

Body: `{ "questionCount": 20 }` (1 ≤ questionCount ≤ quiz `questionCount`; otherwise 400 `app.quiz.invalidQuestionCount`).

Response:

```json
{
  "ok": true,
  "data": {
    "attempt": {
      "id": "…", "status": "Started", "state": "in-progress",
      "score": null, "completedAt": null
    },
    "question": {
      "id": "…", "title": "…", "description": "…|null",
      "order": 0,
      "answers": [ { "id": "…", "title": "…" } ]   // never exposes isCorrect
    },
    "stats": { "total": 20, "answered": 0 }
  }
}
```

- If an open (`Started`) attempt exists for the same quiz, it is **resumed** instead of creating a new one — the response then reflects its progress, and the returned `question` is the first unanswered one.
- The random question subset is fixed for the attempt's lifetime (deterministic resume).

### 5) Submit an answer

`POST /quiz/attempt/{attemptId}/answer` — requires auth

Body: `{ "questionId": "…", "answerId": "…" }`

Errors (localized):
- 404 `attemptNotFound` (not owner / doesn't exist), `questionNotInAttempt`, `answerNotInQuestion`
- 400 `attemptAlreadyCompleted`

Response (re-submitting the same question only replaces the stored answer and does **not** double count):

```json
{
  "ok": true,
  "data": {
    "correct": true,
    "correctAnswerId": "…",
    "stats": { "answered": 12, "total": 20 }
  }
}
```

- `stats.answered/total` is the progress-bar driver.

### 6) Current attempt state / resume

`GET /quiz/attempt/{attemptId}` — requires auth

Response: same shape as `start` (`attempt` + `question` + `stats`). `question` is `null` when every question is already answered — then call `finish`.
Recommended: call this to restore in-progress quiz UI when the user reopens the app.

### 7) Finish attempt / result

`PATCH /quiz/attempt/{attemptId}/finish` — requires auth

Response (also returned verbatim by `GET /quiz/{quizId}/result` for the quiz's latest attempt):

```json
{
  "ok": true,
  "data": {
    "attemptId": "…",
    "status": "Completed",
    "state": "completed",
    "questionCount": 20,
    "score": 85.0,
    "completedAt": "…",
    "answered": 20,
    "correct": 17,
    "wrong": 3
  }
}
```

- `correct + wrong == answered` (answered may be < questionCount if the user finishes early; unanswered questions count in the score denominator).
- Finishing is idempotent; repeated calls return the stored result.
- `GET /quiz/{quizId}/result` → 404 `app.quiz.attemptNotFound` if user never attempted.

---

## App UX translation (suggested)

- **Category screen**: categories grid (tile/carat based on `quizCount`, thumbnail).
- **Quiz list screen**: quiz cards with result badge from `lastAttempt`; "continue" CTA for `in-progress`; modal on start asks question count (`questionCount`, 1..N).
- **Quiz runner screen**: for each question show `title` (+ optional `description`), answer option buttons; submit via endpoint (5); show instant correct/wrong feedback using `correct`/`correctAnswerId`, then fetch the next question via endpoint (6); progress bar bound to `stats.answered / stats.total`.
- **Result screen**: big correct/wrong/answered recap from endpoint (7); retake by calling start again (each attempt is a separate history record; the list badge always reflects the latest).

## Notes / pitfalls

- The answer list of a running question has no `isCorrect` flag — don't guess; the submit response reveals the correct one.
- Attempts are user-scoped server-side; ownership mismatch yields 404, not 403.
- `stats.total` equals the chosen subset count (not the quiz's full question count).
- No timers in v1; result screen is a summary only (no per-question review).
- Quiz/question lists are localized Persian content from the DB, not translated via i18n.

## Backend state of the world (do this first)

The Prisma migration `20261001153913_quiz_module` is **created but not applied**. Ask the user to run `pnpm --dir backend prisma migrate dev` (or the backend owner to apply it) before testing these endpoints against a real DB.
