# App Handoff Plan — IKnow Voice Files

## 1. Feature summary

Admins can now attach a public, unencrypted audio file to each IKnow conversation and vocabulary. The app must:

1. Read `voiceFileId` and `voiceChecksum` from IKnow API responses.
2. Download audio from the public storage endpoint.
3. Cache it locally and play it.
4. Use checksums to know when a voice changed and needs re-downloading.
5. Handle legacy records where `voiceFileId` is `null`.

The `voice` field on conversations is **not** the audio. It remains the actor type (`male`/`female`).

---

## 2. API contract

All endpoints use the existing base URL, e.g. `https://host/api`, version `v1`:

```text
{API_BASE}/v1/...
```

### Endpoints carrying voice data

| Method | Endpoint | Notes |
|---|---|---|
| GET | `/v1/iknow/courses/:courseId/conversation` | list; includes per-item voice fields and `meta.checksum` |
| GET | `/v1/iknow/courses/:courseId/vocabulary` | list; includes per-item voice fields and `meta.checksum` |
| GET | `/v1/iknow/courses/:courseId/conversation/playback` | JWT; nested `data.iKnowConversation` includes voice fields |
| POST | `/v1/iknow/courses/:courseId/vocabulary/practice` | returns `correctWord` / `wrongWord`, both include voice fields |
| GET | `/v1/iknow/courses/:courseId/vocabulary/:vocabularyId/submit` flow | practice responses also carry voice fields |
| GET | `/v1/storage/public/:voiceFileId` | downloads/redirects to the public audio file; no auth required |

### Response shape

The envelope remains unchanged:

```json
{
"ok": true,
"data": [],
"meta": {
"checksum": "64-char-hex"
}
}
```

Conversation list item:

```json
{
"id": "conversation-uuid",
"text": "...",
"translation": "...",
"voice": "male",
"voiceFileId": "file-uuid-or-null",
"voiceChecksum": "64-char-hex-or-null",
"avatarId": "file-uuid-or-null",
"order": 0,
"courseId": "..."
}
```

Vocabulary list item:

```json
{
"id": "vocabulary-uuid",
"word": "...",
"translation": "...",
"thumbnail": "...",
"voiceFileId": "file-uuid-or-null",
"voiceChecksum": "64-char-hex-or-null",
"order": 0,
"courseId": "..."
}
```

### Field rules

- `voiceFileId` — ID of a public audio file. `null` means no voice attached.
- `voiceChecksum` — opaque 64-char SHA-256 token. Compare it; do not recompute or interpret it.
- `meta.checksum` — aggregate checksum only for voices in that list. It changes when a voice is attached, replaced, or removed; it does **not** change for text/order/translation edits.
- Treat checksums as opaque strings. Never parse them.
- Checksums change on re-upload even if the audio bytes are identical. A redownload is acceptable.

---

## 3. Data model changes in the app

Extend local conversation/vocabulary models:

```text
voiceFileId: String?
voiceChecksum: String?
```

Also store locally, per course or globally:

```text
listVoiceChecksum: String? // last seen meta.checksum per list
voiceCache: Map<fileId, {
localPath: String
checksum: String? // checksum observed when downloaded
contentType: String?
}>
```

Key audio files by `voiceFileId`, not by conversation/vocabulary ID. The same file ID may be reused across records.

---

## 4. Download and cache

### Download URL

```text
GET {API_BASE}/v1/storage/public/{voiceFileId}
```

The endpoint responds with a `302` redirect to the actual object.

App requirements:

- Enable redirect following in the HTTP client.
- Do not construct the storage/S3 URL manually.
- No JWT is required for this endpoint.
- Use a temporary file and atomic rename after successful download.
- Infer the file extension from the response `Content-Type`:
- `audio/mpeg` → `.mp3`
- `audio/mp4` / `audio/aac` → `.m4a` or `.aac`
- `audio/wav` / `audio/x-wav` → `.wav`
- `audio/ogg` → `.ogg`
- fallback → no extension
- Do not cache redirect responses; cache the final audio bytes.
- Support cancellation and retry with backoff.

### Sync algorithm

```text
syncVoiceList(courseId, listType):
res = GET list endpoint
items = res.data
listChecksum = res.meta?.checksum

if listChecksum != null and listChecksum == local.listVoiceChecksum:
update metadata only (text, order, etc.)
return

expectedFileIds = set()

for item in items:
if item.voiceFileId == null:
continue

expectedFileIds.add(item.voiceFileId)

cached = voiceCache[item.voiceFileId]

if cached exists
and cached.checksum == item.voiceChecksum
and file exists on disk:
continue

download(item.voiceFileId):
response = GET /v1/storage/public/{voiceFileId}, follow redirects
on success:
save temp file -> final path
voiceCache[item.voiceFileId] = {
localPath,
checksum: item.voiceChecksum,
contentType
}
on 404/410:
remove cached entry
mark item voice unavailable
on network error:
keep old cache if present; mark stale

delete local voice files not in expectedFileIds

local.listVoiceChecksum = listChecksum
```

Important:

- The list-level checksum is a fast “did any voice change?” check. It is not a metadata/content version.
- If `meta.checksum` is missing (older backend), fall back to comparing each item’s `voiceChecksum`.
- Files with the same `voiceFileId` should be downloaded once and shared.
- Do not delete a cached file merely because a single list request failed.

---

## 5. UI integration

### Conversations

- Add a play/pause control per conversation row when `voiceFileId != null`.
- If `voiceFileId == null`, hide or disable the control and show the existing text/translation without audio.
- On play:
1. Use the local file if cached.
2. Otherwise download, show a loading state, then play.
- Only one conversation audio should play at a time.
- For sequential/course playback, advance only after playback completes or the user skips.
- The playback-resume endpoint returns the conversation nested under `data.iKnowConversation`; use its `voiceFileId` through the same resolver.
- Keep the existing `voice` actor-type badge/selection behavior unchanged.

### Vocabulary

- Add a pronunciation/play button per vocabulary item when `voiceFileId != null`.
- Add the same button to the practice response’s `correctWord` (and optionally `wrongWord` if the UX supports it).
- Use the same download/cache resolver as conversations.
- Stop any currently playing audio before starting a new one.

### States to support

- `no voice` — `voiceFileId == null`
- `downloading` — show spinner/progress
- `ready` — play from local file
- `download failed` — show retry affordance
- `file missing on server` — 404/410; remove cache and hide/disable playback
- `offline` — play cached files; show unavailable for uncached ones

---

## 6. Edge cases

- Legacy data: both voice fields may be `null`. The app must not crash or show a broken player.
- File replaced by admin: new `voiceFileId` and new `voiceChecksum`; download the new file and clean up the old one during the next sync.
- Same file reused across multiple records: download once, play from the shared local path.
- Deleted conversation/vocabulary: its cached file becomes stale after the next successful list sync.
- Private or encrypted file: backend rejects the assignment, so the app should never receive such a `voiceFileId`. If download returns `403`/`404`, treat it as unavailable.
- Android/iOS audio focus: pause other audio when starting playback, and release players when leaving the screen.
- Do not assume a file extension from the ID; use the response `Content-Type`.

---

## 7. Ordered task breakdown

1. **Models / parsing**
- Add `voiceFileId`, `voiceChecksum` to API models.
- Parse `meta.checksum` on list responses.
- Add nullable handling everywhere.

2. **Voice cache service**
- Download via `/v1/storage/public/:fileId`.
- Follow redirects, infer extension, atomic write.
- Expose `getLocalVoice(fileId)` and `ensureVoice(fileId, checksum)`.
- Persist cache metadata across app restarts.

3. **Sync layer**
- Implement the per-course list checksum check.
- Per-item checksum comparison and stale-file cleanup.
- Fallback when `meta.checksum` is absent.

4. **Conversation UI**
- Play/pause control, loading/error states.
- Integrate with playback-resume endpoint.
- Single-active-player behavior.

5. **Vocabulary UI**
- Pronounce button on list/practice items.
- Shared player coordination.

6. **Lifecycle / cleanup**
- Cancel downloads on screen exit.
- Remove stale files after successful sync.
- Release native players.

7. **Tests**
- Unit tests for checksum comparison and sync decisions.
- Integration tests for download + redirect + content-type extension.
- UI tests for null voice, cached playback, failed download, replaced voice.

---

## 8. Acceptance criteria

- A conversation/vocabulary with a `voiceFileId` downloads and plays audio on first use.
- A second play uses the local cache without a network download.
- Replacing a voice on the backend causes the next list sync to download the new file and delete the old cached file.
- Text/order/translation-only changes do not trigger audio re-downloads.
- `voiceFileId == null` renders without errors and without a play control.
- Shared `voiceFileId` values result in one download and multiple playback sources.
- Offline playback works for previously downloaded voices.
- `404`/`403` downloads remove stale cache entries and show a retry/disabled state.
- List sync still works if `meta.checksum` is missing.
- No direct S3/storage URL is hardcoded in the app.

## 9. Out of scope / coordination notes

- Admin upload behavior and backend validation are already implemented.
- The app does not need to create/update voices; those are admin-only.
- `voice` (`male`/`female`) remains an actor-type field, not audio.
- If backend `meta.checksum` is later removed, per-item `voiceChecksum` remains sufficient for correctness.
- Do not migrate or modify the backend schema from the app repository.