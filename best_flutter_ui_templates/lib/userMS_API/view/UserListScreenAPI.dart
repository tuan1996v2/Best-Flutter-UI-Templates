import "package:best_flutter_ui_templates/userMS/api/UserAPIService.dart";
import "package:best_flutter_ui_templates/userMS/view/AddUserScreen.dart";
import "package:best_flutter_ui_templates/userMS/view/EditUserScreen.dart";
import "package:best_flutter_ui_templates/utils/debug_overlay_scaffold.dart";
import "package:best_flutter_ui_templates/utils/logger.dart";
import "package:flutter/material.dart";
import "package:best_flutter_ui_templates/userMS/database/DatabaseHelper.dart";
import "package:best_flutter_ui_templates/userMS/model/User.dart";
import "package:best_flutter_ui_templates/userMS/view/UserListItem.dart";
import "package:logger/logger.dart";

class UserListScreenAPI extends StatefulWidget {
  @override
  _UserListScreenAPIState createState() => _UserListScreenAPIState();
}

class _UserListScreenAPIState extends State<UserListScreenAPI> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _usersFuture = DatabaseHelper.instance.getAllUsers();
    });
  }

  Future<void> _testCallAPI() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang gọi API...'),
        duration: Duration(milliseconds: 550),
      ),
    );
    try {
      final users = await UserAPIService.instance.getAllUsers();
      logger.d(
        'Test API thành công! Lấy được ${users.length} người dùng. ${users}',
      );
      if (users.isNotEmpty) {
        await DatabaseHelper.instance.deleteAllUsers();
        for (User user in users) {
          await DatabaseHelper.instance.createUser(user);
        }
      }
      _refreshUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('API Success: Lấy được ${users.length} người dùng!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      logger.e('Test API thất bại: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DebugOverlayScaffold(
      screenName: 'UserListScreenAPI',
      appBar: AppBar(
        title: Text('Danh sách người dùng'),
        actions: [
          IconButton(
            icon: Icon(Icons.api, color: Colors.blue),
            onPressed: _testCallAPI,
            tooltip: 'Test API Call',
          ),
          IconButton(icon: Icon(Icons.refresh), onPressed: _refreshUsers),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      await DatabaseHelper.instance.deleteAllUsers();
                      _refreshUsers();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã xoá toàn bộ dữ liệu local'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Xoá dữ liệu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _refreshUsers,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _testCallAPI,
                    icon: const Icon(Icons.api),
                    label: const Text('Gọi API'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Không có người dùng nào'));
                } else {
                  final reversedUsers = snapshot.data!.reversed.toList();
                  return ListView.builder(
                    itemCount: reversedUsers.length,
                    itemBuilder: (context, index) {
                      final user = reversedUsers[index];
                      return UserListItem(
                        user: user,
                        onDelete: () async {
                          await DatabaseHelper.instance.deleteUser(user.id!);
                          _refreshUsers();
                        },
                        onEdit: () async {
                          // Navigate to edit screen
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditUserScreen(user: user),
                            ),
                          );
                          if (updated == true) {
                            _refreshUsers();
                          }
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddUserScreen()),
          );
          if (created == true) {
            _refreshUsers();
          }
        },
      ),
    );
  }
}
