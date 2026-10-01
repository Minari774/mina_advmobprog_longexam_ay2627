import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/user.dart';
import '../services/user_service.dart';
import '../widgets/custom_info.dart' as notif;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final Future<List<User>> _usersFuture = UserService().getUsers();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      width: ScreenUtil().screenWidth,
      child: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Text('Hindi ma-load ang users. Pakisubukan ulit.'),
              ),
            );
          }

          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('Walang users na nakita.'));
          }

          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (context, index) =>
                Divider(color: theme.dividerColor, height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              final fullName = '${user.firstName} ${user.lastName}'.trim();
              return notif.Notification(
                name: fullName.isEmpty ? user.username : fullName,
                post: 'DummyJSON user #${user.id}',
                description: 'User mula sa DummyJSON.',
                comment: user.username.isEmpty ? '' : '@${user.username}',
                profileImageUrl: user.image,
                userData: user,
                atProfile: true,
              );
            },
          );
        },
      ),
    );
  }
}
