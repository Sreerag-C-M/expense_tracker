import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:test_application/app/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 2), () {
      final box = GetStorage();
      if (box.hasData('token')) {
        Get.offNamed(Routes.DASHBOARD);
      } else {
        Get.offNamed(Routes.LOGIN);
      }
    });
  }
}
