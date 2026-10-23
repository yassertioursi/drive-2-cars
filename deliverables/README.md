# Cars Drive — Android deliverables

- **App name:** Cars Drive
- **Package:** `com.electrotechnique.electricity.games`
- **Version:** 1.0.0 (versionCode 1)
- **Keystore:** `cars_drive.jks`
- **Key alias:** `cars_drive`
- **Store password / Key password:** `cars_drive`

## Files

| File | Purpose |
|---|---|
| `app-release.aab` | Google Play upload bundle |
| `app-release.apk` | Direct install / sideload |
| `cars_drive.jks` | Release keystore (keep safe) |
| `key.properties` | Signing config used by Gradle |
| `certificate.pem` | Public signing certificate |
| `logo.png` | Source app logo |

## Rebuild

```bash
flutter pub get
flutter build appbundle --release
flutter build apk --release
```
