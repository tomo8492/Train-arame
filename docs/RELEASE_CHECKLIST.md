# Release Checklist — WorkoutKit

Use this checklist before each TestFlight upload and App Store submission.

---

## Pre-Archive (every build)

- [ ] Bump `CURRENT_PROJECT_VERSION` in `project.yml` (must be monotonically increasing)
- [ ] Confirm `MARKETING_VERSION` is correct (semver, e.g. `1.0.0`)
- [ ] Run full test suite: `xcodebuild test -scheme WorkoutKit -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max'`
- [ ] All tests pass (0 failures)
- [ ] No `// TODO` or `// FIXME` left in shipping code paths
- [ ] `DEVELOPMENT_TEAM` is set in project.yml or via environment variable

## StoreKit / IAP

- [ ] `com.tomo.workoutkit.pro.unlock` product is Active in App Store Connect
- [ ] Sandbox purchase flow tested on physical device
- [ ] Restore Purchases tested (second device or after reinstall)
- [ ] Family Sharing verified (product is `familySharable: true` in WorkoutKit.storekit)
- [ ] `Transaction.currentEntitlements` correctly restores `ProFeatureGate.isPremium` on cold launch

## TestFlight (Beta builds)

- [ ] Archive using **WorkoutKit-Beta** scheme (`Config/Beta.xcconfig`)
  ```
  xcodebuild archive \
    -scheme WorkoutKit-Beta \
    -destination 'generic/platform=iOS' \
    -archivePath build/WorkoutKit-Beta.xcarchive
  ```
- [ ] dSYM is included in archive (verify in Organizer → Archives → dSYMs)
- [ ] Export IPA with "App Store Connect" distribution method
- [ ] Upload via `altool` or Transporter
- [ ] Update `docs/KNOWN_ISSUES.md` before inviting new testers
- [ ] Add TestFlight "What to Test" notes in App Store Connect

## App Store Submission

- [ ] All TestFlight feedback addressed or documented in KNOWN_ISSUES.md
- [ ] Archive using **WorkoutKit** scheme with **Release** config
- [ ] Privacy Nutrition Label reviewed in App Store Connect (HealthKit data usage)
- [ ] App Review Notes prepared (Sandbox account credentials if IAP is in scope)
- [ ] Screenshots provided for iPhone 6.7" (required), 6.1" (optional)
- [ ] App description and keywords finalised in Japanese (primary) + English
- [ ] Age rating confirmed (4+, no restricted content)
- [ ] Medical disclaimer visible in AboutView (Guideline 1.4.1 ✓)
- [ ] Restore Purchases button accessible without purchase (App Store Guideline 3.1.1 ✓)

## Post-Release

- [ ] Verify crash-free rate in Xcode Organizer / TestFlight analytics after 24 h
- [ ] Monitor App Store Connect reviews
- [ ] Tag release in git: `git tag v1.0.0-beta.1 && git push --tags`
- [ ] Archive this checklist with the build number for the release log
