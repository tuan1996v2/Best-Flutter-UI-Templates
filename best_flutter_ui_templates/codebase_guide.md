# Hướng Dẫn Chi Tiết Cấu Trúc Mã Nguồn & Hệ Thống Điều Hướng (Navigation/Router)

Chào mừng bạn đến với hành trình học Flutter! Đây là một bộ UI Templates rất đẹp mắt và được viết với cấu trúc tùy biến cao. Dưới đây là phân tích chi tiết toàn bộ source code của dự án để giúp bạn nắm bắt nhanh chóng cách hoạt động, cách quản lý màn hình và cách điều hướng (router) trong ứng dụng.

---

## 1. Cấu Trúc Tổng Quan Thư Mục (Project Structure)

Dự án được tổ chức thành các thư mục con trong thư mục `lib/` nhằm tách biệt các tính năng/mẫu UI khác nhau:

*   **[main.dart](file:///Users/tuanos/work/Flutter/Best-Flutter-UI-Templates/best_flutter_ui_templates/lib/main.dart)**: Điểm khởi chạy (Entry Point) của ứng dụng.
*   **[navigation_home_screen.dart](file:///Users/tuanos/work/Flutter/Best-Flutter-UI-Templates/best_flutter_ui_templates/lib/navigation_home_screen.dart)**: Giao diện chính chứa Drawer (Thanh menu trượt bên trái) để chuyển đổi giữa các mục màn hình chính như Home, Help, Feedback, Invite.
*   **[home_screen.dart](file:///Users/tuanos/work/Flutter/Best-Flutter-UI-Templates/best_flutter_ui_templates/lib/home_screen.dart)**: Màn hình Home hiển thị danh sách lưới (Grid View) các mẫu UI lớn (Hotel Booking, Fitness App, v.v.).
*   **[app_theme.dart](file:///Users/tuanos/work/Flutter/Best-Flutter-UI-Templates/best_flutter_ui_templates/lib/app_theme.dart)**: Định nghĩa bảng màu (Colors) và kiểu chữ (TextTheme) chung của toàn bộ ứng dụng.
*   **`custom_drawer/`**: Chứa mã nguồn cho Drawer tùy biến (không dùng Drawer mặc định của Flutter):
    *   [drawer_user_controller.dart](file:///Users/tuanos/work/Flutter/Best-Flutter-UI-Templates/best_flutter_ui_templates/lib/custom_drawer/drawer_user_controller.dart): Bộ điều khiển hiệu ứng cuộn ngang kéo Drawer ra/vào.
    *   [home_drawer.dart](file:///Users/tuanos/work/Flutter/Best-Flutter-UI-Templates/best_flutter_ui_templates/lib/custom_drawer/home_drawer.dart): Thiết kế giao diện bên trong của thanh Drawer (User Avatar, Danh sách menu như Home, Help, Feedback).
*   **`introduction_animation/`**: Màn hình giới thiệu ban đầu (Splash/Onboarding) với các hiệu ứng chuyển động mượt mà.
*   **`hotel_booking/`**: Mẫu UI đặt phòng khách sạn (Hotel Booking) hoàn chỉnh với các bộ lọc, tìm kiếm và xem danh sách.
*   **`fitness_app/`**: Mẫu UI theo dõi sức khỏe (Fitness App) với biểu đồ và giao diện theo dõi chế độ ăn uống, tập luyện.
*   **`design_course/`**: Mẫu UI khóa học thiết kế (Design Course) với các danh mục bài học và chi tiết khóa học.
*   **`model/`**: Định nghĩa các lớp dữ liệu (Data models) dùng cho việc hiển thị danh sách trên màn hình Home.

---

## 2. Hệ Thống Điều Hướng & Định Tuyến (Navigation & Router)

Trong dự án này, việc điều hướng không sử dụng các thư viện ngoài như `go_router` hay đặt tên Route (`named routes`), mà thay vào đó sử dụng **hai phương pháp điều hướng thuần** của Flutter:

### A. Thay Thế Widget Bằng State (State-based Tab Navigation)
Áp dụng cho thanh menu Drawer chính và Bottom Bar trong Fitness App.

#### Cách hoạt động tại Drawer chính ([navigation_home_screen.dart](file:///Users/tuanos/work/Flutter/Best-Flutter-UI-Templates/best_flutter_ui_templates/lib/navigation_home_screen.dart)):
1.  Tại State của `_NavigationHomeScreenState`, định nghĩa biến `Widget? screenView` chứa widget của màn hình hiện tại (mặc định ban đầu là `MyHomePage()`).
2.  Truyền `screenView` vào widget quản lý drawer cuộn ngang `DrawerUserController`.
3.  Khi người dùng click vào một mục trong drawer, hàm callback `onDrawerCall` được kích hoạt và gọi `changeIndex(drawerIndexdata)`.
4.  Hàm `changeIndex` sẽ cập nhật lại `screenView` tương ứng với enum `DrawerIndex` được chọn và gọi `setState()` để re-build lại giao diện hiển thị màn hình mới:

```dart
void changeIndex(DrawerIndex drawerIndexdata) {
  if (drawerIndex != drawerIndexdata) {
    drawerIndex = drawerIndexdata;
    switch (drawerIndex) {
      case DrawerIndex.HOME:
        setState(() {
          screenView = const MyHomePage();
        });
        break;
      case DrawerIndex.Help:
        setState(() {
          screenView = HelpScreen();
        });
        break;
      // ... các màn hình khác
    }
  }
}
```

*   **Ưu điểm**: Không tạo thêm màn hình mới chồng lên ngăn xếp điều hướng (Navigation Stack). Phù hợp cho cấu trúc giao diện dạng Tab hoặc Side Menu nơi trang thái drawer được giữ nguyên.

---

### B. Sử Dụng Navigator Đẩy Màn Hình Mới (Stack-based Navigation)
Áp dụng khi chuyển từ màn hình lưới Home đi vào các Template chi tiết (như Hotel Booking, Design Course).

#### Cách hoạt động tại [home_screen.dart](file:///Users/tuanos/work/Flutter/Best-Flutter-UI-Templates/best_flutter_ui_templates/lib/home_screen.dart):
Khi click vào một ô trong danh sách lưới `GridView`, phương thức `Navigator.push` được gọi để mở màn hình mới:

```dart
callBack: () {
  Navigator.push<dynamic>(
    context,
    MaterialPageRoute<dynamic>(
      builder: (BuildContext context) => homeList[index].navigateScreen!,
    ),
  );
}
```

*   `Navigator.push` đưa một Route mới (ở đây là `MaterialPageRoute`) đè lên trên màn hình hiện tại trong Navigation Stack.
*   Khi muốn quay lại màn hình Home, ở các màn hình con chỉ cần gọi:
    ```dart
    Navigator.pop(context);
    ```
    Nút Back ở AppBar hoặc nút Back vật lý trên Android cũng sẽ tự động kích hoạt `Navigator.pop`.

---

## 3. Cách Sử Dụng & Thêm Màn Hình Mới Vào Ứng Dụng

Nếu bạn muốn thêm một màn hình mới (ví dụ màn hình `ProfileScreen`) vào Drawer hoặc danh sách Home, hãy làm theo các bước dưới đây:

### Cách 1: Thêm vào thanh trượt Drawer bên trái

1.  **Định nghĩa Enum mới**: Mở file [home_drawer.dart](file:///Users/tuanos/work/Flutter/Best-Flutter-UI-Templates/best_flutter_ui_templates/lib/custom_drawer/home_drawer.dart), tìm enum `DrawerIndex` và thêm mục mới của bạn vào:
    ```dart
    enum DrawerIndex {
      HOME,
      Help,
      FeedBack,
      Invite,
      Share,
      About,
      Profile, // Thêm dòng này
    }
    ```
2.  **Thêm nút bấm hiển thị ở Drawer**: Cũng trong file [home_drawer.dart](file:///Users/tuanos/work/Flutter/Best-Flutter-UI-Templates/best_flutter_ui_templates/lib/custom_drawer/home_drawer.dart), tìm danh sách `navigationList` và thêm thông tin hiển thị (nhãn, icon):
    ```dart
    DrawerList(
      index: DrawerIndex.Profile,
      labelName: 'My Profile',
      icon: Icon(Icons.person),
    ),
    ```
3.  **Ánh xạ màn hình hiển thị**: Mở file [navigation_home_screen.dart](file:///Users/tuanos/work/Flutter/Best-Flutter-UI-Templates/best_flutter_ui_templates/lib/navigation_home_screen.dart), nhập (import) file chứa màn hình của bạn và cập nhật hàm `changeIndex`:
    ```dart
    case DrawerIndex.Profile:
      setState(() {
        screenView = ProfileScreen(); // Gán màn hình profile của bạn
      });
      break;
    ```

---

### Cách 2: Thêm vào màn hình Lưới chính (Grid Home)

1.  **Chuẩn bị hình ảnh**: Thêm ảnh đại diện của màn hình vào thư mục `assets/` (ví dụ `assets/profile_preview.png`) và khai báo trong `pubspec.yaml`.
2.  **Đăng ký màn hình vào danh sách**: Mở file [homelist.dart](file:///Users/tuanos/work/Flutter/Best-Flutter-UI-Templates/best_flutter_ui_templates/lib/model/homelist.dart), nhập màn hình mới của bạn và thêm một phần tử `HomeList` vào mảng `homeList`:
    ```dart
    HomeList(
      imagePath: 'assets/profile_preview.png',
      navigateScreen: ProfileScreen(), // Màn hình mới của bạn
    ),
    ```
    Ứng dụng sẽ tự động tính toán số lượng phần tử và hiển thị thêm một ô lưới mới trên giao diện Home với các hiệu ứng chuyển động đi kèm.

---

## 4. Phân Tích Kỹ Thuật Đặc Biệt Trọng Tâm Trong Dự Án

*   **Custom Drawer bằng SingleChildScrollView**: Xem tại [drawer_user_controller.dart](file:///Users/tuanos/work/Flutter/Best-Flutter-UI-Templates/best_flutter_ui_templates/lib/custom_drawer/drawer_user_controller.dart). Kỹ thuật này sử dụng cuộn ngang kết hợp với dịch chuyển tọa độ `Matrix4.translationValues` để tạo hiệu ứng Drawer trượt mượt mà hơn nhiều so với việc chỉ ẩn/hiển thị đơn thuần.
*   **Hiệu ứng Animation xuất hiện tuần tự (Staggered Animation)**: Trong hầu hết các danh sách (như GridView ở Home hoặc ListView trong các sub-apps), lập trình viên sử dụng `AnimationController` kết hợp với `Interval` để các phần tử xuất hiện trượt từ dưới lên lần lượt từng cái một thay vì xuất hiện cùng lúc, đem lại trải nghiệm cao cấp (Premium feel).
*   **Sử dụng `FutureBuilder` trì hoãn nhẹ**: Bạn sẽ thấy các màn hình thường dùng `FutureBuilder` với một hàm `getData()` chờ khoảng 200 miligiây. Điều này giúp hệ thống thực hiện xong các hiệu ứng chuyển trang (page transition) trước khi dựng các layout phức tạp, tránh tình trạng bị giật/lag khung hình khi chuyển màn hình.
