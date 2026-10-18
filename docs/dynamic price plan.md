# Implementation Plan — App-side Points Discount for CafeBazaar IAP

## 0. What changed on the backend (what the app must integrate)

The existing CafeBazaar direct-purchase flow is unchanged except for one added optional field, plus there are **two new capabilities**:

| Endpoint | Auth | Purpose |
|---|---|---|
| `GET /api/v1/user/points/total` | Bearer | Existing — read points balance for the slider |
| `POST /api/v1/payments/cafebazaar/quote` | Bearer | **New** — validate/count spendable points, get a discounted price + `dynamicPriceToken` |
| `POST /api/v1/payments/direct` | Bearer | Existing — now accepts an optional `nonce` to settle a points discount |

Key semantics:
- **1 point = `pointValueInRials` IRR** (default `1000`), returned by the quote so the app never hardcodes it.
- Points are **only deducted when `/payments/direct` succeeds**; abandoned/failed Bazaar purchases cost nothing.
- A quote is **single-use and short-lived** (default TTL 600s, returned as `expiresAt`). After it's used it is rejected; after it expires it's rejected.
- Discount applies **on top of** any item-level discount already baked into the price.
- **`finalPrice` may be `0`** (fully discounted) and is allowed.
- All prices are in **IRR (Rial)**.

Response envelope reminder — every success is `{ "ok": true, "data": { ... } }`.

---

## 1. Points balance (checkout screen init)

`GET /api/v1/user/points/total`

```json
{ "ok": true, "data": { "remaining": 150, "added": 200, "deducted": -50 } }
```

- Treat `null` as `0` (backend normalizes `remaining`, but `added`/`deducted` may still be `null`).
- Use `remaining` as the slider maximum, but the real cap is also bounded by price — the quote returns the exact allowed maximum implicitly by rejecting over-spend. Prefer to also fetch the point value from the quote response.

---

## 2. Quote (the "counting + dynamic price" step)

`POST /api/v1/payments/cafebazaar/quote`

Request:
```json
{ "productType": "Book", "bazaarSku": "<sku>", "pointsToSpend": 100 }
```

- `productType` ∈ `IKnow | IKnowBook | IKnowCourse | VideoCourse | Book` (same values the app already sends to `/payments/direct`).
- `bazaarSku` must be the SKU configured on the product server-side; mismatch → `422 cafebazaarItemUnavailable`.
- `pointsToSpend` is an integer ≥ 0.

Response:
```json
{ "ok": true, "data": {
  "nonce": "9f2c…",
  "token": "eyJhbGciOiJIUzI1NiJ9…",
  "expiresAt": "2026-10-16T10:10:00.000Z",
  "basePrice": 5000000,
  "pointsSpent": 100,
  "discountAmount": 100000,
  "finalPrice": 4900000,
  "remainingPoints": 50,
  "pointValueInRials": 1000
} }
```

App behaviour:
- Call this **on every slider change (debounced)** or at least once when the user confirms, to get the authoritative `finalPrice` + `token`. Do **not** compute the discounted price locally.
- Render `finalPrice` and `basePrice − finalPrice` as the discount; `pointValueInRials` drives the "each point = X" hint.
- If the user chooses **0 points**, you may skip the quote entirely and call `/payments/direct` **without** `nonce` (existing behaviour). Only quote when points > 0. (Recommend this to keep the no-discount path identical to today.)
- Keep the returned `nonce`, `token`, and `expiresAt` keyed to the pending purchase attempt.

Quote errors to handle:
- `422 cafebazaarInsufficientPoints` → the requested points exceed `min(balance, floor(basePrice / pointValueInRials))`. Clamp the slider / show the message and let the user pick fewer.
- `503 cafebazaarServiceUnavailable` → provider disabled/down; fall back to a non-discounted purchase.
- `422 cafebazaarItemUnavailable` / `itemIsNotPublished` → product not purchasable.

---

## 3. Initiate the Bazaar purchase with the dynamic price token

Pass the quote's `token` as **`dynamicPriceToken` in Poolakey's `PurchaseRequest`** (this is the documented mechanism; verify the exact property name against the Poolakey version in use).

```
PurchaseRequest(productId = bazaarSku, payload = <optional>, dynamicPriceToken = <token>)
```

Requirements & fallbacks:
- **Dynamic pricing requires CafeBazaar app version ≥ 13.3.0.** Detect the "dynamic price not supported" error from the billing client and fall back to a normal (full-price) purchase — i.e., re-call `/payments/direct` without `nonce`.
- The token is bound to `sku` + `package_name` + an expiry; the app must not modify or reuse it for another SKU.
- Generate/persist a client-side attempt record: `{ bazaarSku, productType, nonce, expiresAt, requestedPoints }`.
- On the Poolakey result, capture `purchaseToken` and the purchased `productId`. Confirm `productId == bazaarSku` before settling.
- Map CafeBazaar's documented error codes **1–16** to user-facing messages; for token-related failures, re-run the quote and retry the purchase if the discount still applies.

---

## 4. Settle the purchase

`POST /api/v1/payments/direct`

```json
{
  "productType": "Book",
  "bazaarSku": "<sku>",
  "purchaseToken": "<token from Poolakey>",
  "nonce": "<quote nonce, omit if no points spent>",
  "referrerCode": "<optional>"
}
```

- Send `nonce` **only** when a points discount was quoted; it must be the same nonce whose token was used.
- The `purchaseToken` is the backend's idempotency key: retrying the same `purchaseToken` returns the existing payment and **never** double-deducts points. Persist it and always retry with the same value on network failures.
- On success the returned `data` is the Payment object; surface `pointsSpent`, `discountAmount`, and `grandTotal` in the receipt.

Errors to handle:
- `422 cafebazaarDynamicPriceInvalid` → the nonce is unknown, expired, already consumed, or doesn't match the SKU/type. **Do not retry with the same nonce** — re-quote (if the user still wants the discount) and re-purchase; or settle without the discount.
- `409 cafebazaarTokenAlreadyUsed` → this purchase token is registered to another user. Do not retry; investigate.
- `422 cafebazaarVerificationFailed` → Bazaar rejected the purchase.
- `422 itemAlreadyOwned` is **not** returned by this endpoint today (re-purchase is allowed and benefits are skipped server-side), but display ownership state in the UI where possible.

---

## 5. Failure / retry state machine

1. User picks points → `POST /quote` → store `{nonce, token, expiresAt}`.
2. Poolakey purchase with `dynamicPriceToken`.
   - Success → `POST /direct` with `{purchaseToken, nonce}` → on success, refresh points balance and show receipt.
   - Token expired / discount still wanted → back to step 1 (new nonce + token).
   - Dynamic pricing unsupported (Bazaar < 13.3.0) → `POST /direct` without `nonce` (full price).
   - User cancels / purchase fails → no server call needed; nothing was deducted.
3. Network failure while calling `/direct` → retry with the **same** `purchaseToken` (and same `nonce` if it was used). Treat `422 cafebazaarDynamicPriceInvalid` as terminal for that nonce.
4. On app restart / restore, use Poolakey's purchase query to find unsettled purchases and call `/direct`.

---

## 6. Suggested app tasks

1. **API layer**: add `getPointsTotal()`, `createBazaarQuote(productType, bazaarSku, pointsToSpend)`, and extend `createDirectPayment(...)` with `nonce`. Reuse the existing auth/Bearer + `{ok,data}` envelope handling.
2. **Checkout UI**: points slider (0..`remaining`), live `finalPrice`/discount display driven by `/quote`, "each point = `pointValueInRials`" hint, disabled/retry states.
3. **Poolakey integration**: pass `dynamicPriceToken`; detect version/unsupported error; capture `purchaseToken`/`productId`.
4. **Settlement**: call `/direct` with `nonce`, handle the error taxonomy above, persist attempt state for retries.
5. **Receipt/history**: show points spent and discount for the payment (backend returns `pointsSpent`, `discountAmount`, `grandTotal` on the Payment).
6. **QA matrix** (see below).

---

## 7. Test checklist

- 0 points → purchase at full price via `/direct` without `nonce` (regression).
- Some points → discounted `finalPrice`, correct `purchaseToken` settlement, `pointsSpent`/`discountAmount` recorded, balance reduced.
- Points worth more than the item price → quote clamps/rejects; slider never allows `finalPrice < 0`.
- Fully discounted (`finalPrice = 0`) → Bazaar accepts 0 price; purchase settles.
- Quote expires before purchase → re-quote and succeed.
- Retry `/direct` with the same `purchaseToken` → no double deduction.
- Reuse a consumed `nonce` → `422 cafebazaarDynamicPriceInvalid`.
- CafeBazaar < 13.3.0 → graceful full-price fallback.
- Item with its own (IKnow package) discount + points → discount stacks on the already-discounted price.
- Network drop between Poolakey success and `/direct` → recovery on retry/restore.
- Returned prices are IRR; confirm the UI's Rial→Toman conversion (`/10`) if the checkout displays Toman.

---

## Notes / assumptions to verify with the App agent

1. **Poolakey API surface** — I referenced `PurchaseRequest.dynamicPriceToken` from your earlier spec; confirm the exact property name and builder for the Poolakey version pinned in the app. If Poolakey's dynamic-price support isn't in the current version, the app needs the upgrade first.
2. **Bazaar account id / `account_id` claim** — omitted by backend; nothing for the app to send.
3. **Points balance source** — if the checkout currently caches the user profile, add a dedicated points fetch (or use `GET /user/points/total`) so the slider reflects `remaining` accurately.
4. **Price display unit** — backend is IRR end-to-end; any Toman conversion is purely presentational on the app side.

If the App agent can share the Poolakey version and the existing `PurchaseRequest`/direct-payment code, I can tighten steps 3–4 into exact call signatures.