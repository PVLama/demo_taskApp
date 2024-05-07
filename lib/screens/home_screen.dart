import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_app_fn/constants/colors.dart';
import 'package:task_app_fn/controllers/task_controller.dart';
import 'package:task_app_fn/models/task_model.dart';
import 'package:task_app_fn/routers/app_router.dart';

import '../constants/app_assets.dart';

// ignore: must_be_immutable
class HomeScreen extends StatelessWidget{

  final TaskController taskController = Get.put(TaskController());
  TextEditingController searchController = TextEditingController();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskController>(
      builder: (cont) {
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: bgrColor,
          appBar: buildAppBar(),
          body: Stack(children: [
            Column(
              children: [
                buildSearchBox(taskController),
                Expanded(
                  child: taskController.tasks.isEmpty
                      ? Container(
                          color: wColor,
                          height: MediaQuery.of(context).size.width,
                          width: MediaQuery.of(context).size.width,
                          child: Image.asset(
                            AppAssets.homeImage,
                            fit: BoxFit.fitWidth,
                          ),
                        )
                      : buildTaskList(taskController),
                ),
              ],
            ),
            Positioned(
              right: 40,
              bottom: 40,
              child: InkWell(
                onTap: () async {
                   await Get.toNamed(AppRoutes.addTask);
                },
                child: Container(
                  width: 45,
                  decoration: BoxDecoration(
                      color: blueColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Center(
                    child: Text(
                      "+",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                          color: wColor),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      );
    });
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: greyColor,
      leading: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.menu_outlined,
            size: 25,
          )),
      actions: [
        IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              size: 25,
            ))
      ],
    );
  }

  Widget buildSearchBox(TaskController taskController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      margin: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
          color: wColor, borderRadius: BorderRadius.all(Radius.circular(15))),
      child: TextField(
        controller: searchController,
        onChanged: (query) {
            taskController.searchTask(query);
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0),
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: bColor,
          ),
          prefixIconConstraints:
              const BoxConstraints(maxHeight: 20, maxWidth: 25),
          border: InputBorder.none,
          hintText: "Tìm kiếm...",
          hintStyle: TextStyle(
            color: bColor.withOpacity(0.5),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget buildTaskList(TaskController taskController,) => ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: taskController.tasks.length,
        itemBuilder: (BuildContext context, int index) {
          final taskModel = taskController.tasks[index];
          final title = taskModel.title ?? '';
          final des = taskModel.des ?? '';
          final desText = taskController.jsonToDocument(des).toPlainText();
          final colorChoose = taskModel.color ?? bColor;

          final searchText = searchController.text.toLowerCase();
          final titlePlainText = title.toLowerCase();

          int startIndex = titlePlainText.indexOf(searchText);
          if (startIndex != -1) {
            final endIndex = startIndex + searchText.length;
            final part1 = title.substring(0, startIndex);
            final part2 = title.substring(startIndex, endIndex);
            final part3 = title.substring(endIndex);

            return Container(
              decoration: BoxDecoration(
                  color: taskModel.done == true
                      ? greyColor.withOpacity(0.6)
                      : wColor,
                  borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
              child: Dismissible(
                onDismissed: (direction) {
                  taskController.deleteTask(index: index);
                },
                key: UniqueKey(),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: redColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.only(right: 30),
                  child: const Icon(
                    Icons.delete_outline,
                    color: wColor,
                    size: 30,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      onTap: () {
                        Get.toNamed(AppRoutes.addTask, arguments: index);
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      leading: Checkbox(
                        activeColor: blueColor,
                        value: taskModel.done,
                        onChanged: (value) {
                          final updateTask = TaskModel(
                              title: taskModel.title,
                              des: taskModel.des,
                              done: value ?? false,
                              datetime: taskModel.datetime,
                              color: taskModel.color ?? bColor);
                          taskController.updateTask(
                              index: index, taskModel: updateTask);
                        },
                      ),
                      trailing: Icon(
                        Icons.bookmark,
                        size: 25,
                        color: taskModel.done
                            ? colorChoose.withOpacity(0.3)
                            : colorChoose,
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: part1,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                  color: taskModel.done == true
                                      ? bColor.withOpacity(0.3)
                                      : bColor,
                                ),
                              ),
                              TextSpan(
                                text: part2,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange),
                              ),
                              TextSpan(
                                text: part3,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                  color: taskModel.done == true
                                      ? bColor.withOpacity(0.3)
                                      : bColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          desText,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: taskModel.done == true
                                ? bColor.withOpacity(0.3)
                                : bColor,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 15),
                      child: Text(
                        DateFormat('d MMM y, HH:mm', 'vi')
                            .format(taskModel.datetime!),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: taskModel.done == true
                              ? bColor.withOpacity(0.3)
                              : bColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        });
}
