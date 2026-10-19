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

## Adding a release

Each app's own repo publishes its IPA as a GitHub release. To list it here, run that repo's
`scripts/update-source.sh <ipa> <tag> apps.json` on the released file (it records the size and
sha256 that stores verify), then commit `apps.json`.
