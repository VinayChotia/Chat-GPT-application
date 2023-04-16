// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:chatgpt_app/widgets/drop_down.dart';
import 'package:chatgpt_app/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../constants/constants.dart';

class Services {
  static Future<void> showModalSheet({required BuildContext context}) async {
    await showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        )),
        backgroundColor: scaffoldBackgroundColor,
        context: context,
        builder: (context) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: TextWidget(
                  label: "Chosen Modal:",
                  fontSize: 16,
                ),
              ),
              Flexible(flex: 2, child: ModelsDrowDownWidget()),
            ],
          ).p16();
        });
  }
}
