# FinTrack - Ứng dụng Quản lý Tài chính Cá nhân
## 📱 Mô tả

FinTrack là một ứng dụng quản lý tài chính cá nhân được phát triển bằng Flutter, giúp người dùng theo dõi thu chi, quản lý sổ sách kế toán, thiết lập mục tiêu tiết kiệm và phân tích chi tiêu một cách hiệu quả.

## ✨ Tính năng chính

### 💰 Quản lý Sổ sách (Books)
- Tạo và quản lý nhiều sổ sách kế toán
- Theo dõi số dư cho từng sổ sách
- Chuyển đổi giữa các sổ sách dễ dàng

### 📊 Biểu đồ và Thống kê (Charts)
- Biểu đồ tròn thể hiện phân bổ chi tiêu theo danh mục
- Biểu đồ cột theo dõi thu chi theo thời gian
- Thống kê tổng quan về tình hình tài chính

### 💳 Quản lý Giao dịch
- Thêm, chỉnh sửa và xóa giao dịch
- Phân loại giao dịch theo danh mục
- Ghi chú chi tiết cho từng giao dịch
- Lịch sử giao dịch theo thời gian

### 🎯 Mục tiêu Tiết kiệm
- **Tiết kiệm Linh hoạt**: Thiết lập mục tiêu tiết kiệm với số tiền tùy chọn
- **Tiết kiệm Định kỳ**: Tự động tiết kiệm theo chu kỳ (ngày/tuần/tháng)
- Theo dõi tiến độ hoàn thành mục tiêu
- Thông báo khi đạt mục tiêu

### 🔔 Thông báo và Nhắc nhở
- Thông báo cho hóa đơn định kỳ
- Nhắc nhở mục tiêu tiết kiệm
- Thông báo đẩy cho các sự kiện quan trọng

### 🌍 Đa ngôn ngữ
- Hỗ trợ tiếng Việt và tiếng Anh
- Chuyển đổi ngôn ngữ dễ dàng

### 🎨 Giao diện người dùng
- Thiết kế Material Design 3
- Responsive design cho nhiều kích thước màn hình
- Dark/Light theme
- Giao diện thân thiện và dễ sử dụng

## 🛠️ Công nghệ sử dụng

- **Framework**: Flutter 3.2.3+
- **State Management**: Riverpod
- **Database**: SQLite (sqflite)
- **Localization**: flutter_localizations
- **Charts**: fl_chart
- **Notifications**: flutter_local_notifications
- **Background Tasks**: workmanager
- **UI Components**: Material Design 3, Google Fonts
- **Responsive Design**: flutter_screenutil

## 📋 Yêu cầu hệ thống

- Flutter SDK 3.2.3 trở lên
- Dart 3.2.3 trở lên
- Android SDK 21+ (Android 5.0+)
- iOS 11.0+
- Xcode 12.0+ (cho iOS development)

## 🚀 Cài đặt và Chạy

### 1. Clone repository
```bash
git clone https://github.com/your-username/fintrack.git
cd fintrack
```

### 2. Cài đặt dependencies
```bash
flutter pub get
```

### 3. Chạy ứng dụng
```bash
# Chạy trên thiết bị được kết nối
flutter run

# Hoặc build cho Android
flutter build apk

# Hoặc build cho iOS
flutter build ios
```

### 4. Generate code (nếu cần)
```bash
# Generate Riverpod code
flutter packages pub run build_runner build
```

## 📁 Cấu trúc dự án

```
lib/
├── data/
│   ├── config/           # Cấu hình ứng dụng
│   ├── database/         # Database helper và migrations
│   ├── models/           # Data models
│   │   ├── book.dart     # Model sổ sách
│   │   ├── transaction.dart # Model giao dịch
│   │   ├── savings_goal.dart # Model mục tiêu tiết kiệm
│   │   └── ...
│   └── repositories/     # Data access layer
├── providers/            # Riverpod providers
├── services/             # Business logic services
├── ui/                   # User interface
│   ├── books.dart        # Màn hình sổ sách
│   ├── charts.dart       # Màn hình biểu đồ
│   ├── extra_features_screen.dart # Tính năng bổ sung
│   ├── more.dart         # Màn hình cài đặt
│   └── widget/           # Reusable widgets
├── utils/                # Utility functions
└── l10n/                 # Localization files
```

## 🎯 Cách sử dụng

### Tạo sổ sách mới
1. Mở ứng dụng và chọn tab "Sổ sách"
2. Nhấn nút "+" để tạo sổ sách mới
3. Nhập tên sổ sách và số dư ban đầu
4. Nhấn "Lưu" để hoàn tất

### Thêm giao dịch
1. Chọn sổ sách muốn thêm giao dịch
2. Nhấn nút "+" để thêm giao dịch mới
3. Chọn loại giao dịch (Thu/Chi)
4. Nhập số tiền và ghi chú
5. Chọn danh mục phù hợp
6. Nhấn "Lưu" để hoàn tất

### Thiết lập mục tiêu tiết kiệm
1. Chọn tab "Tính năng bổ sung"
2. Chọn "Mục tiêu tiết kiệm"
3. Chọn loại tiết kiệm (Linh hoạt/Định kỳ)
4. Nhập thông tin mục tiêu
5. Nhấn "Tạo" để hoàn tất

## 🔧 Cấu hình

### Cấu hình Splash Screen
Splash screen được cấu hình trong `pubspec.yaml`:
```yaml
flutter_native_splash:
  color: "#ffffff"
  image: assets/images/Fintrack.png
  android: true
  ios: true
```

### Cấu hình App Icon
App icon được cấu hình trong `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/icon_white_final.png"
```

## 🤝 Đóng góp

Chúng tôi rất hoan nghênh mọi đóng góp! Vui lòng:

1. Fork dự án
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit thay đổi (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Mở Pull Request

## 📄 Giấy phép

Dự án này được phân phối dưới giấy phép MIT. Xem file `LICENSE` để biết thêm chi tiết.

## 👥 Tác giả

- **Your Name** - *Initial work* - [YourGitHub](https://github.com/your-username)

## 🙏 Lời cảm ơn

- Flutter team cho framework tuyệt vời
- Cộng đồng Flutter Việt Nam
- Tất cả contributors đã đóng góp cho dự án

## 📞 Liên hệ

- Email: your.email@example.com
- GitHub: [@your-username](https://github.com/your-username)
- LinkedIn: [Your Name](https://linkedin.com/in/your-profile)

---

<div align="center">
  <p>Made with ❤️ by Flutter developers</p>
  <p>⭐ Star this repository if you find it helpful!</p>
</div> 