import 'package:get/get.dart';

import '../theme/theme_service.dart';
import '../../domain/blog/controller/blog_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Register services
    Get.put(ThemeService());

    // Register controllers
    Get.put(BlogController(), permanent: true);
  }
}
