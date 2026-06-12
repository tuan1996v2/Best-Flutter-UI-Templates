import 'package:best_flutter_ui_templates/MyScaffold.dart';
import 'package:best_flutter_ui_templates/register_screen.dart';
import 'package:best_flutter_ui_templates/f3_from_dropdown.dart';
import 'package:best_flutter_ui_templates/vidu_01.dart';
import 'package:best_flutter_ui_templates/utils/logger.dart';
import 'package:best_flutter_ui_templates/utils/debug_overlay_scaffold.dart';
import 'package:flutter/material.dart';

// MyApp đại diện cho Root Widget của ứng dụng.
// Kế thừa StatelessWidget vì nó không tự quản lý trạng thái (state) nội bộ
// (tương tự như một Functional Component thông thường trong React Native).
class HomeTest extends StatelessWidget {
  const HomeTest({super.key});

  @override
  Widget build(BuildContext context) {
    // build() tương tự như hàm render() trong React Native Class Component hoặc phần return (...) trong Functional Component.
    // BuildContext tương tự như React Context, chứa thông tin về vị trí của widget này trong Widget Tree (để truy cập Theme, Navigation, v.v.).
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.blue)),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

// MyHomePage là một StatefulWidget.
// Trong React Native, bạn thường viết state và UI trong cùng một component.
// Trong Flutter, StatefulWidget được tách làm 2 class riêng biệt:
// 1. Class Widget này (MyHomePage): Nhận và lưu cấu hình/props truyền từ component cha (giống `this.props` trong RN).
//    Các fields khai báo ở đây luôn là "final" (bất biến).
// 2. Class State tương ứng (ở dưới): Quản lý state động và build UI (giống `this.state` + `render()`).
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // Đây là prop nhận từ MaterialApp truyền vào, giống như props trong React Native.
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Class quản lý State và UI của MyHomePage.
// Chứa biến state và các hàm xử lý logic, hoạt động giống như useState hook của React Native.
class _MyHomePageState extends State<MyHomePage> {
  int _counter =
      10; // Biến state cục bộ. Tương đương: const [counter, setCounter] = useState(10);
  String text = 'vừa bấm ';
  // Hàm tăng counter lên 1
  void _incrementCounter() {
    setState(() {
      // setState() báo cho Flutter dựng lại (render) UI của Widget này.
      // Tương tự như setter của useState hoặc this.setState() trong React Native.
      _counter++;
      text = 'vừa bấm tăng nè';
    });
  }

  // Hàm giảm counter viết theo dạng rút gọn (arrow function)
  void _decrementCounter() => setState(() {
    _counter--;
    text = 'vừa bấm giảm nè';
  });

  @override
  void initState() {
    super.initState();
    logger.d('Khởi tạo đầu tiên');
  }

  @override
  void dispose() {
    super.dispose();
    logger.d('Return thoát nè');
  }

  @override
  Widget build(BuildContext context) {
    // Hàm build này được gọi lại mỗi khi setState() được thực thi (ví dụ khi click nút tăng/giảm).
    // Framework Flutter đã được tối ưu hóa cực tốt để việc dựng lại widget tree diễn ra cực nhanh,
    // nên bạn cứ yên tâm build lại toàn bộ widget cần thiết thay vì cập nhật từng phần nhỏ lẻ.
    return DebugOverlayScaffold(
      screenName: 'MyHomePage',
      // Scaffold cung cấp cấu trúc layout chuẩn của Material Design (gồm appBar, body, floatingActionButton...).
      // Trong React Native, bạn thường phải tự dựng bằng SafeAreaView, View, StyleSheet hoặc dùng Screen của React Navigation.
      appBar: AppBar(
        // AppBar tương tự Navigation Header trong React Navigation.
        // HƯỚNG DẪN THỬ NGHIỆM: Thử đổi màu ở đây (ví dụ thành Colors.amber) và trigger hot reload
        // để thấy AppBar đổi màu trong khi các thành phần khác giữ nguyên.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Dùng widget.title để truy cập thuộc tính 'title' định nghĩa ở class cha MyHomePage phía trên (tương tự `this.props.title`).
        title: Text(widget.title),
      ),
      body: Center(
        // Center là một layout widget. Nó chỉ nhận duy nhất 1 child và căn giữa child đó theo cả chiều dọc lẫn ngang.
        // Tương tự React Native: style={{ justifyContent: 'center', alignItems: 'center' }}
        child: Column(
          // Column sắp xếp các widget con theo chiều dọc.
          // Tương đương React Native: <View style={{ flexDirection: 'column' }}>
          //
          // Column có nhiều thuộc tính để chỉnh kích thước và căn lề.
          // mainAxisAlignment: .center dùng để căn giữa các widget con theo trục chính (trục dọc đối với Column).
          // Tương tự React Native: justifyContent: 'center' (khi flexDirection là 'column').
          //
          // HƯỚNG DẪN THỬ NGHIỆM: Bật "debug painting" trên IDE để xem khung viền (wireframe) của từng widget,
          // giống như cách bạn dùng Element Inspector trong React Native.
          mainAxisAlignment: .center,
          children: [
            Text('trạng thái: $text'),
            Text('Kết quả:$_counter '),
            Text(
              '$_counter',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium, // Sử dụng font style từ theme đã khai báo ở đầu app.
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => Vidu01()));
              },
              child: Text('Vidu01'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => MyScaffold()));
              },
              child: Text('MyScaffold'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => RegisterScreen()));
              },
              child: Text('FormBasicDemo'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => DropdownScreen()));
              },
              child: Text('DropdownScreen'),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: .centerFloat,
      floatingActionButton: Padding(
        // Padding dùng để tạo khoảng cách đệm (ở đây là khoảng cách lề trái-phải 20).
        // Tương đương React Native: style={{ paddingHorizontal: 20 }}
        padding: const .symmetric(horizontal: 20),
        child: Row(
          // Row sắp xếp các widget con theo chiều ngang.
          // Tương đương React Native: <View style={{ flexDirection: 'row' }}>
          // mainAxisAlignment: .spaceBetween sắp xếp các con dãn đều sang 2 bên rìa.
          // Tương đương React Native: justifyContent: 'space-between' (khi flexDirection là 'row').
          mainAxisAlignment: .spaceBetween,
          children: [
            FloatingActionButton(
              heroTag: 'btn_remove', // Đặt tag duy nhất cho nút này
              onPressed: _decrementCounter, // Gọi hàm giảm counter khi nhấn
              child: const Icon(Icons.remove),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const _DetailScreen())),
              child: const Icon(Icons.details),
            ),

            FloatingActionButton(
              heroTag: 'btn_add', // Đặt tag duy nhất cho nút này
              onPressed: _incrementCounter, // Gọi hàm tăng counter khi nhấn
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailScreen extends StatelessWidget {
  const _DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DebugOverlayScaffold(
      screenName: '_DetailScreen',
      appBar: AppBar(title: Text('Chi tiết')),
      body: Center(
        child: Column(
          children: [
            Text('Chi tiết'),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Quay lại'),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: .centerFloat,
      floatingActionButton: Padding(
        padding: const .symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            FloatingActionButton(
              heroTag: 'btn_remove',
              onPressed: () => {Navigator.of(context).pop()},
              child: const Icon(Icons.remove),
            ),
            FloatingActionButton(
              heroTag: 'btn_add',
              onPressed: () => {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => Vidu01())),
              },
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
