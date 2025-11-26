# Setup Guide - MindWell App

## Quick Start

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Add Fonts (Required)**
   - Download fonts from Google Fonts:
     - Inter: https://fonts.google.com/specimen/Inter
     - Poppins: https://fonts.google.com/specimen/Poppins
     - Nunito: https://fonts.google.com/specimen/Nunito
   - Extract and place the following files in `assets/fonts/`:
     - Inter-Regular.ttf, Inter-Medium.ttf, Inter-SemiBold.ttf, Inter-Bold.ttf
     - Poppins-Regular.ttf, Poppins-Medium.ttf, Poppins-SemiBold.ttf, Poppins-Bold.ttf
     - Nunito-Regular.ttf, Nunito-SemiBold.ttf, Nunito-Bold.ttf

3. **Run the App**
   ```bash
   flutter run
   ```

## Optional Assets

### Lottie Animations
- Download Lottie JSON files from https://lottiefiles.com
- Place in `assets/lottie/`
- Recommended: mood animations, breathing animations, loading indicators

### 3D Avatars
- Download 3D models from Rive, Spline, or ReadyPlayerMe
- Export as `.glb` format
- Place in `assets/models/`

### Audio Files
- Add meditation/relaxation audio files (MP3 format)
- Place in `assets/audio/`
- Update `lib/features/meditation/screens/meditation_screen.dart` to uncomment audio code

### Images
- Add counselor profile images
- Place in `assets/images/counselors/`
- Update counselor data with actual image paths

## Platform-Specific Setup

### Android
No additional setup required. The app is ready to run on Android.

### Web
For web deployment:
```bash
flutter build web
```

The UI is responsive and will adapt to different screen sizes.

## Testing the App

1. **First Launch**: You'll see the onboarding flow
2. **Complete Onboarding**: Enter your name to proceed
3. **Home Screen**: Explore mood tracking, quick actions, and features
4. **Navigation**: Use the bottom navigation bar to switch between screens

## Common Issues

### Fonts Not Loading
- Ensure all font files are in `assets/fonts/`
- Run `flutter clean` and `flutter pub get`
- Restart the app

### Missing Assets
- The app will work with placeholder icons/animations
- Add assets as described above for full experience

### Build Errors
- Run `flutter clean`
- Run `flutter pub get`
- Ensure Flutter SDK is 3.8.1 or higher

## Next Steps

1. Add your fonts (required)
2. Test all features
3. Add optional assets for enhanced experience
4. Update counselor data with real information
5. Add actual booking URLs for Marham/Oladoc
6. Configure notification permissions

## Integration Points

### External Services (TODO)
- **Marham URLs**: Update in `lib/data/dummy/counselors_data.dart`
- **Oladoc URLs**: Update in `lib/data/dummy/counselors_data.dart`
- **WhatsApp Numbers**: Update counselor phone numbers

### Backend Integration (Future)
When ready to integrate with backend:
1. Add `http` package (already in pubspec.yaml as comment)
2. Create API service in `lib/services/api/`
3. Replace dummy data with API calls
4. Add authentication if needed

## Support

For issues, check:
- README.md in root directory
- README.md files in asset directories
- TODO comments in code

---

**Happy Coding! 🚀**

