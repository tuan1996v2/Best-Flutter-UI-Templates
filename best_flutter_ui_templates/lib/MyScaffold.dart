import 'package:flutter/material.dart';
import 'package:best_flutter_ui_templates/utils/logger.dart';
import 'package:best_flutter_ui_templates/utils/debug_overlay_scaffold.dart';

class MyScaffold extends StatefulWidget {
  const MyScaffold({super.key});

  @override
  State<MyScaffold> createState() => _MyScaffoldState();
}

class _MyScaffoldState extends State<MyScaffold> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _displayedText = '';
  String _displayedPassword = '';
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final show = _scrollController.offset > 100;
      if (_showBackToTop != show) {
        setState(() {
          _showBackToTop = show;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _scrollController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DebugOverlayScaffold(
      screenName: 'MyScaffold',
      appBar: AppBar(
        title: Text('Test Scaffold'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () {
              logger.d('object');
            },
            icon: Icon(Icons.message),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.call)),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: .symmetric(horizontal: 20),
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    const Text('MyScaffold'),

                    InkWell(
                      onTap: () {
                        logger.d('Nút này sẽ không có màu đỏ khi chạm vào');
                      },
                      child: Container(
                        padding: .symmetric(horizontal: 10, vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: .all(color: Colors.red, width: 1),
                        ),
                        child: Text('Nút có hiệu ứng InkWell'),
                      ),
                    ),

                    SizedBox(height: 10),
                    TextField(
                      keyboardType: .name,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'Họ và tên',
                        hintText: ' Nhập vào đây',
                        helperText: 'Nhập họ tên của bạn',
                        prefixIcon: Icon(Icons.person),
                        suffixIcon: Icon(Icons.person),
                        contentPadding: .symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                      ),
                    ),

                    SizedBox(height: 10),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _displayedText = value;
                        });
                      },

                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'Email',
                        hintText: ' Nhập email của bạn',
                        helperText: ' helperText',
                        prefixIcon: Icon(Icons.email),

                        suffixIcon: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            _emailController.clear();
                            setState(() {
                              _displayedText = '';
                            });
                          },
                        ),

                        contentPadding: .symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _displayedPassword = value;
                        });
                      },

                      controller: _passwordController,
                      obscureText: true,

                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'Mật khẩu',
                        hintText: ' Nhập mật khẩu của bạn',
                        helperText: 'helperText',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            _passwordController.clear();
                            setState(() {
                              _displayedPassword = '';
                            });
                          },
                        ),

                        contentPadding: .symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                      ),
                    ),

                    SizedBox(height: 10),
                    Text(_displayedText),
                    GestureDetector(
                      onTap: () {
                        logger.d('Nút này có màu đỏ khi chạm vào');
                      },
                      onDoubleTap: () {
                        logger.d('onDoubleTap');
                      },
                      onLongPress: () {
                        logger.d('onLongPress');
                      },
                      onVerticalDragUpdate: (details) {
                        logger.d('kéo trên dưới ${details.delta}');
                      },
                      onScaleUpdate: (details) {
                        logger.d('kéo trái phải ${details.scale}');
                      },

                      child: Container(
                        width: 200,
                        height: 200,
                        color: Colors.red,
                        child: Center(
                          child: Text(
                            "Chạm Vào Tao",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: null,
                      // onPressed: () {
                      //   logger.d('Nút này có màu đỏ khi chạm vào');
                      // },
                      child: Text('Buttonnnnn'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: .symmetric(horizontal: 10, vertical: 5),
                        elevation: 2,
                      ),
                    ),
                    SizedBox(height: 10),
                    const Text(
                      'Xin chào các cháu: adf à à adsf ads eqwr ầdsf ả2r qewf ávsf eqwr eqw  ',
                      style: TextStyle(fontSize: 20, fontWeight: .bold),
                      textAlign: .center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      width: 200,
                      height: 200,
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Column(
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .center,
                        children: [const Text('đây là nội')],
                      ),
                    ),
                    Align(
                      alignment: .center,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(height: 10),
                              Icon(Icons.call),
                              Icon(Icons.call),
                              Icon(Icons.call),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: .spaceEvenly,
                            crossAxisAlignment: .center,
                            children: [
                              SizedBox(height: 10),
                              const Text('Text1.......'),
                              const Text('Text2.......'),
                              const Text('Text3.......'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        logger.d('baams vaof nuts');
                      },

                      child: Column(
                        children: [
                          Container(
                            width: 200,
                            height: 2000,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Column(
                              mainAxisAlignment: .center,
                              crossAxisAlignment: .center,
                              children: [const Text('đây là nội')],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(50), // Bo góc ở đây
                      ),
                      child: Material(
                        // Dùng Material làm "cái nền" cho hiệu ứng
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            50,
                          ), // Bo góc cả InkWell
                          onTap: () => logger.d('baams vaof nuts'),
                          child: Center(child: Text('đây là nội')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: AnimatedScale(
                scale: _showBackToTop ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: AnimatedOpacity(
                  opacity: _showBackToTop ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.fastOutSlowIn,
                      );
                    },
                    child: const Icon(Icons.keyboard_arrow_up),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: 'asdfadsf',
        onPressed: () {},
        child: Icon(Icons.call),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
    );
  }
}
