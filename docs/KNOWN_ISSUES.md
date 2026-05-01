# Known Issues — WorkoutKit Beta 1.0.0 (Build 1)

> Last updated: 2026-05-01
> TestFlight group: Internal Testers

---

## Open Issues

### [WK-001] Live Activity not installable on Simulator
**Severity:** Low (Simulator only)
**Status:** By design
The `WorkoutKitLiveActivity` widget extension is excluded from Simulator builds. Test Live Activity features on a physical device.

### [WK-002] StoreKit purchases require Sandbox account on physical device
**Severity:** Low
**Status:** Known
Tapping "Buy Now" on a real device requires a Sandbox Apple ID. Use Settings → App Store → Sandbox Account to sign in. The `.storekit` config works for Simulator without an account.

### [WK-003] Sleep data not available in HealthKit Simulator
**Severity:** Low (Simulator only)
**Status:** Expected
HealthKit sleep analysis is unavailable in Simulator. Test on a device with Health app data.

### [WK-004] Widget medium/large sizes require Premium entitlement
**Severity:** Informational
**Status:** By design
The WidgetKit extension exposes small-size widgets to free users only. Medium and large sizes are gated behind `ProFeatureGate.isPremium`. This is intentional per product spec.

---

## Recently Fixed

| ID | Description | Fixed in |
|---|---|---|
| - | - | - |

---

## Reporting New Issues

File issues via TestFlight feedback or directly at:
`tomo060213@gmail.com`

Include: iOS version, device model, steps to reproduce, and a screenshot or crash log from the Feedback button in TestFlight.
