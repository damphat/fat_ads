# FatAds

FatAds is a Flutter package designed to make integrating Ads into your app easier.
Currently, the package supports only AppOpen Ads.

## Key features

- Include a command line tool that allows you to update `AndroidManifest.xml` and `Info.plist` files.
- For safety, it always uses the testing unit IDs in debug mode.
- For easy cross-platform, we use silent failure instead of throwing exceptions on unsupported platforms.
- For better readability, all parameters have default values.
- Support Android/iOS

## Usage

To add or update your `AdMob App ID` into `AndroidManifest.xml` and `Info.plist` files. Run the following command:

```bash
flutter pub run fat_ads
```

### To display AppOpen Ads

```dart
void main() async {
    // This is an async function that returns when an Ads either is loaded or is
    // unable to load within the specified timeout.
    // To prevent Ads from suddenly appearing on your UI, make sure to call this
    // function before `runApp()` and don't forget to use the `await` keyword.
    await appOpenAds(
        // iosUnitId: "<ios ad unit id>",
        // androidUnitId: "<android ad unit id>",
        // loadingTimeout: Duration(seconds: 3),
    );

    runApp(...)
}
```
