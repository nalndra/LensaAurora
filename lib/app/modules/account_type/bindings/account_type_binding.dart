import 'package:get/get.dart';

import '../controllers/account_type_controller.dart';

class AccountTypeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountTypeController>(
      () => AccountTypeController(),
    );
  }
}
