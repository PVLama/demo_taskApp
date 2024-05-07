import 'package:get/get.dart';
import 'package:task_app_fn/screens/home_screen.dart';

import '../bindings/task_binding.dart';
import '../screens/my_task_screen.dart';

class AppRoutes{
  static const String home = '/';
  static const String addTask = '/addTask';
}
class AppPages{
  static final pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => HomeScreen(),
      binding: TaskBinding(),
    ),
    GetPage(
      name: AppRoutes.addTask,
      page: () => MyTask(),
      binding: TaskBinding(),
    ),
  ];
}