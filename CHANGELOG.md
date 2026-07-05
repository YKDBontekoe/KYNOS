# [1.3.0](https://github.com/YKDBontekoe/KYNOS/compare/v1.2.0...v1.3.0) (2026-07-05)


### Bug Fixes

* **release:** commit SideStore source metadata on each release ([21dada8](https://github.com/YKDBontekoe/KYNOS/commit/21dada86acde2937e971339b06269577a3fd9365))

# [1.2.0](https://github.com/YKDBontekoe/KYNOS/compare/v1.1.0...v1.2.0) (2026-07-05)


### Features

* improve today dashboard with hub sections, coach integration, and ux polish ([#35](https://github.com/YKDBontekoe/KYNOS/issues/35)) ([4f4d667](https://github.com/YKDBontekoe/KYNOS/commit/4f4d6676e6d6a5a43b96baf3e88886c9ef778631))

# [1.1.0](https://github.com/YKDBontekoe/KYNOS/compare/v1.0.1...v1.1.0) (2026-07-05)


### Bug Fixes

* **ci:** unblock semantic-release for non-conventional squash commits ([#34](https://github.com/YKDBontekoe/KYNOS/issues/34)) ([d11b2c9](https://github.com/YKDBontekoe/KYNOS/commit/d11b2c90fa26ed64e11bed984658aef2627029f0))

## [1.0.1](https://github.com/YKDBontekoe/KYNOS/compare/v1.0.0...v1.0.1) (2026-07-05)


### Bug Fixes

* **ci:** decouple semantic-release from cancellable CI workflow ([#32](https://github.com/YKDBontekoe/KYNOS/issues/32)) ([288b76c](https://github.com/YKDBontekoe/KYNOS/commit/288b76ce441994a3cb6e93a8927f721829756b08))
* **ios:** Connect HealthKit button now triggers permission dialog ([#27](https://github.com/YKDBontekoe/KYNOS/issues/27)) ([9c0e589](https://github.com/YKDBontekoe/KYNOS/commit/9c0e58995c633332a852a3c0508057ef5e894ae3))

# 1.0.0 (2026-07-05)


### Bug Fixes

* add mandatory HealthKit permissions to Info.plist ([95adc4f](https://github.com/YKDBontekoe/KYNOS/commit/95adc4f8ff5adee4a052d41e26fd7914f074f7a6))
* **android:** raise minSdk to 26 for health plugin release builds ([a6089a9](https://github.com/YKDBontekoe/KYNOS/commit/a6089a9ad450d4d8a8b55eef0f9d011cd722a7cd))
* **ci:** allow secrets context in keystore step and silence gitleaks false positives ([34cf288](https://github.com/YKDBontekoe/KYNOS/commit/34cf2886b5e0ee60afa2495ad8459f48e6b75635))
* create placeholder .env file in CI and docs to fix flutter analyze ([cc9abda](https://github.com/YKDBontekoe/KYNOS/commit/cc9abdaa1bd13c36bc1756b28499aa2f5bac0841))
* regenerate riverpod provider hashes after const changes ([49c4fc8](https://github.com/YKDBontekoe/KYNOS/commit/49c4fc8f233751f3c1062b149b643965008c6f86)), closes [#23](https://github.com/YKDBontekoe/KYNOS/issues/23)
* **release:** unblock semantic-release Android R8 and asset upload ([45259e1](https://github.com/YKDBontekoe/KYNOS/commit/45259e104a74629c5c1983e5a5288f300121125f))
* resolve flutter analyze warnings blocking CI ([e2450c9](https://github.com/YKDBontekoe/KYNOS/commit/e2450c9d9dbb4695f29c2863906c30fc62a15aab))
* Resolve flutter analyze warnings in settings_screen.dart ([d37fd2a](https://github.com/YKDBontekoe/KYNOS/commit/d37fd2a1dbe3e7fbf025b0946937236e3b7110d8))
* resolve import sorting and prefer_const_constructors lint warnings ([67007c7](https://github.com/YKDBontekoe/KYNOS/commit/67007c72d77f318dd27fffa4b072f06c6fd2a96c))
* Sync pubspec.lock to fix CI build_runner failure ([87b4e14](https://github.com/YKDBontekoe/KYNOS/commit/87b4e14218cb17aa123360a832c580308b977571))
* update pubspec constraints and lockfile to match CI runner ([b434c60](https://github.com/YKDBontekoe/KYNOS/commit/b434c6030d14fd8d25d3d010e377e28be6634483))
* update pubspec constraints and lockfile to match CI runner ([b4312b7](https://github.com/YKDBontekoe/KYNOS/commit/b4312b7d25a7cceb40f781cbd47c7095f2dd9240))
* wrap KynosApp with ProviderScope in smoke test ([7f3ccaa](https://github.com/YKDBontekoe/KYNOS/commit/7f3ccaa39a39eb17451d280d7b535c90ae11349a))


### Features

* add comprehensive widget tests for shared components ([5edce14](https://github.com/YKDBontekoe/KYNOS/commit/5edce1430f44a1d07c7a899778664d54dbb49913))
* add RPG gamification system with GameKit integration ([d2bc2c1](https://github.com/YKDBontekoe/KYNOS/commit/d2bc2c18f739d6429c02a477ee41b55f016f9ca7))
* implement high-fidelity 3-page onboarding flow ([987ed24](https://github.com/YKDBontekoe/KYNOS/commit/987ed246b51c39713555c18fcd8016e23f7eacc8)), closes [hi#fidelity](https://github.com/hi/issues/fidelity)
* Implement production-ready Flutter Settings Page ([a992207](https://github.com/YKDBontekoe/KYNOS/commit/a99220772d35eb5e96457767b1acf3e121fa93f9))
* Implement Settings Page and state controller ([fc032f8](https://github.com/YKDBontekoe/KYNOS/commit/fc032f8ea8f899cf638e5b916b080136d36802e7))
* implement v0.2 HealthKit integration and live dashboard metrics ([9813f06](https://github.com/YKDBontekoe/KYNOS/commit/9813f063ecf7b97b135361da4b1bfdffa93e13dc))
* initialize project scaffold and architecture rules (v0.1) ([9a7fc38](https://github.com/YKDBontekoe/KYNOS/commit/9a7fc38a181f65ad90804a9e1f0b3d4284a67b4e))
* integrate Nexus Lab (v0.4) and biomechanics infrastructure into main ([dfa213f](https://github.com/YKDBontekoe/KYNOS/commit/dfa213f31940f2ad0cf7ef028ff81d5486c52bc3))
* integrate on-device Gemma 4 AI coach ([ca7d9de](https://github.com/YKDBontekoe/KYNOS/commit/ca7d9de8bfad4fa9fe767de0c2f7ebb1a4bac8be))

# Changelog

All notable changes to this project are documented in this file by
[semantic-release](https://github.com/semantic-release/semantic-release).
