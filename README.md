# Atlantic Breakfast — Online APK Build

Upload these files to your GitHub repo root, then run the action:

- `.github/workflows/build.yml`
- `lib/main.dart`
- `assets/logo.png`
- `pubspec.yaml`

**Run:** Actions → **Build APK (Online)** → Run workflow  
**Download:** Artifact `atlantic_breakfast_release_apk` → `app-release.apk`

The workflow creates a fresh Flutter project (`--org com.atlantic`, package `com.atlantic.breakfast`), injects your app code, sets the label to **Atlantic Breakfast**, builds a release APK, and uploads it.

Admin: `admin / 123456` — InstaPay: `01272716001` — Arabic default + English switch.
