import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'src/routes/app_pages.dart';
import 'src/domain/blog/controller/blog_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  // Initialize deep linking
  await initDynamicLinks();

  runApp(MyApp());
}

Future<void> initDynamicLinks() async {
  // Get initial dynamic link if the app is opened with a dynamic link
  final PendingDynamicLinkData? data =
      await FirebaseDynamicLinks.instance.getInitialLink();

  // Handle link that opened the app
  if (data != null) {
    _handleDynamicLink(data);
  }

  // Listen for dynamic links while the app is in the foreground
  FirebaseDynamicLinks.instance.onLink
      .listen((dynamicLinkData) {
        _handleDynamicLink(dynamicLinkData);
      })
      .onError((error) {
        print('Dynamic Link Error: $error');
      });
}

void _handleDynamicLink(PendingDynamicLinkData data) {
  final Uri deepLink = data.link;

  // Example: https://yourdomain.com/blog/123
  final List<String> pathSegments = deepLink.pathSegments;

  if (pathSegments.length >= 2 && pathSegments[0] == 'blog') {
    final String blogId = pathSegments[1];

    // Set the selected blog ID in the controller
    final BlogController controller = Get.find<BlogController>();
    controller.selectedBlogId.value = blogId;

    // Navigate to the blog detail page
    Get.toNamed(Routes.BLOG_DETAIL.replaceAll(':id', blogId));
  }
}
