import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:like_button/like_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../routes/app_pages.dart';
import '../../controller/blog_controller.dart';
import '../../models/blog_model.dart';

class BlogDetailView extends StatefulWidget {
  const BlogDetailView({super.key});

  @override
  _BlogDetailViewState createState() => _BlogDetailViewState();
}

class _BlogDetailViewState extends State<BlogDetailView> {
  final BlogController controller = Get.find<BlogController>();
  final ScrollController _scrollController = ScrollController();
  final RxDouble _scrollProgress = 0.0.obs;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollProgress);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollProgress() {
    if (_scrollController.position.maxScrollExtent > 0) {
      _scrollProgress.value =
          _scrollController.offset / _scrollController.position.maxScrollExtent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String id = Get.parameters['id'] ?? '';
    final BlogPost blog = Get.arguments ?? controller.getBlogPostById(id)!;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                stretch: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'blog-image-${blog.id}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: blog.imageURL,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: Colors.grey[300],
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: Icon(Icons.error, color: Colors.red),
                              ),
                        ),
                        // Gradient overlay
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                                stops: [0.6, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      Share.share(
                        'Check out this amazing blog post: ${blog.title}\n${blog.deeplink}',
                      );
                    },
                  ),
                  LikeButton(
                    size: 24,
                    circleColor: CircleColor(
                      start: Color(0xffFF5722),
                      end: Color(0xffFF8A65),
                    ),
                    bubblesColor: BubblesColor(
                      dotPrimaryColor: Color(0xffFF5722),
                      dotSecondaryColor: Color(0xffFF8A65),
                    ),
                    likeBuilder: (bool isLiked) {
                      return Icon(
                        isLiked ? Icons.bookmark : Icons.bookmark_border,
                        color: isLiked ? AppTheme.primaryColor : Colors.white,
                        size: 24,
                      );
                    },
                  ),
                  SizedBox(width: 16),
                ],
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: Offset(0, -30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tags
                        if (blog.tags.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                blog.tags
                                    .map(
                                      (tag) => Chip(
                                        label: Text(
                                          tag,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                        backgroundColor: AppTheme.primaryColor
                                            .withOpacity(0.1),
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    )
                                    .toList(),
                          ),

                        SizedBox(height: 16),

                        // Title
                        Text(
                          blog.title,
                          style: Theme.of(
                            context,
                          ).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),

                        SizedBox(height: 16),

                        // Author and Date
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppTheme.primaryColor,
                              child: Text(
                                blog.author.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  blog.author,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${timeago.format(blog.publishedDate)} • ${blog.readTimeMinutes} min read',
                                  style: TextStyle(
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            OutlinedButton(
                              onPressed: () {
                                // Follow author
                                Get.snackbar(
                                  'Follow',
                                  'Follow functionality coming soon!',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                              child: Text('Follow'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                side: BorderSide(color: AppTheme.primaryColor),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24),

                        // Content
                        MarkdownBody(
                          data: blog.content,
                          styleSheet: MarkdownStyleSheet(
                            p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.8,
                              fontSize: 16,
                            ),
                            h1: Theme.of(
                              context,
                            ).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                            h2: Theme.of(
                              context,
                            ).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                            h3: Theme.of(
                              context,
                            ).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                            blockquote: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[700],
                              fontSize: 16,
                              height: 1.8,
                            ),
                            blockquoteDecoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            code: TextStyle(
                              fontFamily: 'monospace',
                              backgroundColor: Colors.grey[200],
                              fontSize: 14,
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onTapLink: (text, href, title) {
                            if (href != null) {
                              launchUrl(Uri.parse(href));
                            }
                          },
                        ),

                        SizedBox(height: 32),

                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              icon: Icons.thumb_up_outlined,
                              label: 'Like',
                              onTap: () {
                                Get.snackbar(
                                  'Like',
                                  'Like functionality coming soon!',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.comment_outlined,
                              label: 'Comment',
                              onTap: () {
                                Get.snackbar(
                                  'Comment',
                                  'Comment functionality coming soon!',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.share_outlined,
                              label: 'Share',
                              onTap: () {
                                Share.share(
                                  'Check out this amazing blog post: ${blog.title}\n${blog.deeplink}',
                                );
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.bookmark_border_outlined,
                              label: 'Save',
                              onTap: () {
                                Get.snackbar(
                                  'Save',
                                  'Save functionality coming soon!',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: 32),

                        // Related Posts
                        Text(
                          'Related Posts',
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        SizedBox(height: 16),

                        // Related posts list
                        Container(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.blogPosts.length > 1 ? 3 : 0,
                            itemBuilder: (context, index) {
                              // Skip the current blog post
                              final relatedIndex =
                                  (index + 1) % controller.blogPosts.length;
                              final relatedBlog =
                                  controller.blogPosts[relatedIndex];

                              return Container(
                                width: 280,
                                margin: EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Theme.of(context).cardColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Get.toNamed(
                                      Routes.BLOG_DETAIL.replaceAll(
                                        ':id',
                                        relatedBlog.id,
                                      ),
                                      arguments: relatedBlog,
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: relatedBlog.imageURL,
                                          height: 120,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              relatedBlog.title,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'By ${relatedBlog.author}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Reading progress indicator
          Obx(
            () => Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _scrollProgress.value,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
                minHeight: 3,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create a function for commenting
          Get.snackbar(
            'Comment',
            'Comment functionality coming soon!',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        child: Icon(Icons.comment),
        tooltip: 'Add Comment',
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
