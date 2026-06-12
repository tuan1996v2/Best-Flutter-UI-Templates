import 'package:flutter/material.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import 'utils/logger.dart';
import 'utils/debug_overlay_scaffold.dart';

class DropdownScreen extends StatefulWidget {
  const DropdownScreen({super.key});

  @override
  State<DropdownScreen> createState() => _DropdownScreenState();
}

class _DropdownScreenState extends State<DropdownScreen> {
  final TextEditingController _controller = TextEditingController();

  List<String> _cities = [
    'An Giang',
    'Bà Rịa - Vũng Tàu',
    'Bắc Giang',
    'Hà Nội',
    'Hồ Chí Minh',
    'Hải Phòng',
    'Bắc Ninh',
    'Thái Bình',
    'Nam Định',
    'Hải Dương',
    'Thái Nguyên',
    'Hòa Bình',
    'Thanh Hóa',
    'Nghệ An',
    'Hà Tĩnh',
    'Quảng Bình',
    'Quảng Trị',
    'Thừa Thiên Huế',
    'Đà Nẵng',
    'Quảng Nam',
    'Quảng Ngãi',
    'Bình Định',
    'Phú Yên',
    'Khánh Hòa',
    'Ninh Thuận',
    'Bình Thuận',
    'Đắk Lắk',
    'Đắk Nông',
    'Kon Tum',
    'Hồ Chí Minh',
    'Bà Rịa - Vũng Tàu',
    'An Giang',
    'Bắc Giang',
    'Hà Nội',
    'Hồ Chí Minh',
    'Hải Phòng',
    'Bắc Ninh',
    'Thái Bình',
    'Nam Định',
    'Hải Dương',
    'Thái Nguyên',
    'Hòa Bình',
    'Thanh Hóa',
    'Nghệ An',
    'Hà Tĩnh',
    'Quảng Bình',
    'Quảng Trị',
    'Thừa Thiên Huế',
    'Đà Nẵng',
    'Quảng Nam',
    'Quảng Ngãi',
    'Bình Định',
    'Phú Yên',
    'Khánh Hòa',
    'Ninh Thuận',
    'Bình Thuận',
    'Đắk Lắk',
    'Đắk Nông',
    'Kon Tum',
  ];
  String? _selectedCity;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DebugOverlayScaffold(
      screenName: 'DropdownScreen',
      appBar: AppBar(title: const Text('DropdownScreen')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButtonFormField(
              isExpanded: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng chọn thành phố';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _selectedCity = value;
                });
                logger.d(_selectedCity);
              },
              value: _selectedCity,
              decoration: InputDecoration(
                labelText: "Thành phố",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: _cities
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
            // Thay thế hoàn toàn DropdownButtonFormField bằng DropdownMenu
            DropdownMenu<String>(
              width:
                  MediaQuery.of(context).size.width -
                  40, // Đặt chiều rộng bằng width màn hình - padding
              label: const Text("Thành phố"),
              enableFilter: true, // Bật tính năng tìm kiếm
              requestFocusOnTap: true,
              onSelected: (String? value) {
                setState(() {
                  _selectedCity = value;
                });
              },
              dropdownMenuEntries: _cities.map((city) {
                return DropdownMenuEntry<String>(value: city, label: city);
              }).toList(),
            ),
            DropdownFlutter<String>(
              hintText: 'Select job role',
              items: _cities,
              onChanged: (value) {
                logger.i('Selected: $value');
              },
            ),
            SizedBox(height: 20),
            DropdownFlutter.search(
              items: _cities,
              onChanged: (value) {
                logger.i('Selected: $value');
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
