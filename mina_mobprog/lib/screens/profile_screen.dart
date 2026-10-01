import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mina_mobprog/constants.dart';
import 'package:mina_mobprog/models/post.dart';
import 'package:mina_mobprog/models/user.dart';
import 'package:mina_mobprog/services/post_service.dart';
import 'package:mina_mobprog/widgets/custom_font.dart';
import 'package:mina_mobprog/widgets/post_card.dart';

import 'detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<Post>> _postsFuture;

  final List<String> photos = [
    'assets/images/avatar1.jpg',
    'assets/images/avatar2.jpg',
    'assets/images/avatar3.jpg',
    'assets/images/avatar4.jpg',
    'assets/images/avatar5.png',
    'assets/images/avatar6.jpg',
    'assets/images/avatar7.jpg',
    'assets/images/avatar8.jpg',
    'assets/images/avatar9.jpg',
    'assets/images/avatar10.jpg',
    'assets/images/avatar11.jpg',
    'assets/images/avatar12.jpg',
    'assets/images/avatar13.webp',
    'assets/images/avatar14.jpg',
    'assets/images/avatar15.jpg',
    'assets/images/avatar16.jpg',
    'assets/images/avatar17.jpg',
    'assets/images/avatar18.jpg',
    'assets/images/avagtar19.png',
    'assets/images/avatar20.png',
  ];

  @override
  void initState() {
    super.initState();

    _postsFuture = PostService().getPostsByUser(widget.user.id);
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postsFuture = PostService().getPostsByUser(widget.user.id);
    });

    await _postsFuture;
  }

  String _formatDate(String date) {
    if (date.isEmpty) {
      return 'Recently';
    }

    try {
      final parsedDate = DateTime.parse(date);

      return '${parsedDate.month}/${parsedDate.day}/${parsedDate.year}';
    } catch (_) {
      return date;
    }
  }

  Widget _profileImage({double radius = 20}) {
    final fallbackImage = photos.first;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: widget.user.image.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: widget.user.image,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(strokeWidth: 2),
                errorWidget: (context, url, error) => CachedNetworkImage(
                  imageUrl: fallbackImage,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.person),
                ),
              )
            : CachedNetworkImage(
                imageUrl: fallbackImage,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    const Icon(Icons.person),
              ),
      ),
    );
  }

  Widget _photos() {
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
      child: GridView.builder(
        itemCount: photos.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: ScreenUtil().setWidth(8),
          mainAxisSpacing: ScreenUtil().setHeight(8),
        ),
        itemBuilder: (context, index) {
          final imagePath = photos[index];

          final bool isAsset = imagePath.startsWith('assets/');

          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) {
                  return Dialog(
                    child: InteractiveViewer(
                      child: isAsset
                          ? Image.asset(imagePath, fit: BoxFit.contain)
                          : CachedNetworkImage(
                              imageUrl: imagePath,
                              fit: BoxFit.contain,
                            ),
                    ),
                  );
                },
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: isAsset
                  ? Image.asset(imagePath, fit: BoxFit.cover)
                  : CachedNetworkImage(
                      imageUrl: imagePath,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[300]),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.person),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _postsTab() {
    return FutureBuilder<List<Post>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50),
                  const SizedBox(height: 10),
                  const Text('Unable to load posts.'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _refreshPosts,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refreshPosts,
            child: ListView(
              children: const [
                SizedBox(height: 100),
                Center(child: Text('No posts found.')),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshPosts,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return NewsFeedCard(
                userName: '${widget.user.firstName} ${widget.user.lastName}',
                profileImageUrl: widget.user.image,
                postContent: post.body,
                numOfLikes: post.likes,
                date: _formatDate(post.createdAt),
                hasImage: '',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DetailScreen(post: post, user: widget.user),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          color: FB_PRIMARY.withValues(alpha: 0.12),
                        ),

                        Positioned(
                          bottom: -50,
                          left: ScreenUtil().setWidth(20),
                          child: Stack(
                            children: [
                              _profileImage(radius: 50),

                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.grey[300],
                                  child: const Icon(Icons.camera_alt, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: ScreenUtil().setHeight(55)),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomFont(
                            text:
                                '${widget.user.firstName} ${widget.user.lastName}',
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil().setSp(20),
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color ??
                                Colors.black,
                          ),

                          SizedBox(height: ScreenUtil().setHeight(5)),

                          CustomFont(
                            text: '@${widget.user.username}',
                            fontSize: ScreenUtil().setSp(14),
                            color: Colors.grey,
                          ),

                          SizedBox(height: ScreenUtil().setHeight(10)),

                          Row(
                            children: [
                              CustomFont(
                                text: '2.8M',
                                fontSize: ScreenUtil().setSp(15),
                                fontWeight: FontWeight.bold,
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'followers',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(width: 5),
                              Icon(Icons.circle, size: 5.sp, color: FB_PRIMARY),
                              const SizedBox(width: 5),
                              CustomFont(
                                text: '2',
                                fontSize: ScreenUtil().setSp(15),
                                fontWeight: FontWeight.bold,
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'following',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),

                          SizedBox(height: ScreenUtil().setHeight(10)),

                          Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: FB_PRIMARY,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {},
                                child: const Text('Follow'),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton(
                                onPressed: () {},
                                child: const Text('Message'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: ScreenUtil().setHeight(10)),
                  ],
                ),
              ),

              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    indicatorColor: FB_PRIMARY,
                    labelColor:
                        Theme.of(context).textTheme.bodyLarge?.color ??
                        Colors.black,
                    tabs: const [
                      Tab(text: 'Posts'),
                      Tab(text: 'About'),
                      Tab(text: 'Photos'),
                    ],
                  ),
                ),
              ),
            ];
          },

          body: TabBarView(
            children: [
              _postsTab(),

              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'About',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),

                          ListTile(
                            leading: const Icon(Icons.email_outlined),
                            title: const Text('Email'),
                            subtitle: Text(widget.user.email),
                          ),

                          ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: const Text('Username'),
                            subtitle: Text(widget.user.username),
                          ),

                          ListTile(
                            leading: const Icon(Icons.school),
                            title: const Text('Department'),
                            subtitle: const Text('CCIT'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              _photos(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
