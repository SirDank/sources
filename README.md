# Sources

[AltStore](https://altstore.io) / [SideStore](https://sidestore.io) source for my iOS apps.
It works in any store that accepts AltStore sources.

Add this URL in your store's **Sources** screen:

```
https://raw.githubusercontent.com/SirDank/sources/main/apps.json
```

## Apps

| App | What it is |
| --- | --- |
| [SKapsule](https://github.com/SKonstruct/SKapsule-iOS) | Spiral Knights on iPhone and iPad |

Third-party apps, listed unmodified from their authors' GitHub releases (the IPA is the one they
publish, checked against their checksum). They are not mine; report problems to their authors.

| App | What it is |
| --- | --- |
| [Madeira](https://github.com/willfaust/Madeira) | Windows PC games on iPhone and iPad (needs JIT, iOS 18+) |
| [LinuxRunner](https://github.com/mxhm11cr/LinuxRunner) | ARM64 Linux and desktops on iPhone and iPad |
| [Henge](https://github.com/Leviidev/Henge) | macOS on iPhone and iPad (needs JIT) |

Coming later (no public release yet): Wintur, Windows command-line software on iPhone and iPad,
and MoUtils, offline utilities with on-device AI.

## Adding a release

Each app publishes its IPA as a GitHub release. Download the released file and run

```sh
./update.sh <ipa> <download URL> ["release notes"] [release date, ISO 8601 UTC]
```

It matches the app by bundle identifier, records the size and sha256 that stores verify, and
edits `apps.json` only. Review and commit it yourself.

Apps without a public release wait in `pending/` instead of `apps.json`, because AltStore fails to
load a source that contains an app with no versions. `update.sh` moves an app from `pending/` into
`apps.json` on its first release. Before that, check its `appPermissions` against the released IPA:
stores refuse an install whose entitlements or privacy keys differ.
