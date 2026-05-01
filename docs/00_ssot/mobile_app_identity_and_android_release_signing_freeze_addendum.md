# Mobile App Identity And Android Release Signing Freeze Addendum

## 0. Verdict

- Current stage: formal mobile app identity freeze for Alipay mobile application creation.
- Current execution boundary: freeze identifiers and prepare Android release signing material only.
- No-Go: do not submit Alipay app review, do not enable production payment products, do not upload payment keys, do not switch production traffic.

## 1. Current Evidence

| Item | Current value | Verdict |
|---|---|---|
| Android `applicationId` | `com.example.mobile` | Temporary Flutter default; not allowed for Alipay formal app creation |
| Android `namespace` | `com.example.mobile` | Temporary Flutter default; must be changed in a later app identity implementation package |
| iOS `PRODUCT_BUNDLE_IDENTIFIER` | `com.example.mobile` | Temporary Flutter default; not allowed for Alipay formal app creation |
| Android release signing | release currently uses debug signing | No-Go for formal Alipay mobile app signature |
| Android release keystore | not found in local mobile project | must generate or import a formal release/upload key |

## 2. Frozen Formal Identity

| Field | Frozen value | Reason |
|---|---|---|
| Product name | `展览定制之家` | Matches Alipay formal app creation name |
| Android package name | `com.zhanlandingzhijia.mobile` | Stable brand-based package id; replaces temporary `com.example.mobile` |
| iOS Bundle ID | `com.zhanlandingzhijia.mobile` | Keep iOS and Android identity aligned |
| Alipay app type | mobile application | User selected mobile app in Alipay Open Platform |
| Alipay app platform | all | User selected all, covering Android and iOS |

## 3. Android Signing Freeze

| Item | Frozen value |
|---|---|
| Keystore file | `apps/mobile/android/upload-keystore.jks` |
| Key properties file | `apps/mobile/android/key.properties` |
| Key alias | `upload` |
| Key algorithm | RSA |
| Key size | 2048 |
| Validity | 10000 days |
| Secret handling | local-only, ignored by Git, do not commit, do not paste into chat |

## 4. Current Minimum Closed Loop

1. Generate Android release/upload keystore locally.
2. Record Android certificate fingerprints for Alipay mobile app creation.
3. Use `com.zhanlandingzhijia.mobile` as Android package name and iOS Bundle ID in Alipay.
4. Keep local Flutter package rename as a separate implementation package.

## 5. Retained But Not Opened

- Flutter Android package rename.
- iOS Bundle ID rename.
- Android release build wiring.
- Alipay production app review submission.
- Alipay production payment product activation.
- Payment callback public ingress.
- Real-money UAT.

## 6. Later Extension Slots

- App Store / Android store listing metadata.
- Universal Links / app links.
- Alipay SDK native app-pay integration.
- Production certificate mode.
- Key rotation and release signing custody policy.

## 7. Gates

| Gate | Current verdict | Notes |
|---|---|---|
| Formal identifiers | Pass | frozen as `com.zhanlandingzhijia.mobile` |
| Android release signing material | Pass | local keystore generated and fingerprint verified |
| Alipay app creation | Conditional Go | allowed only after signing fingerprint is available and merchant account is selected |
| Production payment enablement | No-Go | requires separate finance production gate |

## 8. Execution Receipt

| Item | Result |
|---|---|
| Android keystore generated | `apps/mobile/android/upload-keystore.jks` |
| Android key properties generated | `apps/mobile/android/key.properties` |
| File permissions | local-only, `600` |
| Key alias | `upload` |
| Creation date | 2026-04-30 |
| SHA1 | `40:1E:12:CF:E4:6D:64:A6:69:05:30:FD:7E:1A:6E:C3:5D:28:AF:B8` |
| SHA256 | `50:2F:43:A9:D8:F7:10:8C:80:AF:40:FC:ED:F3:A0:7C:35:8E:EF:C2:A4:B3:E0:58:C3:68:29:14:7F:04:A0:C2` |
| Alipay Android app signature candidate | `6bc5dcf1972574f234dd3186bd3f3982` |
| Upload icon candidate | `/Users/wangweiwei/Desktop/资料模板/展览定制之家图标_320.png` |

## 9. Remaining Before Alipay Creation

1. Select merchant account in Alipay Open Platform.
2. Upload the 320px icon candidate.
3. Fill Android package name: `com.zhanlandingzhijia.mobile`.
4. Fill Android app signature: `6bc5dcf1972574f234dd3186bd3f3982`.
5. Fill iOS Bundle ID: `com.zhanlandingzhijia.mobile`.
6. Leave Universal Links empty only if Alipay permits it; otherwise freeze a real domain-based Universal Links path first.
7. Create the Alipay app only after the above fields are reviewed on screen.
