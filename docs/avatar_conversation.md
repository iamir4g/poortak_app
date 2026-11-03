## Handoff plan — Application agent

### API surface (no new endpoints)

**`GET /api/v1/iknow/courses/:courseId/conversation`** (public, no auth)

Each item now includes avatarId: string | null in addition to id, text, translation, voice, order, createdAt, updatedAt, disabledAt, courseId. No request changes are required.

Example:

```json
{
  "data": [
    {
      "id": "…",
      "text": "Hello, how are you?",
      "translation": "سلام، حال شما چطور است؟",
      "voice": "female",
      "avatarId": "6f1c2b9e-…",
      "order": 0,
      "courseId": "…"
    }
  ]
}
```

**Admin endpoints** (for reference only): POST and PATCH /api/v1/admin/iknow/courses/:courseId/conversation[/:conversationId] now accept an optional avatarId in the body, and return it in the response.

### Fetching the avatar

avatarId is the file ID. Resolve it with the existing public storage endpoint:

```
GET /api/v1/storage/public/{avatarId}
```

- Returns 302 redirecting to the file URL — follow redirects in your HTTP client, or use the Location header directly.
- No authentication header is required.
- The backend guarantees the file is public and unencrypted, because the admin API rejects anything else. So no decrypt-key call and no access-grant check are needed.

### Behavior to handle

1. **`avatarId` may be `null`.** Older/existing conversations have no avatar. Render a fallback (initials, generic character icon, or hide the avatar slot) rather than a broken image.
2. **Treat avatar as optional per paragraph**, not per conversation — each row can have a different avatar, and rows are ordered by order ascending.
3. **Avatars may change.** The ID is not stable for a given character; refetch the conversation list on screen entry rather than caching the URL indefinitely. If you cache images, key the cache by avatarId.
4. **Do not hardcode a file extension or assume image-only.** The API does not restrict mimetype (per your decision), so read the Content-Type of the redirect target or render defensively for non-image files.
5. **The avatar is not related in the database.** A file can be deleted independently, in which case /storage/public/{avatarId} returns a 404. Handle a failed avatar load gracefully and keep the paragraph usable.
6. **`voice` is unchanged** and remains an independent field (male / female). avatarId does not replace it.
