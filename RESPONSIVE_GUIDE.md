# Hướng dẫn Responsive Design cho Fintrack App

## Tổng quan

Hệ thống responsive design được thiết kế để đảm bảo app Fintrack hiển thị tốt trên mọi kích thước màn hình từ điện thoại nhỏ đến tablet và desktop.

## Breakpoints

- **Mobile**: < 600px
- **Tablet**: 600px - 900px  
- **Desktop**: > 900px

## Cách sử dụng

### 1. Import các utility classes

```dart
import '../utils/responsive_utils.dart';
import '../utils/responsive_widgets.dart';
```

### 2. Sử dụng ResponsiveUtils

#### Kiểm tra kích thước màn hình
```dart
if (context.isMobile) {
  // Code cho mobile
} else if (context.isTablet) {
  // Code cho tablet
} else {
  // Code cho desktop
}
```

#### Lấy kích thước responsive
```dart
// Font size
final fontSize = ResponsiveUtils.getFontSize(
  context,
  mobile: 14.0,
  tablet: 16.0,
  desktop: 18.0,
);

// Icon size
final iconSize = ResponsiveUtils.getIconSize(
  context,
  mobile: 24.0,
  tablet: 28.0,
  desktop: 32.0,
);

// Spacing
final spacing = ResponsiveUtils.getSpacing(
  context,
  mobile: 8.0,
  tablet: 12.0,
  desktop: 16.0,
);
```

### 3. Sử dụng Responsive Widgets

#### ResponsiveText
```dart
ResponsiveText(
  'Hello World',
  mobileFontSize: 16,
  tabletFontSize: 18,
  desktopFontSize: 20,
  style: TextStyle(fontWeight: FontWeight.bold),
)
```

#### ResponsiveIcon
```dart
ResponsiveIcon(
  Icons.home,
  mobileSize: 24,
  tabletSize: 28,
  desktopSize: 32,
  color: Colors.blue,
)
```

#### ResponsiveButton
```dart
ResponsiveButton(
  'Click me',
  onPressed: () {},
  backgroundColor: Colors.blue,
  textColor: Colors.white,
  mobileFontSize: 14,
  tabletFontSize: 16,
  desktopFontSize: 18,
)
```

#### ResponsiveContainer
```dart
ResponsiveContainer(
  padding: EdgeInsets.all(16),
  child: Text('Content'),
)
```

#### ResponsiveCard
```dart
ResponsiveCard(
  child: Column(
    children: [
      Text('Card content'),
    ],
  ),
)
```

#### ResponsiveGridView
```dart
ResponsiveGridView(
  children: [
    // Your grid items
  ],
  mobileColumns: 2,
  tabletColumns: 3,
  desktopColumns: 4,
)
```

### 4. Extension Methods

Sử dụng extension methods để code ngắn gọn hơn:

```dart
// Thay vì ResponsiveUtils.isMobile(context)
if (context.isMobile) {
  // Code
}

// Thay vì ResponsiveUtils.screenWidth(context)
final width = context.screenWidth;

// Thay vì ResponsiveUtils.screenPadding(context)
final padding = context.screenPadding;
```

## Responsive Spacing, Padding & Layout

### 1. Responsive Spacing

```dart
// Spacing giữa các elements
ResponsiveColumn(
  spacing: ResponsiveUtils.getSpacing(
    context,
    mobile: 8,
    tablet: 12,
    desktop: 16,
  ),
  children: [
    Widget1(),
    Widget2(),
    Widget3(),
  ],
)

// Hoặc sử dụng ResponsiveRow
ResponsiveRow(
  spacing: ResponsiveUtils.getSpacing(
    context,
    mobile: 8,
    tablet: 12,
    desktop: 16,
  ),
  children: [
    Widget1(),
    Widget2(),
  ],
)
```

### 2. Responsive Padding & Margin

```dart
Container(
  // Responsive padding
  padding: EdgeInsets.all(ResponsiveUtils.getSpacing(
    context,
    mobile: 8,
    tablet: 12,
    desktop: 16,
  )),
  
  // Responsive margin
  margin: EdgeInsets.symmetric(
    horizontal: ResponsiveUtils.getSpacing(
      context,
      mobile: 4,
      tablet: 6,
      desktop: 8,
    ),
    vertical: ResponsiveUtils.getSpacing(
      context,
      mobile: 2,
      tablet: 4,
      desktop: 6,
    ),
  ),
  
  child: YourWidget(),
)
```

### 3. Responsive Layout Patterns

#### Conditional Layout
```dart
Widget build(BuildContext context) {
  return context.isMobile 
    ? _buildMobileLayout()
    : _buildTabletLayout();
}
```

#### Responsive Grid
```dart
ResponsiveGridView(
  children: items.map((item) => ItemWidget(item)).toList(),
  mobileColumns: 2,
  tabletColumns: 3,
  desktopColumns: 4,
  crossAxisSpacing: ResponsiveUtils.getSpacing(context),
  mainAxisSpacing: ResponsiveUtils.getSpacing(context),
)
```

#### Responsive Row/Column Switch
```dart
// Tự động chuyển từ Row sang Column trên mobile
context.isMobile 
  ? ResponsiveColumn(
      children: widgets,
      spacing: ResponsiveUtils.getSpacing(context),
    )
  : ResponsiveRow(
      children: widgets,
      spacing: ResponsiveUtils.getSpacing(context),
    )
```

### 4. Responsive Container với Decoration

```dart
Container(
  padding: EdgeInsets.all(ResponsiveUtils.getSpacing(
    context,
    mobile: 8,
    tablet: 12,
    desktop: 16,
  )),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(
      context,
      mobile: 8,
      tablet: 12,
      desktop: 16,
    )),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        blurRadius: ResponsiveUtils.getSpacing(
          context,
          mobile: 4,
          tablet: 6,
          desktop: 8,
        ),
        offset: Offset(
          0,
          ResponsiveUtils.getSpacing(
            context,
            mobile: 2,
            tablet: 3,
            desktop: 4,
          ),
        ),
      ),
    ],
  ),
  child: YourWidget(),
)
```

## Best Practices

### 1. Layout Responsive

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: context.isMobile 
      ? _buildMobileLayout()
      : _buildTabletLayout(),
  );
}
```

### 2. Grid Layout

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: ResponsiveUtils.getGridColumns(context),
    childAspectRatio: ResponsiveUtils.getAspectRatio(context),
  ),
  itemBuilder: (context, index) => YourWidget(),
)
```

### 3. Text Responsive

```dart
Text(
  'Your text',
  style: TextStyle(
    fontSize: ResponsiveUtils.getFontSize(
      context,
      mobile: 14,
      tablet: 16,
      desktop: 18,
    ),
  ),
)
```

### 4. Padding và Margin

```dart
Container(
  padding: ResponsiveUtils.screenPadding(context),
  margin: ResponsiveUtils.horizontalPadding(context),
  child: YourWidget(),
)
```

### 5. Spacing và Layout

```dart
// Sử dụng ResponsiveColumn/Row thay vì Column/Row thường
ResponsiveColumn(
  spacing: ResponsiveUtils.getSpacing(context),
  children: [
    Widget1(),
    Widget2(),
    Widget3(),
  ],
)

// Responsive spacing trong SizedBox
SizedBox(
  height: ResponsiveUtils.getSpacing(
    context,
    mobile: 8,
    tablet: 12,
    desktop: 16,
  ),
)
```

## Ví dụ thực tế

### AppBar Responsive
```dart
AppBar(
  toolbarHeight: ResponsiveUtils.getSpacing(
    context, 
    mobile: 60, 
    tablet: 70, 
    desktop: 80
  ),
  title: ResponsiveText(
    'Title',
    mobileFontSize: 18,
    tabletFontSize: 20,
    desktopFontSize: 24,
  ),
)
```

### Bottom Navigation Responsive
```dart
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(
      icon: ResponsiveIcon(
        Icons.home,
        mobileSize: 20,
        tabletSize: 24,
        desktopSize: 28,
      ),
      label: 'Home',
    ),
  ],
  selectedLabelStyle: TextStyle(
    fontSize: ResponsiveUtils.getFontSize(
      context,
      mobile: 12,
      tablet: 14,
      desktop: 16,
    ),
  ),
)
```

### StatItem Responsive (Ví dụ hoàn chỉnh)
```dart
class StatItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Responsive padding
      padding: EdgeInsets.all(ResponsiveUtils.getSpacing(
        context,
        mobile: 8,
        tablet: 12,
        desktop: 16,
      )),
      
      // Responsive margin
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getSpacing(
          context,
          mobile: 4,
          tablet: 6,
          desktop: 8,
        ),
      ),
      
      // Responsive decoration
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(
          context,
          mobile: 8,
          tablet: 12,
          desktop: 16,
        )),
      ),
      
      child: ResponsiveColumn(
        // Responsive spacing giữa elements
        spacing: ResponsiveUtils.getSpacing(
          context,
          mobile: 4,
          tablet: 6,
          desktop: 8,
        ),
        children: [
          ResponsiveText(
            'Amount',
            mobileFontSize: 16,
            tabletFontSize: 18,
            desktopFontSize: 20,
          ),
          ResponsiveText(
            'Title',
            mobileFontSize: 12,
            tabletFontSize: 14,
            desktopFontSize: 16,
          ),
        ],
      ),
    );
  }
}
```

## Testing

### 1. Test trên các kích thước màn hình khác nhau
- iPhone SE (375x667)
- iPhone 12 (390x844)
- iPad (768x1024)
- Desktop (1920x1080)

### 2. Test orientation
- Portrait mode
- Landscape mode

### 3. Test text scaling
- Font size accessibility settings

## Lưu ý quan trọng

1. **Luôn sử dụng ResponsiveUtils** thay vì hardcode kích thước
2. **Test trên nhiều thiết bị** để đảm bảo UI nhất quán
3. **Sử dụng Flexible và Expanded** cho layout linh hoạt
4. **Tránh hardcode width/height** khi có thể
5. **Sử dụng MediaQuery** một cách thông minh
6. **Sử dụng ResponsiveColumn/Row** thay vì Column/Row thường
7. **Responsive spacing** cho tất cả khoảng cách
8. **Responsive padding/margin** cho tất cả container

## Troubleshooting

### Vấn đề thường gặp

1. **Text bị tràn**: Sử dụng `TextOverflow.ellipsis` và `maxLines`
2. **Layout bị vỡ**: Sử dụng `Flexible` và `Expanded`
3. **Icon quá lớn/nhỏ**: Điều chỉnh `ResponsiveUtils.getIconSize()`
4. **Spacing không đều**: Sử dụng `ResponsiveUtils.getSpacing()`
5. **Padding quá lớn/nhỏ**: Điều chỉnh responsive padding
6. **Layout không responsive**: Sử dụng conditional layout

### Debug

```dart
// In ra kích thước màn hình để debug
print('Screen size: ${context.screenSize}');
print('Is mobile: ${context.isMobile}');
print('Is tablet: ${context.isTablet}');
print('Is desktop: ${context.isDesktop}');

// In ra spacing để debug
print('Current spacing: ${ResponsiveUtils.getSpacing(context)}');
print('Current padding: ${ResponsiveUtils.screenPadding(context)}');
```

# Hướng dẫn sử dụng Flutter ScreenUtil cho Responsive Design

## Cài đặt và cấu hình

### 1. Thêm dependency vào pubspec.yaml
```yaml
dependencies:
  flutter_screenutil: ^5.8.4
```

### 2. Cấu hình trong main.dart
```dart
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Trong MyApp widget
@override
Widget build(BuildContext context) {
  return ScreenUtilInit(
    designSize: const Size(375, 812), // iPhone X design size
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, child) {
      return MaterialApp(
        // ... your app configuration
      );
    },
  );
}
```

## Cách sử dụng

### 1. Kích thước màn hình
- `.w` - Chiều rộng (width)
- `.h` - Chiều cao (height)
- `.r` - Bán kính (radius)
- `.sp` - Font size (text scale factor)

### 2. Ví dụ sử dụng

#### Trước khi sử dụng ScreenUtil:
```dart
Container(
  width: 100,
  height: 50,
  padding: EdgeInsets.all(16),
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16),
  ),
)
```

#### Sau khi sử dụng ScreenUtil:
```dart
Container(
  width: 100.w,
  height: 50.h,
  padding: EdgeInsets.all(16.w),
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16.sp),
  ),
)
```

### 3. Các extension methods

#### Kích thước:
- `100.w` - 100% của chiều rộng thiết kế
- `50.h` - 50% của chiều cao thiết kế
- `20.r` - 20% của bán kính thiết kế

#### Font size:
- `16.sp` - Font size 16 với text scale factor
- `20.sp` - Font size 20 với text scale factor

#### Media query:
- `ScreenUtil().screenWidth` - Chiều rộng màn hình thực tế
- `ScreenUtil().screenHeight` - Chiều cao màn hình thực tế
- `ScreenUtil().statusBarHeight` - Chiều cao status bar

### 4. Lưu ý quan trọng

#### Không sử dụng const với ScreenUtil:
```dart
// ❌ Sai
const Text(
  'Hello',
  style: TextStyle(fontSize: 16.sp), // Lỗi!
)

// ✅ Đúng
Text(
  'Hello',
  style: TextStyle(fontSize: 16.sp),
)
```

#### Sử dụng đúng extension:
```dart
// ✅ Đúng
Container(
  width: 100.w,
  height: 50.h,
  padding: EdgeInsets.all(16.w),
  margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12.r),
  ),
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16.sp),
  ),
)
```

## Design Size

Trong dự án này, chúng ta sử dụng design size là `Size(410, 840)` (Samsung A30):
- Chiều rộng thiết kế: 410px
- Chiều cao thiết kế: 840px

### Tại sao chọn Samsung A30 làm chuẩn?

1. **Thiết bị phát triển chính**: Đây là thiết bị bạn đang sử dụng để phát triển và test
2. **Kích thước phổ biến**: Samsung A30 có kích thước màn hình phổ biến trong phân khúc Android
3. **Tỷ lệ khung hình cân bằng**: 410x840 tạo ra tỷ lệ khung hình đẹp (≈19.5:9)
4. **Tương thích tốt**: Dễ dàng scale lên/xuống cho các thiết bị khác

### Cách hoạt động của designSize:

```dart
// Trên Samsung A30 (410x840) - thiết bị chuẩn:
100.w = 410px
100.h = 840px
50.w = 205px
50.h = 420px

// Trên iPhone X (375x812):
100.w = 375px (tự động scale từ 410px)
100.h = 812px (tự động scale từ 840px)
50.w = 187.5px
50.h = 406px

// Trên iPhone 12 Pro (390x844):
100.w = 390px (tự động scale từ 410px)
100.h = 844px (tự động scale từ 840px)
50.w = 195px
50.h = 422px

// Trên Samsung Galaxy S21 (360x800):
100.w = 360px (tự động scale từ 410px)
100.h = 800px (tự động scale từ 840px)
50.w = 180px
50.h = 400px
```

### Công thức tính toán:

```dart
// Scale factor = Kích thước thực tế / Kích thước thiết kế
widthScaleFactor = actualScreenWidth / 410
heightScaleFactor = actualScreenHeight / 840

// Ví dụ trên iPhone X:
widthScaleFactor = 375 / 410 = 0.915
heightScaleFactor = 812 / 840 = 0.967

// Khi bạn viết 100.w:
actualWidth = 100 * widthScaleFactor = 100 * 0.915 = 91.5px
```

### Lợi ích của việc sử dụng designSize:

1. **Thiết kế nhất quán**: UI sẽ có tỷ lệ tương tự trên mọi thiết bị
2. **Tự động scale**: Không cần viết code riêng cho từng thiết bị
3. **Dễ bảo trì**: Chỉ cần thiết kế cho một kích thước chuẩn
4. **Responsive tự động**: Ứng dụng tự động thích ứng với mọi màn hình

### Các designSize phổ biến khác:

```dart
// iPhone SE (cũ)
designSize: const Size(375, 667)

// iPhone 12/13/14
designSize: const Size(390, 844)

// Android phổ biến
designSize: const Size(360, 800)

// Tablet
designSize: const Size(768, 1024)

// Desktop
designSize: const Size(1920, 1080)
```

### Khuyến nghị:

- **Mobile app**: Sử dụng `Size(375, 812)` hoặc `Size(390, 844)`
- **Tablet app**: Sử dụng `Size(768, 1024)`
- **Desktop app**: Sử dụng `Size(1920, 1080)`
- **Universal app**: Sử dụng `Size(375, 812)` và test trên nhiều thiết bị

## Các thiết bị được hỗ trợ

- iPhone (tất cả các kích thước)
- Android phones (tất cả các kích thước)
- Tablets (iPad, Android tablets)
- Desktop (Windows, macOS, Linux)

## Best Practices

1. **Luôn sử dụng ScreenUtil cho tất cả kích thước cố định**
2. **Không sử dụng const với ScreenUtil extensions**
3. **Sử dụng .sp cho font size thay vì .w hoặc .h**
4. **Test trên nhiều thiết bị khác nhau**
5. **Sử dụng .r cho border radius**
6. **Sử dụng .w cho width và .h cho height**

## Ví dụ hoàn chỉnh

```dart
class ResponsiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.w,
      height: 200.h,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Responsive Title',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'This text will scale properly on all devices',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
``` 