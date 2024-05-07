import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/colors.dart';
import '../models/task_model.dart';
import 'color_controller.dart';

class TaskController extends GetxController with StateMixin<List<TaskModel>> {
  final GetStorage box = GetStorage();
  final _tasks =  <TaskModel>[];
  List<TaskModel> get tasks => _tasks.toList();
  final selectedColor = Rx<Color>(bColor);
  final image = Rx<File>(File(''));

  ColorController colorController = Get.put(ColorController());
  TextEditingController titleController = TextEditingController();
  TextEditingController desController = TextEditingController();
  QuillController quillController = QuillController.basic();
  FocusNode focusNode = FocusNode();
  int? index = Get.arguments;

  TaskModel? taskModel;
  var totalCharacter = 0;
  var hasData = false;
  var isNewTask = false;
  var isDarkMode = false;

  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    loadAllTasks();
    changeUI();
  }

  void updateState() {
      final titleLength = titleController.text.length;
      final desLength = countCharactersFromQuillJson(jsonEncode(quillController.document.toDelta().toJson()));
      final totalLength = titleLength + desLength;
      totalCharacter = totalLength;
      hasData = titleLength > 0 || desLength > 0;
      colorController.changeColor(selectedColor.value);
  }

  @override
  void onClose() {
    titleController.dispose();
    desController.dispose();
    quillController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  void clearState() {
    titleController.clear();
    desController.clear();
    quillController.clear();
    colorController.getColor();
  }

  Document jsonToDocument(String jsonString) {
    final delta = Delta.fromJson(jsonDecode(jsonString));
    return Document.fromDelta(delta);
  }

  String documentToJson(Document document) {
    final delta = document.toDelta();
    return jsonEncode(delta.toJson());
  }

  int countCharactersFromQuillJson(String quillJson) {
    final List<dynamic> quillDelta = jsonDecode(quillJson);
    int characterCount = 0;
    bool foundLastNewLine = false;

    for (final item in quillDelta) {
      if (item is Map && item.containsKey('insert')) {
        final dynamic insertValue = item['insert'];
        if (insertValue is String) {
          if (!foundLastNewLine) {
            final int newLineIndex = insertValue.lastIndexOf('\n');
            if (newLineIndex == -1) {
              characterCount += insertValue.length;
            } else {
              characterCount += newLineIndex;
              foundLastNewLine = true;
            }
          }
        }
      }
    }
    return characterCount;
  }

  void loadAllTasks() {
    final storedTasks = box.read<List>('tasks');
    if (storedTasks != null) {
      final tasksList = storedTasks.map((task) => TaskModel.fromJson(task)).toList();
      _tasks.assignAll(tasksList);
      update();
    }
  }

  Future<void> savedAllTasks() async {
    final tasksList = tasks.map((task) => task.toJson()).toList();
    await box.write('tasks', tasksList);
    update();
  }

  void addTask({required TaskModel taskModel}) async {
    _tasks.insert(0, taskModel);
    isNewTask = true;
    await savedAllTasks();
    print("Thêm mới thành công");
  }

  void updateTask({required int index, required TaskModel taskModel}) {
    if (index >= 0 && index < tasks.length) {
      _tasks[index] = taskModel;
      _tasks.removeAt(index);
      _tasks.insert(0, taskModel);
      savedAllTasks();
      print("cập nhật thành công");
    } else {
      print("Cập nhật không hợp lệ");
    }
  }

  void deleteTask({required int index}) {
    if (index >= 0 && index < tasks.length) {
      _tasks.removeAt(index);
      savedAllTasks();
      print("Xóa thành công");
    } else {
      print("Xóa không hợp lệ");
    }
  }

  List<TaskModel> searchTask(String query) {
    final lowerQuery = query.toLowerCase();
    if (lowerQuery.isEmpty) {
      loadAllTasks();
      return tasks;
    }
    final foundTasks = tasks.where((taskModel) {
      final lowerTitle = taskModel.title?.toLowerCase() ?? '';
      return lowerTitle.contains(lowerQuery);
    }).toList();
    update();
    return foundTasks;
  }

  Future imagePicker() async {
    try{
      final imagePick = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(imagePick == null){
        return;
      }
      final imageTemp = File(imagePick.path);
      image.value = imageTemp;
    } on PlatformException catch (e){
      return e;
    }
  }

  changeUI() {
    change(_tasks, status: RxStatus.success());
  }

}
