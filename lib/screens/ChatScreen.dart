import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:taxi_driver/model/UserDetailModel.dart';
import 'package:taxi_driver/utils/Common.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';

import '../../main.dart';
import '../Services/ChatMessagesService.dart';
import '../model/ChatMessageModel.dart';
import '../model/FileModel.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';
import '../components/ChatItemWidget.dart';

class ChatScreen extends StatefulWidget {
  final UserData? userData;

  ChatScreen({this.userData});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String id = '';
  var messageCont = TextEditingController();
  var messageFocus = FocusNode();
  bool isMe = false;
  late ChatMessageService chatMessageService;
  bool mIsEnterKey = false;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  UserData sender = UserData(
    username: sharedPref.getString(USER_NAME),
    uid: sharedPref.getString(UID),
    playerId: sharedPref.getString(PLAYER_ID),
  );

  init() async {
    String? uid = sharedPref.getString(UID);
    if (uid == null) {
      // Handle the case when UID is null
      // For example, navigate back or show an error message
      Navigator.pop(context);
      return;
    } else {
      id = uid;
    }
    mIsEnterKey = sharedPref.getBool(IS_ENTER_KEY) ?? false;
    chatMessageService = ChatMessageService();
    if (widget.userData != null) {
      log('${widget.userData} jjjj');
      chatMessageService.setUnReadStatusToTrue(
          senderId: sender.uid!, receiverId: widget.userData!.uid!);
    } else {
      // Handle the case when userData is null
      // For example, navigate back or show an error message
      Navigator.pop(context);
      return;
    }
    setState(() {
      isInitialized = true;
    });
  }

  sendMessage({FilePickerResult? result}) async {
    if (result == null && messageCont.text.trim().isEmpty) {
      messageFocus.requestFocus();
      return;
    }

    ChatMessageModel data = ChatMessageModel();
    data.receiverId = widget.userData!.uid!;
    data.senderId = sender.uid;
    data.message = messageCont.text;
    data.isMessageRead = false;
    data.createdAt = DateTime.now().millisecondsSinceEpoch;

    if (result != null) {
      data.messageType = result.files.single.path!.isNotEmpty
          ? MessageType.IMAGE.name
          : MessageType.TEXT.name;
    } else {
      data.messageType = MessageType.TEXT.name;
    }

    try {
      await notificationService.sendPushNotifications(
          sharedPref.getString(USER_NAME)!, messageCont.text,
          receiverPlayerId: widget.userData!.playerId);
    } catch (e) {
      log(e);
    }

    messageCont.clear();
    setState(() {});

    final messageDoc = await chatMessageService.addMessage(data);
    if (result != null) {
      FileModel fileModel = FileModel();
      fileModel.id = messageDoc.id;
      fileModel.file = File(result.files.single.path!);
      fileList.add(fileModel);
      setState(() {});
    }

    await chatMessageService.addMessageToDb(
      messageDoc,
      data,
      sender,
      widget.userData,
    );

    final updateTime = DateTime.now().millisecondsSinceEpoch;

    final userCollection = userService.fireStore.collection(USER_COLLECTION);
    await Future.wait([
      userCollection
          .doc(sharedPref.getInt(USER_ID).toString())
          .collection(CONTACT_COLLECTION)
          .doc(widget.userData!.uid)
          .update({'lastMessageTime': updateTime}),
      userCollection
          .doc(widget.userData!.uid)
          .collection(CONTACT_COLLECTION)
          .doc(sharedPref.getInt(USER_ID).toString())
          .update({'lastMessageTime': updateTime}),
    ]).catchError((e) {
      log(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return Center(
          child: CircularProgressIndicator(
        color: Colors.red,
      ));
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            SizedBox(width: 8),
            ClipRRect(
                borderRadius: BorderRadius.all(radiusCircular(20)),
                child: commonCachedNetworkImage(
                    widget.userData!.profileImage.validate(),
                    height: 40,
                    width: 40)),
            SizedBox(width: 8),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(widget.userData!.username.validate(),
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: primaryColor,
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 76),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: PaginateFirestore(
              reverse: true,
              isLive: true,
              padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
              physics: BouncingScrollPhysics(),
              query: chatMessageService.chatMessagesWithPagination(
                  currentUserId: sharedPref.getString(UID),
                  receiverUserId: widget.userData!.uid!),
              itemsPerPage: PER_PAGE_CHAT_COUNT,
              shrinkWrap: true,
              onEmpty: Offstage(),
              itemBuilderType: PaginateBuilderType.listView,
              itemBuilder: (context, snap, index) {
                ChatMessageModel data = ChatMessageModel.fromJson(
                    snap[index].data() as Map<String, dynamic>);
                data.isMe = data.senderId == sender.uid;
                return ChatItemWidget(data: data);
              },
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: radius(),
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 0.2,
                    blurRadius: 0.2,
                  ),
                ],
              ),
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageCont,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: language.writeMessage,
                        hintStyle: secondaryTextStyle(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      cursorColor:
                          appStore.isDarkMode ? Colors.white : Colors.black,
                      focusNode: messageFocus,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      style: primaryTextStyle(),
                      textInputAction: mIsEnterKey
                          ? TextInputAction.send
                          : TextInputAction.newline,
                      onSubmitted: (s) {
                        sendMessage();
                      },
                      maxLines: 5,
                    ),
                  ),
                  inkWellWidget(
                    child: Icon(Icons.send, color: primaryColor, size: 25),
                    onTap: () {
                      sendMessage();
                    },
                  )
                ],
              ),
              width: MediaQuery.of(context).size.width,
            ),
          )
        ],
      ),
    );
  }
}
