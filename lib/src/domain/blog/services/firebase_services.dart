import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import '../../../routes/app_pages.dart';
import '../models/blog_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDynamicLinks _dynamicLinks = FirebaseDynamicLinks.instance;

  // Collection references
  final CollectionReference _blogsCollection = FirebaseFirestore.instance
      .collection('blogs');

  // Get all blog posts
  Future<List<BlogPost>> getBlogPosts() async {
    try {
      final QuerySnapshot snapshot =
          await _blogsCollection
              .orderBy('publishedDate', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return BlogPost.fromJson({'id': doc.id, ...data});
      }).toList();
    } catch (e) {
      print('Error fetching blog posts: $e');
      throw e;
    }
  }

  // Get blog post by ID
  Future<BlogPost?> getBlogPostById(String id) async {
    try {
      final DocumentSnapshot doc = await _blogsCollection.doc(id).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return BlogPost.fromJson({'id': doc.id, ...data});
      }

      return null;
    } catch (e) {
      print('Error fetching blog post by ID: $e');
      throw e;
    }
  }

  // Initialize dynamic links
  Future<void> initDynamicLinks() async {
    // Handle app opened from dynamic link while app is in terminated state
    final PendingDynamicLinkData? initialLink =
        await _dynamicLinks.getInitialLink();
    if (initialLink != null) {
      _handleDynamicLink(initialLink);
    }

    // Handle app opened from dynamic link while app is in background
    _dynamicLinks.onLink
        .listen((dynamicLinkData) {
          _handleDynamicLink(dynamicLinkData);
        })
        .onError((error) {
          print('Error handling dynamic link: $error');
        });
  }

  void _handleDynamicLink(PendingDynamicLinkData data) {
    final Uri deepLink = data.link;

    // Example deeplink: https://blogfusion.page.link/blog?id=123
    final String? blogId = deepLink.queryParameters['id'];

    if (blogId != null) {
      Get.toNamed(Routes.BLOG_DETAIL.replaceAll(':id', blogId));
    }
  }

  // Create a dynamic link
  Future<String> createBlogDynamicLink(String blogId) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://blogfusion.page.link',
      link: Uri.parse('https://blogfusion.page.link/blog?id=$blogId'),
      androidParameters: AndroidParameters(
        packageName: 'com.example.flutter_blog_app',
        minimumVersion: 0,
      ),
      iosParameters: IOSParameters(
        bundleId: 'com.example.flutterBlogApp',
        minimumVersion: '0',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Check out this blog post!',
        description: 'Read this amazing blog post on BlogFusion',
        imageUrl: Uri.parse(
          'https://images.unsplash.com/photo-1542435503-956c469947f6',
        ),
      ),
    );

    final ShortDynamicLink shortLink = await _dynamicLinks.buildShortLink(
      parameters,
    );
    return shortLink.shortUrl.toString();
  }

  // Helper method to add sample data
  Future<void> addSampleData() async {
    try {
      final List<Map<String, dynamic>> sampleBlogs = [
        {
          'title': 'The Future of Mobile Development',
          'summary':
              'Exploring the latest trends and technologies in mobile app development.',
          'content': """
# The Future of Mobile Development

Mobile development is constantly evolving, with new frameworks, tools, and practices emerging regularly. In this article, we'll explore the latest trends and technologies in mobile app development.

## Cross-Platform Development

Cross-platform development has gained significant traction in recent years, with frameworks like Flutter and React Native leading the way.

### Flutter

Flutter, Google's UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase, has seen rapid adoption. Its unique approach, using a custom rendering engine, allows for pixel-perfect experiences across platforms.

Key advantages of Flutter include:

- **Hot Reload**: Make changes to your code and see them instantly without losing state
- **Rich Widget Library**: Pre-built widgets that follow Material Design and Cupertino (iOS) guidelines
- **High Performance**: Compiled to native ARM code, providing excellent performance

### React Native

React Native, developed by Facebook, allows developers to use React along with native platform capabilities to build mobile apps. It has a strong community and is widely used for building cross-platform applications.

## Native Development

Despite the rise of cross-platform solutions, native development continues to be important, especially for apps that require:

- Deep integration with platform-specific features
- Maximum performance
- Complex user interfaces

Apple's SwiftUI and Google's Jetpack Compose are modern UI toolkits that make native development more accessible and productive.

## Emerging Technologies

Several emerging technologies are shaping the future of mobile development:

### 5G Connectivity

The rollout of 5G networks will enable:

- Faster data transfer speeds
- Lower latency
- More connected devices

Mobile apps will need to adapt to take advantage of these capabilities, potentially enabling new types of applications and experiences.

### Augmented Reality (AR)

AR technologies like ARKit and ARCore are becoming more sophisticated, enabling developers to create immersive experiences that blend digital content with the real world.

### Machine Learning

On-device machine learning, powered by frameworks like TensorFlow Lite and Core ML, allows developers to incorporate intelligent features without requiring a constant connection to the cloud.

## Conclusion

The future of mobile development looks exciting, with new technologies enabling more powerful, responsive, and intelligent applications. Whether you choose cross-platform or native development, staying current with these trends will be crucial for creating successful mobile apps.
""",
          'imageURL':
              'https://images.unsplash.com/photo-1542435503-956c469947f6',
          'publishedDate': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: 2)),
          ),
          'author': 'John Doe',
          'tags': ['Flutter', 'Mobile', 'Development'],
          'readTimeMinutes': 5,
        },
        {
          'title': 'Building Responsive UIs with Flutter',
          'summary':
              'Learn how to create beautiful, responsive user interfaces that work on any device.',
          'content': """
# Building Responsive UIs with Flutter

Creating responsive user interfaces is essential for providing a great user experience across different screen sizes and orientations. Flutter makes this relatively straightforward with its flexible layout system.

## Understanding Flutter's Layout System

Flutter's layout system is based on widgets. The key widgets for creating responsive layouts include:

- **Row and Column**: For arranging widgets horizontally and vertically
- **Expanded and Flexible**: For controlling how widgets use available space
- **MediaQuery**: For accessing screen dimensions
- **LayoutBuilder**: For creating different layouts based on available space

## Using Flex Layouts

The `Row` and `Column` widgets are flex layouts that arrange their children in a horizontal or vertical line, respectively. Combined with `Expanded` and `Flexible`, they allow for responsive designs.

""",
        },
      ];
    } catch (e) {
      print(e);
    }
  }
}
