import 'package:get/get.dart';

import '../domain/blog/pages/views/blog_details_view.dart';
import '../domain/blog/pages/views/blog_list_view.dart';
import '../domain/blog/pages/views/splash_screen.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(name: Routes.HOME, page: () => BlogListView()),
    GetPage(
      name: Routes.BLOG_DETAIL,
      page: () => BlogDetailView(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
  ];
}
