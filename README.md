# fitness_app

A modern Flutter application for fitness and workout tracking.

---

## 🚀 CI/CD & Automated Verification

Continuous Integration is enforced on every Pull Request via **GitHub Actions**:

- **Branch Naming Check**: Ensures branches follow standard conventions (`feature/*`, `bugfix/*`, `hotfix/*`, `release/*`, `chore/*`, `refactor/*`, `docs/*`, `test/*`, `ci/*`).
- **Lint & Static Analysis**: Runs `dart format --set-exit-if-changed` and `flutter analyze --fatal-infos --fatal-warnings`.
- **Automated Tests**: Runs the unit and widget test suite (`flutter test`) and publishes summary metrics directly onto the PR.

For detailed guidelines and branch naming rules, please read [CONTRIBUTING.md](CONTRIBUTING.md).

---

## 🛠️ Local Development & Pre-PR Commands

Before opening a pull request, run the following commands to ensure all CI checks pass:

```bash
# Format code
dart format .

# Check code analysis and linter
flutter analyze

# Run all automated tests
flutter test
```

---

## 📱 Getting Started

1. Ensure you have Flutter 3.44+ and Dart 3.12+ installed:
   ```bash
   flutter doctor
   ```
2. Install packages:
   ```bash
   flutter pub get
   ```
3. Run code generators:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Run the app:
   ```bash
   flutter run
   ```
