## Why

Guest users see the profile screen in a partially-disabled state with a small banner notice, but the form and save button are still visible, creating a confusing "broken" feel. The screen should communicate clearly: this feature requires an account, and nothing else should distract from that message.

## What Changes

- Replace the entire profile screen body with a single centered "create an account" message when the user is a guest without cloud sync
- Remove the form, segmented control, save button, and avatar picker from guest view
- Keep the AppBar (with settings icon) so the user can still navigate to account settings to sign up

## Capabilities

### New Capabilities
- `profile-guest-wall`: Full-screen replacement UI on the profile screen for guest users that prompts account creation and disables all profile editing UI

### Modified Capabilities
- None

## Impact

- `lib/features/profile/profile_screen.dart` — gate the body on `_isProfileDisabled`
- `lib/features/profile/widgets/guest_account_notice.dart` — may be replaced or extended with a new full-screen variant; existing widget stays for other uses
