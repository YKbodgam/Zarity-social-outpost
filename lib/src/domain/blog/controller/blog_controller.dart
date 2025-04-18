import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get_storage/get_storage.dart';

import '../models/blog_model.dart';
import '../services/firebase_services.dart';

class BlogController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final RxList<BlogPost> blogPosts = <BlogPost>[].obs;
  final RxList<BlogPost> filteredBlogPosts = <BlogPost>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedBlogId = ''.obs;
  final RxList<String> bookmarkedPosts = <String>[].obs;
  final RxList<String> likedPosts = <String>[].obs;

  // For categories and filters
  final RxString selectedCategory = 'All'.obs;

  // Local storage for bookmarks and likes
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadLocalUserData();
    fetchBlogPosts();
    initDeepLinks();
  }

  Future<void> _loadLocalUserData() async {
    try {
      // Load saved bookmarks from local storage
      final List<dynamic>? savedBookmarks = box.read<List>('bookmarkedPosts');
      if (savedBookmarks != null) {
        bookmarkedPosts.value =
            savedBookmarks.map((e) => e.toString()).toList();
      }

      // Load saved likes from local storage
      final List<dynamic>? savedLikes = box.read<List>('likedPosts');
      if (savedLikes != null) {
        likedPosts.value = savedLikes.map((e) => e.toString()).toList();
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> initDeepLinks() async {
    try {
      await _firebaseService.initDynamicLinks();
    } catch (e) {
      print('Error initializing deep links: $e');
    }
  }

  Future<void> fetchBlogPosts() async {
    isLoading.value = true;

    try {
      // First try to get data from the Firestore database
      final List<BlogPost> posts = await _firebaseService.getBlogPosts();

      // If no posts are found in the database, add sample data
      if (posts.isEmpty) {
        await _firebaseService.addSampleData();
        // Try fetching again after adding sample data
        blogPosts.value = await _firebaseService.getBlogPosts();
      } else {
        blogPosts.value = posts;
      }

      // Apply initial filtering
      _applyFilters();
    } catch (e) {
      print('Error fetching blog posts: $e');
      // In case of error, try to use mock data as fallback
      blogPosts.value = _getMockBlogPosts();
      _applyFilters();
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilters() {
    if (selectedCategory.value == 'All') {
      filteredBlogPosts.value = blogPosts;
    } else {
      filteredBlogPosts.value =
          blogPosts.where((post) {
            return post.tags.contains(selectedCategory.value);
          }).toList();
    }
  }

  void setSelectedCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  BlogPost? getBlogPostById(String id) {
    try {
      return blogPosts.firstWhere((post) => post.id == id);
    } catch (e) {
      print('Blog post with ID $id not found');
      return null;
    }
  }

  Future<void> shareBlogPost(BlogPost blog) async {
    try {
      final String dynamicLink = await _firebaseService.createBlogDynamicLink(
        blog.id,
      );

      await Share.share(
        'Check out this amazing blog post: ${blog.title}\n$dynamicLink',
      );
    } catch (e) {
      print('Error sharing blog post: $e');
      // Fallback to sharing without dynamic link
      await Share.share('Check out this amazing blog post: ${blog.title}');
    }
  }

  void toggleBookmark(String blogId) {
    if (bookmarkedPosts.contains(blogId)) {
      bookmarkedPosts.remove(blogId);
    } else {
      bookmarkedPosts.add(blogId);
    }

    // Save to local storage
    box.write('bookmarkedPosts', bookmarkedPosts.toList());
  }

  bool isBookmarked(String blogId) {
    return bookmarkedPosts.contains(blogId);
  }

  void toggleLike(String blogId) {
    if (likedPosts.contains(blogId)) {
      likedPosts.remove(blogId);
    } else {
      likedPosts.add(blogId);
    }

    // Save to local storage
    box.write('likedPosts', likedPosts.toList());
  }

  bool isLiked(String blogId) {
    return likedPosts.contains(blogId);
  }

  List<BlogPost> getBookmarkedBlogs() {
    return blogPosts
        .where((blog) => bookmarkedPosts.contains(blog.id))
        .toList();
  }

  List<BlogPost> getRelatedBlogs(String currentBlogId, {int limit = 3}) {
    final currentBlog = getBlogPostById(currentBlogId);
    if (currentBlog == null) return [];

    // Find blogs with similar tags
    final List<BlogPost> related =
        blogPosts.where((blog) => blog.id != currentBlogId).toList();

    // Sort by number of matching tags
    related.sort((a, b) {
      final aMatchingTags =
          a.tags.where((tag) => currentBlog.tags.contains(tag)).length;
      final bMatchingTags =
          b.tags.where((tag) => currentBlog.tags.contains(tag)).length;
      return bMatchingTags.compareTo(aMatchingTags);
    });

    return related.take(limit).toList();
  }

  // Mock data for fallback
  List<BlogPost> _getMockBlogPosts() {
    return [
      BlogPost(
        id: '1',
        imageURL: 'https://images.unsplash.com/photo-1542435503-956c469947f6',
        title: 'The Future of Mobile Development',
        summary:
            'Exploring the latest trends and technologies in mobile app development.',
        content:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
        deeplink: 'blogapp://blog/1',
        publishedDate: DateTime.now().subtract(Duration(days: 2)),
        author: 'John Doe',
        tags: ['Flutter', 'Mobile', 'Development'],
        readTimeMinutes: 5,
      ),
      BlogPost(
        id: '2',
        imageURL: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c',
        title: 'Building Responsive UIs with Flutter',
        summary:
            'Learn how to create beautiful, responsive user interfaces that work on any device.',
        content:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
        deeplink: 'blogapp://blog/2',
        publishedDate: DateTime.now().subtract(Duration(days: 5)),
        author: 'Jane Smith',
        tags: ['UI/UX', 'Flutter', 'Design'],
        readTimeMinutes: 8,
      ),
      BlogPost(
        id: '3',
        imageURL:
            'https://images.unsplash.com/photo-1517694712202-14dd9538aa97',
        title: 'State Management in Flutter: A Comprehensive Guide',
        summary:
            'Explore different state management solutions in Flutter and learn when to use each one.',
        content:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
        deeplink: 'blogapp://blog/3',
        publishedDate: DateTime.now().subtract(Duration(days: 8)),
        author: 'Alex Johnson',
        tags: ['Flutter', 'State Management', 'GetX'],
        readTimeMinutes: 10,
      ),
      BlogPost(
        id: '4',
        imageURL: 'https://images.unsplash.com/photo-1551650975-87deedd944c3',
        title: 'Firebase Integration with Flutter: A Step-by-Step Guide',
        summary:
            'Learn how to integrate Firebase services into your Flutter application for authentication, database, and more.',
        content:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
        deeplink: 'blogapp://blog/4',
        publishedDate: DateTime.now().subtract(Duration(days: 12)),
        author: 'Emily Chen',
        tags: ['Flutter', 'Firebase', 'Backend'],
        readTimeMinutes: 12,
      ),
    ];
  }
}
