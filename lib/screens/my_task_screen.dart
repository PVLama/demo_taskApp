import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_app_fn/controllers/task_controller.dart';
import 'package:task_app_fn/models/task_model.dart';

import '../constants/colors.dart';
import '../widgets/color_picker_dialog.dart';

class MyTask extends StatefulWidget {
  MyTask({
    super.key,
  });

  @override
  State<MyTask> createState() => _MyTaskState();
}

class _MyTaskState extends State<MyTask> {
  final TaskController taskController = Get.find();
  int? index = Get.arguments;

  @override
  void initState() {
    super.initState();
    if (index != null) {
      taskController.taskModel = taskController.tasks[index!];
      if (taskController.taskModel != null) {
        taskController.titleController.text = taskController.taskModel?.title ?? '';
        taskController.quillController.document = taskController.jsonToDocument(taskController.taskModel!.des ?? '');
        taskController.colorController.changeColor(taskController.taskModel?.color ?? bColor);
        taskController.taskModel?.color = taskController.colorController.getColor();
      }
      taskController.isNewTask = false;
    } else {
     taskController. isNewTask = true;
      taskController.clearState();
    }
    taskController.quillController.addListener(_updateControllers);
    taskController.titleController.addListener(_updateControllers);
  }
  void _updateControllers() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      taskController.updateState();
      taskController.update();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
          child: taskController.obx((state) => Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.keyboard_backspace,
                  size: 25,
                ),
                onPressed: () {
                  Get.back();
                },
              ),
              actions: [
                Row(children: [
                  IconButton(
                    icon: const Icon(Icons.undo),
                    onPressed: () {
                      taskController.quillController.undo();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.redo),
                    onPressed: () {
                      taskController.quillController.redo();
                    },
                  ),
                ]),
                IconButton(
                  onPressed: () async {
                    final selectedColor = await Get.dialog<Color>(
                      ColorPickerDialog(
                        initialColor: taskController.taskModel?.color ??
                            taskController.colorController.getColor(),
                        colorController: taskController.colorController,
                      ),
                    );
                    if (selectedColor != null) {
                      taskController.colorController.changeColor(selectedColor);
                      if (taskController.taskModel != null) {
                        taskController.taskModel?.color = selectedColor;
                        taskController.update();
                      }
                    }
                  },
                  icon: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.bookmark,
                      size: 25,
                      color: taskController.taskModel?.color ??
                          taskController.colorController.getColor(),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Text(
                    "Xong",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      color: bColor,
                    ),
                  ),
                ),
                Visibility(
                  visible: taskController.hasData,
                  child: IconButton(
                    onPressed: () {
                      final title = taskController.titleController.text;
                      final desJson = taskController.documentToJson(
                          taskController.quillController.document);
                      final updatedDateTime = DateTime.now();
                      if (index != null) {
                        final updateTask = TaskModel(
                          title: title,
                          des: desJson,
                          done: false,
                          datetime: updatedDateTime,
                          color: taskController
                              .colorController.selectedColor.value,
                        );
                        taskController.updateTask(
                            index: index!, taskModel: updateTask);
                      } else {
                        final newTask = TaskModel(
                          title: title,
                          des: desJson,
                          done: false,
                          datetime: updatedDateTime,
                          color: taskController
                              .colorController.selectedColor.value,
                        );
                        taskController.addTask(taskModel: newTask);
                      }
                      Get.back();
                    },
                    icon: const Icon(
                      Icons.check,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: QuillToolbar.simple(
                      configurations: QuillSimpleToolbarConfigurations(
                        controller: taskController.quillController,
                        showFontFamily: false,
                        showStrikeThrough: false,
                        showQuote: false,
                        showHeaderStyle: false,
                        showLink: false,
                        showSearchButton: false,
                        showBackgroundColorButton: false,
                        showCodeBlock: false,
                        showInlineCode: false,
                        showUndo: false,
                        showRedo: false,
                        showDividers: false,
                        showSmallButton: false,
                        showSubscript: false,
                        showSuperscript: false,
                      ),
                    ),
                  ),
                  TextField(
                    controller: taskController.titleController,
                    // onChanged: (value){
                    //   taskController.updateState();
                    //   taskController.update();
                    // },
                    maxLines: null,
                    expands: false,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      hintText: "Tiêu đề",
                      hintStyle: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.5,
                        color: bColor.withOpacity(0.3),
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 25, letterSpacing: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        Text(
                          DateFormat('d MMM y, HH:mm', 'vi')
                              .format(DateTime.now()),
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: bColor,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 10, left: 10),
                          height: 15,
                          width: 1.5,
                          color: bColor.withOpacity(0.6),
                        ),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "${taskController.totalCharacter} ký tự",
                              style: TextStyle(
                                  fontSize: 12, color: bColor.withOpacity(0.6)),
                            )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 500,
                    child: QuillEditor(
                      configurations: QuillEditorConfigurations(
                        controller: taskController.quillController,
                        padding: const EdgeInsets.all(8),
                        autoFocus: true,
                        scrollable: true,
                        readOnly: false,
                        expands: false,
                        placeholder: 'Bắt đầu soạn...',
                      ),
                      scrollController: ScrollController(),
                      focusNode: taskController.focusNode,
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
