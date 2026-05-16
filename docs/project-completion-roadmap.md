# NutriLens Project Completion Roadmap

Source: Google Drive deck `Angela Project Log`, original presentation ID `1MD3-s94TTRG1_ByBO2C5zJYh39QppNVlHZSALQA_L08`.

## Project Description

NutriLens is described as an augmented-reality smart glasses plus companion mobile app system. The glasses recognize food, dishes, and packaged products, then overlay calories, macros, allergen warnings, and personalized recommendations in the user's field of view. The mobile app is the health hub: daily intake tracking, nutrition trends, personalized meal plans, health goals, and support for food allergies or medical restrictions.

The current milestone slide names the stack as Flutter for the mobile app and Firebase for the backend. The UI mockups use the app name `ApexFuel`, while the project log uses `NutriLens`. Before implementation, choose whether the app brand should be `NutriLens`, `ApexFuel`, or `NutriLens by ApexFuel`.

## UI Mockup Analysis

The design direction is not a generic nutrition tracker. It is a sports-performance nutrition app for student athletes, especially tennis players. The product promise in the mockups is "fueling" rather than just calorie counting.

Core screens shown:

- Onboarding: asks for primary sport, uses a full-screen sports photo background, and promises calorie, macro, and fueling-window tuning based on sport demands.
- Home dashboard: greets Angela, shows school/team program membership, daily fuel progress, macro progress bars, next training session, meal plan cards, hydration tracking, and bottom navigation.
- AI meal scan: camera-first screen with detected ingredients, match confidence, portion estimate, macro summary, edit action, and log meal action.
- Meal plan: AI-generated sport-specific meal plan with date selector, match-day nutrition card, meal cards, calorie/protein/carb/fat breakdowns, and regenerate action.
- Schedule: dark-mode training and match schedule with timeline, pre-match fueling windows, and meal/exercise recommendations tied to event time.
- Insights: weekly nutrition performance with fuel score, trend chart, AI coach recommendations, and summary metric tiles for calories, protein, hydration, and sleep.
- Profile: athlete profile, sport/team metadata, streak/meals/fuel score, active goal, nutrition settings, allergies/diet, and health sync.
- Community: school/team program impact, leaderboard, coach AI report, and impact stories.
- Hardware concept: AR glasses with dual camera array, micro OLED HUD, on-device food AI engine, Qualcomm AR1 class processor, BLE/Wi-Fi app sync, and battery system.
- Lifestyle AR concept images: students wearing glasses with floating hydration or pre-practice fueling overlays.

UI style:

- High-contrast black, white, neon lime, blue, orange, and purple accents.
- Large bold rounded typography, oversized metrics, pill badges, progress bars, and card-based summaries.
- Bottom navigation centered on a prominent camera scan button.
- Food photography is central, not decorative; meal cards need real food images or image placeholders.
- The app has both light and dark surfaces, so the Flutter theme should support a deliberate color system rather than relying on default Material colors.

## Current Repo State

The local project is still the default Flutter counter app. There is no NutriLens UI, Firebase setup, camera flow, data model, routing, or app-specific assets yet.

Important setup issue: `pubspec.yaml` requires Dart SDK `^3.10.8`, but the installed Flutter tool reports Dart `3.10.7`. `flutter analyze` currently fails during dependency resolution because of that SDK mismatch. Fix this before implementation by either upgrading Flutter/Dart or lowering the SDK constraint to match the installed stable toolchain.

Context7 docs check:

- Flutter docs confirm Firebase initialization should happen before `runApp`, using `WidgetsFlutterBinding.ensureInitialized()` and `Firebase.initializeApp(...)`.
- Firebase Flutter snippets confirm Firestore references, auth state listeners, and Storage references as the right backend building blocks for this app.

## Completion Roadmap

### Phase 0: Alignment and Setup

- Decide final product/app name: `NutriLens`, `ApexFuel`, or combined branding.
- Fix Flutter/Dart SDK mismatch so `flutter pub get` and `flutter analyze` run.
- Replace default Flutter demo title and counter app.
- Create app design tokens: colors, text styles, spacing, card radius, icons, shadows, and light/dark page backgrounds.
- Add project folders for `features`, `models`, `services`, `theme`, `widgets`, and `assets`.
- Add initial image assets or placeholders for food, sports, profile, and AR concept screens.

### Phase 1: Static UI Prototype

- Build app shell with bottom navigation: Home, Meals, Scan, Schedule, Profile/Insights.
- Implement the core mockup screens as static data first:
  - Onboarding sport selection
  - Home dashboard
  - Meal scan result
  - Meal plan
  - Schedule
  - Insights
  - Profile
  - Community
- Match the mockups closely enough for a demo: neon lime action color, large macro cards, camera center button, food imagery, sport/team labels, and timeline cards.
- Add responsive constraints so the UI works on common phone sizes.
- Add widget tests for app boot and navigation.

### Phase 2: Data Model and Local State

- Define models for `UserProfile`, `SportProfile`, `Meal`, `IngredientDetection`, `NutritionSummary`, `WorkoutEvent`, `FuelGoal`, `InsightMetric`, and `TeamProgram`.
- Add local mock repositories so the UI is not hard-coded inside widgets.
- Implement onboarding state and selected sport affecting dashboard labels/goals.
- Implement meal logging from scan result into a local daily meal list.
- Implement progress calculations for calories, carbs, protein, fats, hydration, sleep, and fuel score.

### Phase 3: Firebase Backend

- Create Firebase project and register Android/iOS app IDs.
- Add Firebase packages: `firebase_core`, `firebase_auth`, `cloud_firestore`, and `firebase_storage`.
- Generate `firebase_options.dart` and initialize Firebase in `main.dart`.
- Add simple authentication, likely email/password or anonymous auth for classroom demo speed.
- Create Firestore collections:
  - `users`
  - `userProfiles`
  - `meals`
  - `mealScans`
  - `nutritionGoals`
  - `scheduleEvents`
  - `teamPrograms`
  - `insights`
- Store uploaded/scanned meal images in Firebase Storage.
- Add Firestore security rules so users only access their own nutrition data, while team/program data has controlled read access.

### Phase 4: Camera and Food Recognition MVP

- Add camera capture flow behind the center scan button.
- Start with a practical MVP:
  - Capture or select meal image.
  - Show a loading/analyzing state.
  - Return a mock or manually entered detection result.
  - Let the student edit ingredients and portions.
  - Log the meal to Firestore.
- Later upgrade the recognition layer:
  - Use a cloud vision/AI service or a small custom food classifier.
  - Store confidence and detected ingredients.
  - Keep human edit as required because food portion estimates are error-prone.

### Phase 5: Personalization and AI Coach

- Generate meal plans from goals, sport, schedule, and dietary restrictions.
- Add match-day fueling rules: pre-match carbs, hydration target, post-match protein.
- Implement AI coach cards as deterministic recommendations first.
- Add real trend calculations for weekly fuel score, protein goals, hydration gaps, and sleep.
- Add allergy/diet flags so recommendations avoid unsafe foods.

### Phase 6: Schedule and Team/Community

- Add schedule event creation: training, match, rest day, and meal reminders.
- Link nutrition recommendations to event timing.
- Add team/program membership and leaderboard screens.
- Add coach report summaries from team aggregate data.
- Keep student privacy boundaries clear: show team averages and rankings only if appropriate for the classroom/demo scope.

### Phase 7: Hardware Prototype Track

- Treat hardware as a parallel capstone/prototype, not a blocker for the mobile app MVP.
- First hardware deliverable: concept slide plus simulated AR overlay in app.
- Second deliverable: phone camera scan acting as a stand-in for glasses.
- Third deliverable: optional BLE demo where an external device sends a mock scan event to the app.
- Full AR glasses food recognition is a major hardware/ML project and should be scoped as stretch work.

### Phase 8: Publishing, Paper, and Patent Prep

- App publishing prep: app icon, package name, screenshots, privacy policy, Firebase production rules, and store metadata.
- Paper: problem, target users, system architecture, UI flow, data model, AI/camera limitations, testing, and future work.
- Patent/invention draft: define novelty carefully around AR nutrition overlays, athlete fueling recommendations, and school/team program integration. This needs legal review before any real filing.

## Recommended MVP

Build the mobile app first. For the first complete demo, the goal should be:

- Onboarding for Angela's sport and goals.
- Home dashboard with fuel score and macro targets.
- Meal plan and schedule screens.
- Camera scan flow with simulated AI detection.
- Log meal to Firebase.
- Insights screen generated from logged data.
- Profile and team/community screens with realistic demo data.

Defer real AR glasses, real food model training, app store publishing, paper, and patent until the app can be demonstrated end to end.
