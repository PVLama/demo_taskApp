import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../constants/colors.dart';

class ColorController extends GetxController {
  static ColorController get to => Get.find();
  final selectedColor = Rx<Color>(bColor);

  @override
  void onInit() {
    super.onInit();
    loadColor();
  }

  void changeColor(Color color) {
    selectedColor.value = color;
    saveColor(color);
  }

  Color getColor() => selectedColor.value;

  Future<void> saveColor(Color color) async {
    final storage = GetStorage();
    await storage.write('selected_color', color.value);
    update();
  }

  Future<void> loadColor() async {
    final storage = GetStorage();
    final int? colorValue = storage.read('selected_color');
    if (colorValue != null) {
      selectedColor.value = Color(colorValue);
    }
  }
}
