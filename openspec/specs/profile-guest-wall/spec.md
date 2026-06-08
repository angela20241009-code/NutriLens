# Spec: Profile Guest Wall

## Purpose

Controls what is rendered on the profile screen when the active user is a guest (anonymous, no cloud sync). Guest users see a call-to-action to create an account instead of the standard profile form; authenticated users see the full form as before.

## Requirements

### Requirement: Guest users see account creation prompt instead of profile form
When the active user is a guest (anonymous) without cloud sync, the profile screen body SHALL be replaced entirely by a centered message prompting account creation. The AppBar (including the settings icon) SHALL remain visible. No form fields, segmented control, avatar picker, or save button SHALL be rendered.

#### Scenario: Guest user opens profile screen
- **WHEN** a guest user (anonymous, no cloud sync) navigates to the profile screen
- **THEN** the screen shows only the AppBar and a centered placeholder message
- **THEN** the placeholder contains a title telling the user to create an account and a subtitle explaining that an account is required to use the profile

#### Scenario: Guest user can still reach settings
- **WHEN** a guest user views the account-creation prompt
- **THEN** the settings icon in the AppBar is tappable and navigates to account settings

#### Scenario: Authenticated user sees full profile form
- **WHEN** a user with cloud sync (non-guest) opens the profile screen
- **THEN** the full profile form is displayed as before
