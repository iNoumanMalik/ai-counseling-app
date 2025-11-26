# MindWell - Mental Wellness App

A beautiful Flutter mobile app focused on mental wellness, self-help tools, daily motivation, and referencing external counselors.

## 🎯 Features

- **Onboarding Flow**: Beautiful animated introduction screens
- **Home Dashboard**: Personalized greeting, mood selector, and quick actions
- **Mood Tracking**: Track your daily mood with visual feedback
- **Journal**: Write and save your thoughts locally
- **Breathing Exercises**: Guided breathing exercises with animations
- **Habit Tracking**: Daily habits with streaks and badges
- **Counselor Discovery**: Browse counselors by category and connect via external platforms
- **Meditation Library**: Audio meditation tracks (placeholder for now)
- **CBT Worksheets**: Self-help worksheets and exercises
- **Crisis Support**: Emergency numbers and resources
- **Profile**: View your progress and statistics

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK 3.8.1 or higher
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository** (or navigate to project directory)

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Add Fonts**:
   - Download Inter, Poppins, and Nunito fonts from [Google Fonts](https://fonts.google.com)
   - Place them in `assets/fonts/` directory
   - See `assets/fonts/README.md` for details

4. **Add Assets** (Optional - app works with placeholders):
   - Add Lottie animations to `assets/lottie/`
   - Add 3D models to `assets/models/`
   - Add audio files to `assets/audio/`
   - Add images to `assets/images/`
   - See respective README files in each directory

5. **Run the app**:
   ```bash
   flutter run
   ```

## 📱 Target Platforms

- ✅ Android
- ✅ Web (responsive UI)

## 🏗️ Project Structure

```
lib/
├── config/           # Theme, colors, strings
├── core/             # Utilities, widgets, navigation
│   ├── navigation/   # Routing configuration
│   ├── utils/        # Storage service, helpers
│   └── widgets/      # Reusable widgets
├── data/             # Models and dummy data
│   ├── models/       # Data models
│   └── dummy/        # Placeholder data
└── features/         # Feature modules
    ├── onboarding/   # Onboarding screens
    ├── home/         # Home dashboard
    ├── discovery/    # Counselor discovery
    ├── breathing/    # Breathing exercises
    ├── journal/      # Journaling feature
    ├── habits/       # Habit tracking
    ├── meditation/   # Meditation library
    ├── worksheets/   # CBT worksheets
    ├── profile/      # User profile
    └── crisis/       # Crisis support
```

## 🎨 Design

- **Color Palette**: Calming pastels (Purple, Mint, Peach)
- **Fonts**: Inter (body), Poppins (headings), Nunito (mood icons)
- **Style**: Soft gradients, rounded corners, smooth animations

## 🔧 Technologies Used

- **State Management**: Riverpod
- **Navigation**: go_router
- **Storage**: SharedPreferences
- **Animations**: flutter_animate, Lottie, Rive
- **Charts**: fl_chart
- **3D Models**: model_viewer_plus
- **Audio**: audioplayers
- **Notifications**: flutter_local_notifications

## 📝 TODO / Placeholders

The following features have placeholder implementations that need integration:

1. **External APIs**: Counselor data is currently dummy data. Replace with real API integration.
2. **Marham/Oladoc URLs**: Update with actual booking URLs.
3. **WhatsApp Integration**: Update with real counselor phone numbers.
4. **Audio Files**: Add meditation audio files to `assets/audio/`.
5. **Lottie Animations**: Add Lottie files to `assets/lottie/`.
6. **3D Avatars**: Add 3D model files to `assets/models/`.
7. **Fonts**: Add font files to `assets/fonts/`.
8. **Images**: Add counselor profile images.
9. **Notifications**: Complete notification setup for reminders.
10. **Mood Graphs**: Implement 7-day and 30-day mood tracking charts.

## 🔐 Privacy & Data

- **No Backend**: All data is stored locally using SharedPreferences
- **No Authentication**: User data is stored on device only
- **No Server-Side Storage**: No sensitive data is sent to servers

## 📄 License

This project is for educational purposes.

## 🤝 Contributing

This is a semester project. For improvements:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## ⚠️ Important Notes

- **Not for Medical Emergencies**: This app is not a substitute for professional medical care
- **Crisis Support**: Always contact emergency services for immediate help
- **Counselor Booking**: All bookings are handled through external platforms (Marham, Oladoc)
- **No Internal Scheduling**: The app does not handle scheduling internally

## 🐛 Known Issues

- Font files need to be added manually
- Some animations use emoji placeholders instead of Lottie files
- Audio player needs actual audio files
- Mood graphs not yet implemented

## 📞 Support

For issues or questions, please check the TODO comments in the code or refer to the README files in asset directories.

---

**Built with ❤️ using Flutter**
