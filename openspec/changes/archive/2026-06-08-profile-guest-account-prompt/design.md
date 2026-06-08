## Context

The profile screen currently checks `_isProfileDisabled` (guest + no cloud sync) to disable individual fields and show a small `GuestAccountNotice` banner. The rest of the form—avatar, segmented tabs, all fields, save button—remains visible but inert, which is visually noisy and confusing.

The fix is a single conditional branch in `ProfileScreen.build`: when the user is a guest, render only the AppBar and a centered message. No new dependencies, no data model changes.

## Goals / Non-Goals

**Goals:**
- Show a full-screen placeholder message to guest users instead of the disabled form
- Keep the AppBar + settings icon visible so users can navigate to account settings
- Reuse the existing `_isProfileDisabled` guard — no new auth logic

**Non-Goals:**
- Adding a CTA button (e.g., "Create Account") — just text for now
- Changing sign-up or onboarding flows
- Modifying `GuestAccountNotice` widget (it stays for potential future use)

## Decisions

**Decision: branch at the body level, not field level**
Switch the `body` content entirely when `_isProfileDisabled` is true, rather than wrapping individual widgets. This is simpler and removes all risk of a field accidentally being enabled.

Alternative considered: keep the form but overlay an `AbsorbPointer` + `Opacity`. Rejected — still renders the full form widget tree and is less readable.

**Decision: inline the message, no new widget**
The guest wall is three widgets (icon, title, subtitle) centered on screen. Extracting it to a widget adds indirection with no reuse benefit yet.

## Risks / Trade-offs

- [Risk] `_isProfileDisabled` evaluated before `_loading` completes → Mitigation: loading guard already runs first; `_isProfileDisabled` reads `_account` which is populated after load, so the wall only appears after load resolves.
- [Trade-off] No "Create Account" button means user must tap Settings manually — acceptable per scope; settings icon in AppBar is the escape hatch.
