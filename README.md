# FinTrack - Personal Finance Management App

## 📱 Description

FinTrack is a personal finance management application developed with Flutter, helping users track income and expenses, manage accounting books, set savings goals, and analyze spending effectively.

## ✨ Key Features

### 💰 Book Management
- Create and manage multiple accounting books
- Track balance for each book
- Easy switching between books

### 📊 Charts and Statistics
- Pie charts showing expense distribution by category
- Bar charts tracking income and expenses over time
- Overview statistics of financial situation

### 💳 Transaction Management
- Add, edit, and delete transactions
- Categorize transactions by category
- Detailed notes for each transaction
- Transaction history by time

### 🎯 Savings Goals
- **Flexible Savings**: Set savings goals with custom amounts
- **Periodic Savings**: Automatically save according to cycle (daily/weekly/monthly)
- Track goal completion progress
- Notifications when goals are achieved

### 🔔 Notifications and Reminders
- Notifications for recurring bills
- Savings goal reminders
- Push notifications for important events

### 🌍 Multi-language Support
- Support for Vietnamese and English
- Easy language switching

### 🎨 User Interface
- Material Design 3
- Responsive design for multiple screen sizes
- Dark/Light theme
- User-friendly and easy-to-use interface

## 🛠️ Technologies Used

- **Framework**: Flutter 3.2.3+
- **State Management**: Riverpod
- **Database**: SQLite (sqflite)
- **Localization**: flutter_localizations
- **Charts**: fl_chart
- **Notifications**: flutter_local_notifications
- **Background Tasks**: workmanager
- **UI Components**: Material Design 3, Google Fonts
- **Responsive Design**: flutter_screenutil

## 📋 System Requirements

- Flutter SDK 3.2.3 or higher
- Dart 3.2.3 or higher
- Android SDK 21+ (Android 5.0+)
- iOS 11.0+
- Xcode 12.0+ (for iOS development)

## 🚀 Installation and Setup

### 1. Clone repository
```bash
git clone https://github.com/your-username/fintrack.git
cd fintrack
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run the application
```bash
# Run on connected device
flutter run

# Or build for Android
flutter build apk

# Or build for iOS
flutter build ios
```

### 4. Generate code (if needed)
```bash
# Generate Riverpod code
flutter packages pub run build_runner build
```

## 📁 Project Structure

```
lib/
├── data/
│   ├── config/           # Application configuration
│   ├── database/         # Database helper and migrations
│   ├── models/           # Data models
│   │   ├── book.dart     # Book model
│   │   ├── transaction.dart # Transaction model
│   │   ├── savings_goal.dart # Savings goal model
│   │   └── ...
│   └── repositories/     # Data access layer
├── providers/            # Riverpod providers
├── services/             # Business logic services
├── ui/                   # User interface
│   ├── books.dart        # Books screen
│   ├── charts.dart       # Charts screen
│   ├── extra_features_screen.dart # Additional features
│   ├── more.dart         # Settings screen
│   └── widget/           # Reusable widgets
├── utils/                # Utility functions
└── l10n/                 # Localization files
```

## 🎯 How to Use

### Create a new book
1. Open the app and select the "Books" tab
2. Press the "+" button to create a new book
3. Enter the book name and initial balance
4. Press "Save" to complete

### Add a transaction
1. Select the book you want to add a transaction to
2. Press the "+" button to add a new transaction
3. Choose transaction type (Income/Expense)
4. Enter amount and notes
5. Select appropriate category
6. Press "Save" to complete

### Set up savings goals
1. Select the "Additional Features" tab
2. Choose "Savings Goals"
3. Select savings type (Flexible/Periodic)
4. Enter goal information
5. Press "Create" to complete

## 🔧 Configuration

### Splash Screen Configuration
Splash screen is configured in `pubspec.yaml`:
```yaml
flutter_native_splash:
  color: "#ffffff"
  image: assets/images/Fintrack.png
  android: true
  ios: true
```

### App Icon Configuration
App icon is configured in `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/icon_white_final.png"
```

## 🤝 Contributing

We welcome all contributions! Please:

1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is distributed under the MIT License. See the `LICENSE` file for more details.

## 👥 Authors

- **Nguyễn Ngọc Tuấn** - *Leader and Fullstack Developer* - [DanhCaTuanNgoc](https://github.com/DanhCaTuanNgoc)
- **Đặng Thế Vinh** - *Backend Developer* - [capijim](https://github.com/capijim)
- **Thạch Bảo** - *Frontend Developer* - [ThachBao](https://github.com/ThachBao)

## 📞 Contact

- Email: your.email@example.com
- GitHub: [DanhCaTuanNgoc](https://github.com/DanhCaTuanNgoc)
- Gmail: [ngoctuan090904@gmail.com]
- LinkedIn: [Nguyễn Ngọc Tuấn](https://www.linkedin.com/in/tu%E1%BA%A5n-nguyen-b7a49934a/)

---

<div align="center">
  <p>Made with ❤️ by Flutter developers</p>
  <p>⭐ Star this repository if you find it helpful!</p>
</div> 