## 1. Profile Screen Guest Wall

- [x] 1.1 In `ProfileScreen.build`, wrap the body content in a conditional: if `_isProfileDisabled` is true (and not loading), render a centered column with an icon, title ("Create an account"), and subtitle ("Sign up to set up your profile and save your data") instead of the form
- [x] 1.2 Ensure the `_loading` guard still renders `CircularProgressIndicator` before the guest-wall check so the screen doesn't flash the wall during load
- [x] 1.3 Verify the AppBar settings icon remains enabled (not gated on `_loading`) when the guest wall is shown
- [x] 1.4 Remove the inline `GuestAccountNotice` widget call from the form body since it's no longer needed (the wall replaces it)
