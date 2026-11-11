#!/usr/bin/env bash

# Adds a release of one app to apps.json from its released IPA, so the size, sha256, version
# and date always match the file users download. The app is matched by bundle identifier in
# apps.json, or promoted from pending/ on its first release. Edits apps.json (and removes the
# promoted pending file) only; commit it yourself. appPermissions.privacy is taken from the IPA.
# Usage: ./update.sh <ipa> <download URL> ["release notes"] [release date, ISO 8601 UTC]
# The date defaults to now; pass the release's publish date when adding an older release.

set -euo pipefail

[ $# -ge 2 ] || { echo "usage: $0 <ipa> <download URL> [notes]" >&2; exit 1; }

python3 - "$(dirname "$0")/apps.json" "$1" "$2" "${3:-}" "${4:-}" <<'PY'
import glob, hashlib, json, os, plistlib, sys, zipfile
from datetime import datetime, timezone

src, ipa, url, notes, date = sys.argv[1:6]
with zipfile.ZipFile(ipa) as z:
    info = plistlib.loads(z.read(next(n for n in z.namelist() if n.count("/") == 2 and n.endswith(".app/Info.plist"))))
data = open(ipa, "rb").read()
v = {
    "version": info["CFBundleShortVersionString"],
    "buildVersion": info["CFBundleVersion"],
    "date": date or datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "localizedDescription": notes or f"Version {info['CFBundleShortVersionString']}",
    "downloadURL": url,
    "size": len(data),
    "sha256": hashlib.sha256(data).hexdigest(),
    "minOSVersion": info.get("MinimumOSVersion", ""),
}
s = json.load(open(src))
app = next((a for a in s["apps"] if a["bundleIdentifier"] == info["CFBundleIdentifier"]), None)
if app is None:  # first release: promote the app from pending/ (AltStore rejects apps with no versions)
    pend = next((p for p in sorted(glob.glob(os.path.join(os.path.dirname(src), "pending", "*.json")))
                 if json.load(open(p))["bundleIdentifier"] == info["CFBundleIdentifier"]), None)
    if pend is None:
        sys.exit(f"no apps.json or pending/ entry for {info['CFBundleIdentifier']}")
    app = json.load(open(pend))
    s["apps"].append(app)
    os.remove(pend)
# Stores refuse an install whose privacy keys differ from the IPA's, so take them from it.
# (The entitlements are not in Info.plist: update appPermissions.entitlements by hand when they change.)
app.setdefault("appPermissions", {})["privacy"] = {k: info[k] for k in sorted(info) if k.endswith("UsageDescription")}
# Newest first (AltStore reads the order); re-adding a URL replaces its entry.
app["versions"] = [v] + [o for o in app["versions"] if o["downloadURL"] != url]
# Older clients read these flat fields instead of versions[].
app.update(version=v["version"], versionDate=v["date"], versionDescription=v["localizedDescription"],
           downloadURL=url, size=v["size"], sha256=v["sha256"])
json.dump(s, open(src, "w"), indent=2, ensure_ascii=False)
open(src, "a").write("\n")
print(f"{app['name']}: {v['version']} ({v['buildVersion']}), {v['size']} bytes, sha256 {v['sha256'][:12]}…")
PY
