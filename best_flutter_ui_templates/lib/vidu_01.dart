import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:best_flutter_ui_templates/utils/logger.dart';

class Vidu01 extends StatelessWidget {
  Vidu01({super.key});
  String name = "Tuanos";
  int age = 18;

  Future<String> taiDuLieu() async {
    await Future.delayed(const Duration(seconds: 2));
    return "Tải dữ liệu xong";
  }

  void viDuStreamDemSo() {
    logger.d('=====ví dụ 1 : stream trò chơi năm mười ========');
    Stream.periodic(const Duration(seconds: 1), (x) => (x + 1) * 5)
        .take(3)
        .listen(
          (event) => logger.d(event),
          onDone: () => logger.d('Xong nè'),
          onError: (error) => logger.e('Lỗi nè $error'),
        );
  }

  void viDuStreamController() async {
    logger.d('=====ví dụ 2 : stream================');

    StreamController<String> controller = StreamController<String>();
    controller.stream.listen(
      (tinNhan) {
        logger.d('Tin nhắn : $tinNhan');
      },
      onDone: () => logger.d('Đã đóng'),
      onError: (error) => logger.e('Lỗi $error'),
    );
    controller.sink.add('Hello');
    await Future.delayed(Duration(seconds: 2), () {
      logger.d('Đang gửi tin nhắn cuối cùng');
      controller.sink.add('World');
      controller.close();
    });
    controller.sink.add('Hello2');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vidu01')),
      body: Center(
        child: Column(
          children: [
            Text('Vidu01'),
            Text(name),
            Text(age >= 18 ? 'Đủ tuổi' : 'Chưa đủ tuổi'),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () => viDuStreamDemSo(),
              child: const Text('Bấm đi'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () => viDuStreamController(),
              child: const Text('Bấm tin nhắn: '),
            ),
            FutureBuilder<String>(
              future: taiDuLieu(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data!);
                } else {
                  return const Text('Đang tải...');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
