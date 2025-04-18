import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../routes/app_pages.dart';
import '../../controller/blog_controller.dart';
import '../widgets/blog_card.dart';
import '../widgets/blog_shimmer.dart';
import '../widgets/category_selector.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/featured_blog.dart';
import '../widgets/story_circle.dart';

class BlogListView extends StatefulWidget {
  const BlogListView({super.key});

  @override
  _BlogListViewState createState() => _BlogListViewState();
}

class _BlogListViewState extends State<BlogListView>
    with SingleTickerProviderStateMixin {
  final BlogController controller = Get.find<BlogController>();
  late AnimationController _refreshIconController;
  final RxString selectedCategory = 'All'.obs;
  final RxInt currentNavIndex = 0.obs;

  final List<String> categories = [
    'All',
    'Flutter',
    'Mobile',
    'UI/UX',
    'Development',
    'Design',
    'Technology',
  ];

  @override
  void initState() {
    super.initState();
    _refreshIconController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _refreshIconController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    _refreshIconController.repeat();
    await controller.fetchBlogPosts();
    _refreshIconController.stop();
    _refreshIconController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Blog Feed',
        onSearchPressed: () {
          // Create a function for search functionality
          Get.snackbar(
            'Search',
            'Search functionality coming soon!',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        onNotificationPressed: () {
          // Create a function for notifications
          Get.snackbar(
            'Notifications',
            'Notifications functionality coming soon!',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        onProfilePressed: () {
          // Create a function for profile
          Get.snackbar(
            'Profile',
            'Profile functionality coming soon!',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return BlogShimmer();
        }

        if (controller.blogPosts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No blog posts found',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                SizedBox(height: 8),
                Text(
                  'Pull down to refresh or check back later',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _handleRefresh(),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _handleRefresh,
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              // Stories section
              Container(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.blogPosts.length,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  itemBuilder: (context, index) {
                    final blog = controller.blogPosts[index];
                    return StoryCircle(
                      imageUrl: blog.imageURL,
                      username: blog.author.split(' ')[0],
                      isViewed: index % 3 == 0, // Random viewed status for demo
                      onTap: () {
                        Get.toNamed(
                          Routes.BLOG_DETAIL.replaceAll(':id', blog.id),
                          arguments: blog,
                        );
                      },
                    );
                  },
                ),
              ),

              // Featured blog
              if (controller.blogPosts.isNotEmpty)
                FeaturedBlog(
                  blog: controller.blogPosts.first,
                  onTap: () {
                    Get.toNamed(
                      Routes.BLOG_DETAIL.replaceAll(
                        ':id',
                        controller.blogPosts.first.id,
                      ),
                      arguments: controller.blogPosts.first,
                    );
                  },
                ),

              // Category selector
              Obx(
                () => CategorySelector(
                  categories: categories,
                  selectedCategory: selectedCategory.value,
                  onCategorySelected: (category) {
                    selectedCategory.value = category;
                    // Filter blogs by category
                    // This would be implemented in the controller
                  },
                ),
              ),

              // Section title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Latest Posts',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        // View all posts
                      },
                      child: Text('View All'),
                    ),
                  ],
                ),
              ),

              // Blog posts
              AnimationLimiter(
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: controller.blogPosts.length,
                  padding: EdgeInsets.only(bottom: 24),
                  itemBuilder: (context, index) {
                    final blog = controller.blogPosts[index];
                    final isHighlighted =
                        blog.id == controller.selectedBlogId.value;

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: BlogCard(
                            blog: blog,
                            isHighlighted: isHighlighted,
                            onTap: () {
                              // Navigate to blog detail
                              Get.toNamed(
                                Routes.BLOG_DETAIL.replaceAll(':id', blog.id),
                                arguments: blog,
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(
        () => CustomBottomNav(
          currentIndex: currentNavIndex.value,
          onTap: (index) {
            currentNavIndex.value = index;
            // Handle navigation
            if (index == 0) {
              // Already on home
            } else if (index == 1) {
              // Navigate to explore
              Get.snackbar(
                'Explore',
                'Explore page coming soon!',
                snackPosition: SnackPosition.BOTTOM,
              );
            } else if (index == 2) {
              // Navigate to saved
              Get.snackbar(
                'Saved',
                'Saved posts page coming soon!',
                snackPosition: SnackPosition.BOTTOM,
              );
            } else if (index == 3) {
              // Navigate to profile
              Get.snackbar(
                'Profile',
                'Profile page coming soon!',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create a function for sharing the app
          Get.snackbar(
            'Share',
            'Share functionality coming soon!',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        tooltip: 'Share App',
        child: Icon(Icons.share),
      ),
    );
  }
}
