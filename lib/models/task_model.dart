import 'dart:ui';

import 'package:flutter/material.dart';

class TaskModel {
  String? title;
  String? des;
  bool done;
  DateTime? datetime;
  dynamic color;

  TaskModel({
    this.title,
    this.des,
    this.done = false,
    this.datetime,
    this.color,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      title: json['title'],
      des: json['description'],
      done: json['done'] ?? false,
      datetime: json['datetime'] != null
          ? DateTime.parse(json['datetime'])
          : DateTime.now(),
      color: _parseColor(json['color']),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': des,
        'done': done,
        'datetime': datetime?.toString(),
        'color': _serializeColor(color),
      };

  static Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    final hexColor = colorString.startsWith('Color(')
        ? colorString.substring(6, colorString.length - 1)
        : colorString;
    final colorValue = int.tryParse(hexColor, radix: 16);
    return colorValue != null ? Color(colorValue) : null;
  }

  static String? _serializeColor(Color? color) {
    return color != null ? 'Color(${color.value})' : null;
  }

}
