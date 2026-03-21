# Reviewer App: Troubleshooting & Developer Guide

This document was created to help future developers understand common issues previously encountered in this application and how to resolve them. It also provides a cheat sheet of the most important Flutter terminal commands used during development.

---

## Common Encountered Issues & Fixes

### 1. Flutter Build Error: Execution failed for task `:sqflite_android:compileDebugJavaWithJavac`
**Problem:** When building the app for Android, you might encounter an error indicating that the Java build for the `sqflite_android` plugin failed (typically citing an issue with Java compilation or JDK version incompatibility).
**Cause:** Newer versions of Flutter and Android Gradle Plugins require a specific JDK (Java Development Kit) version to function correctly. This is often an issue when the environment drops back to an outdated Java 1.8 version or is pushed to a too-new Java 21 version while Gradle expects Java 17.
**Fix:** 
1. Ensure that you have **Java 17 (JDK 17)** installed on your machine.
2. Update your local environment variables (`JAVA_HOME`) to point to the JDK 17 folder.
3. Alternatively, explicitly define the Java home for Gradle by adding this line to your `android/gradle.properties`:
   ```properties
   org.gradle.java.home=C:\\Program Files\\Java\\jdk-17...
   ```
   *(Be sure to replace the path with your actual JDK path)*

### 2. Layout Overflowed: "RIGHT OVERFLOWED BY X PIXELS" (Hazard Tape)
**Problem:** In UI rows or cards, a yellow-and-black hazard striped bar occasionally appears on the edge of the screen, warning that content has overflowed.
**Cause:** This happens when widgets inside a `Row` attempt to take up more horizontal space than the screen provides. Often, it's caused by text strings (e.g., long subject titles or long question answers) or unconstrained dropdown menus inside flex layouts. Note that `Text` widgets inside a `Row` do *not* automatically line-wrap unless constrained.
**Fix:** 
To prevent this, ensure that rows with dynamic content are constrained.
1. Add `isExpanded: true` to `DropdownButtonFormField` so the widget forces its list items to respect parent constraints.
2. Wrap nested `Row` widgets in an `Expanded` widget so it claims only the remaining space.
3. If the overflow is caused by a long text string that can be visually truncated, wrap the text container in a `Flexible` widget and apply `overflow: TextOverflow.ellipsis` to the `Text` widget.
4. **Text inside a Row that needs to line-wrap:** Wrap the `Text` widget in an `Expanded` widget. This constrains its width and forces it to wrap to the next line instead of infinitely expanding horizontally out of bounds.

### 3. State/UI Not Updating Immediately
**Problem:** After fetching data from the local database or triggering an asynchronous save, the screen doesn't immediately reflect the changes.
**Cause:** The application relies heavily on `StatefulWidget`s. When data resolves after an `await` call, `setState` might be called incorrectly or an exception might be thrown if the widget was unmounted while waiting.
**Fix:**
Always verify that the widget hasn't been destroyed before calling `setState` after an asynchronous gap:
```dart
await _service.saveData();
if (!mounted) return;
setState(() {
  // Update state variables here
});
```

---

## Important Flutter Terminal Commands

Here is a list of essential terminal commands to navigate, maintain, and build the application:

### Project Maintenance
- **`flutter clean`**  
  Deletes the build folder and clears out all cached generated files. Run this command when the project starts behaving unpredictably or if you are changing core plugin versions.
  
- **`flutter pub get`**  
  Downloads and updates all package dependencies defined in your `pubspec.yaml` file. Always run this directly after running `flutter clean` or after cloning the repository.

- **`flutter analyze`**  
  Analyzes the Dart code to identify syntax errors, missing constraints, or deprecated code usages. It is highly recommended to run this before pushing any commits to ensure code quality.

### Running & Building
- **`flutter run`**  
  Launches the app in debug mode on the connected device or emulator. It supports "Hot Reload" (press `r` in the terminal) to instantly push UI changes to the app without restarting.

- **`flutter build apk --release`**  
  Compiles the application into a production-ready `.apk` file located at `build/app/outputs/flutter-apk/app-release.apk`. Use this when you are ready to distribute the app to users.

- **`flutter doctor`**  
  Diagnoses your system configuration. If you encounter strange build errors, running this command will check your Flutter SDK, Android Studio tools, and connected devices to identify what is missing or misconfigured.
