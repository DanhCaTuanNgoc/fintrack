# Cài đặt Thông báo

## Để đảm bảo thông báo hiển thị trên điện thoại:

### 1. Cấp quyền thông báo
- Khi app khởi động lần đầu, chấp nhận yêu cầu quyền thông báo
- Hoặc vào Settings > Apps > Fintrack > Notifications > Allow

### 2. Tắt chế độ tiết kiệm pin
- Vào Settings > Battery > Battery optimization
- Tìm Fintrack và chọn "Don't optimize"

### 3. Tắt chế độ Do Not Disturb
- Đảm bảo không bật chế độ "Do Not Disturb" khi test

### 4. Test thông báo
- Tạo hóa đơn định kỳ với ngày hôm nay
- Đợi 10 giây (background service chạy mỗi 10 giây)
- Thông báo sẽ xuất hiện với âm thanh và rung

### 5. Kiểm tra log
- Mở Developer Tools
- Tìm log: "✅ Background service: Đã tạo X thông báo thành công"

## Cấu hình đã được thêm:
- ✅ Quyền POST_NOTIFICATIONS và VIBRATE
- ✅ Notification channel với importance.max
- ✅ Cấu hình đầy đủ: sound, vibration, lights, LED
- ✅ Yêu cầu quyền tự động khi khởi động app
- ✅ Background service chạy mỗi 10 giây 