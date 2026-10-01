import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../screens/detail_screen.dart';
import 'custom_font.dart';

class Notification extends StatelessWidget {
  const Notification({
    super.key,
    required this.name,
    required this.post,
    required this.description,
    required this.comment,
    this.profileImageUrl = '',
    this.atProfile = false,
    this.date = '',
    this.hasImage = '',
    this.numOfLikes = 0,
    this.postData,
    this.userData,
  });

  final String name;
  final String post;
  final String description;
  final String comment;
  final String profileImageUrl;
  final String date;
  final int numOfLikes;
  final String hasImage;
  final bool atProfile;

  final Post? postData;
  final User? userData;

  void _openDetail(BuildContext context) {
    if (atProfile) {
      return;
    }

    final detailPost = postData ??
        Post(
          id: 1,
          userId: 1,
          body: comment.isNotEmpty ? comment : description,
          likes: numOfLikes,
          dislikes: 0,
          createdAt: post,
          updatedAt: post,
        );
    final user = userData ??
        User(
          id: 1,
          username: name,
          email: '',
          firstName: name.split(' ').first,
          lastName: name.split(' ').skip(1).join(' '),
          gender: '',
          image: 'assets/images/avatar1.jpg',
          accessToken: '',
          refreshToken: '',
        );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(post: detailPost, user: user),
      ),
    );
  }

  Widget _profileImage(BuildContext context) {
    final double radius = ScreenUtil().setSp(20);

    final theme = Theme.of(context);

    final Color imageBackground = theme.brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[300]!;

    final Color personIconColor = theme.brightness == Brightness.dark
        ? Colors.white70
        : Colors.grey[700]!;

    if (profileImageUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: imageBackground,
        child: Icon(
          Icons.person,
          size: ScreenUtil().setSp(20),
          color: personIconColor,
        ),
      );
    }

    if (profileImageUrl.startsWith('http://') ||
        profileImageUrl.startsWith('https://')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: imageBackground,
        backgroundImage: NetworkImage(profileImageUrl),
        onBackgroundImageError: (_, __) {},
        child: const SizedBox.shrink(),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: imageBackground,
      child: ClipOval(
        child: Image.asset(
          profileImageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            'assets/images/avatar1.jpg',
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Main text color.
    final Color textColor =
        theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;

    // Secondary text color.
    final Color secondaryTextColor = theme.brightness == Brightness.dark
        ? Colors.white70
        : Colors.black54;

    // Very subtle secondary text.
    final Color subtleTextColor = theme.brightness == Brightness.dark
        ? Colors.white54
        : Colors.grey.shade500;

    // Chevron color.
    final Color chevronColor = theme.brightness == Brightness.dark
        ? Colors.white54
        : Colors.grey.shade500;

    return InkWell(
      onTap: atProfile ? null : () => _openDetail(context),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(15),
          vertical: ScreenUtil().setHeight(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileImage(context),

            SizedBox(width: ScreenUtil().setWidth(10)),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NAME
                  CustomFont(
                    text: name,
                    fontSize: ScreenUtil().setSp(17),
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),

                  SizedBox(height: ScreenUtil().setHeight(3)),

                  // POST DATE
                  CustomFont(
                    text: 'Posted: $post',
                    fontSize: ScreenUtil().setSp(13),
                    color: textColor,
                  ),

                  // DESCRIPTION
                  if (description.isNotEmpty) ...[
                    SizedBox(height: ScreenUtil().setHeight(3)),

                    CustomFont(
                      text: description,
                      fontSize: ScreenUtil().setSp(12),
                      color: secondaryTextColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ],

                  // COMMENT
                  if (comment.isNotEmpty) ...[
                    SizedBox(height: ScreenUtil().setHeight(4)),

                    CustomFont(
                      text: comment,
                      fontSize: ScreenUtil().setSp(12),
                      color: textColor,
                    ),
                  ],

                  // DATE
                  if (date.isNotEmpty) ...[
                    SizedBox(height: ScreenUtil().setHeight(5)),

                    CustomFont(
                      text: date,
                      fontSize: ScreenUtil().setSp(11),
                      color: subtleTextColor,
                    ),
                  ],
                ],
              ),
            ),

            // POST IMAGE
            if (hasImage.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(10)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    hasImage,
                    width: ScreenUtil().setWidth(45),
                    height: ScreenUtil().setWidth(45),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/avatar20.png',
                        width: ScreenUtil().setWidth(45),
                        height: ScreenUtil().setWidth(45),
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),

            // CHEVRON
            if (!atProfile)
              Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(5)),
                child: Icon(Icons.chevron_right, color: chevronColor),
              ),
          ],
        ),
      ),
    );
  }
}
