import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:task_app_fn/constants/colors.dart';

import '../controllers/color_controller.dart';

class ColorPickerDialog extends StatelessWidget {
  final Color initialColor;
  final ColorController colorController;

  const ColorPickerDialog({
    required this.initialColor,
    required this.colorController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color selectedColorValue = initialColor;
    return AlertDialog(
      title: const Text('Chọn màu', style: TextStyle(color: bColor)),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: initialColor,
          onColorChanged: (color) {
            selectedColorValue = color;
          },
          showLabel: true,
          pickerAreaHeightPercent: 0.8,
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text(
            'OK',
            style: TextStyle(color: bColor),
          ),
          onPressed: () {
            colorController.changeColor(selectedColorValue);
            Get.back(result: selectedColorValue);
          },
        ),
      ],
    );
  }
}
