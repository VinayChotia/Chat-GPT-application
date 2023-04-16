// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'dart:developer';

import 'package:chatgpt_app/constants/constants.dart';
import 'package:chatgpt_app/models/chat_model.dart';
import 'package:chatgpt_app/providers/chats_provider.dart';
import 'package:chatgpt_app/services/api_services.dart';
import 'package:chatgpt_app/services/assets_manager.dart';
import 'package:chatgpt_app/services/services.dart';
import 'package:chatgpt_app/widgets/chat_widget.dart';
import 'package:chatgpt_app/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../providers/models_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;
  late TextEditingController textEditingController;
  late FocusNode focusnode;
  late ScrollController _listScrollController;
  @override
  void initState() {
    textEditingController = TextEditingController();
    focusnode = FocusNode();
    _listScrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusnode.dispose();
    super.dispose();
  }

  // List<ChatModel> chatList = [];

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
        appBar: AppBar(
          elevation: 2,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(AssetsManager.openaiLogo),
          ),
          title: "VinuGpt".text.make(),
          actions: [
            IconButton(
              onPressed: () async {
                await Services.showModalSheet(context: context);
              },
              icon: Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(children: [
            Flexible(
              child: ListView.builder(
                  controller: _listScrollController,
                  itemCount: chatProvider.getchatList.length, //chatList.length,
                  itemBuilder: (context, index) {
                    return ChatWidget(
                      msg: chatProvider
                          .getchatList[index].msg, //chatList[index].msg,
                      chatIndex: chatProvider.getchatList[index]
                          .chatIndex, //chatList[index].chatIndex,
                    );
                  }),
            ),
            if (_isTyping) ...[
              SpinKitThreeBounce(
                color: Colors.white,
                size: 18,
              ),
            ],
            SizedBox(
              height: 15,
            ),
            Material(
              color: cardColor,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: focusnode,
                      style: TextStyle(color: Colors.white),
                      controller: textEditingController,
                      onSubmitted: (value) async {
                        await sendMessageFCT(
                            modelsProvider: modelsProvider,
                            chatProvider: chatProvider);
                      },
                      decoration: InputDecoration.collapsed(
                          hintText: "How Can I Help You",
                          hintStyle: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        await sendMessageFCT(
                            modelsProvider: modelsProvider,
                            chatProvider: chatProvider);
                      },
                      icon: Icon(Icons.send, color: Colors.white))
                ],
              ).p8(),
            )
          ]),
        ));
  }

  void scrollListToEnd() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  Future<void> sendMessageFCT(
      {required ModelsProvider modelsProvider,
      required ChatProvider chatProvider}) async {
    if (_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            label: "Please wait for the previous answer to load",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            label: "Please type something",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      String msg = textEditingController.text;
      setState(() {
        _isTyping = true;
        // chatList.add(ChatModel(msg: textEditingController.text, chatIndex: 0));
        chatProvider.addUserMessage(msg: msg);
        textEditingController.clear();
        focusnode.unfocus();
      });
      await chatProvider.sendMessageAndGetAnswers(
          msg: msg, chosenModelId: modelsProvider.getCurrentModel);
      // chatList.addAll(await ApiService.sendMessage(
      //     message: textEditingController.text,
      //     modelId: modelsProvider.getCurrentModel));
      setState(() {});
    } catch (error) {
      log("error $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            label: error.toString(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        scrollListToEnd();
        _isTyping = false;
      });
    }
  }
}
