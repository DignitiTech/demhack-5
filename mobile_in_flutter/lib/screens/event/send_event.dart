/**
 *  Copyright (C) 2022 Digniti Tech OÜ.  All rights reserved.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:x_app/domain/models/activity/event_activity.dart';
import 'package:x_app/domain/models/contacts/contact.dart';
import 'package:x_app/domain/models/event/event_model.dart';
import 'package:x_app/domain/models/message/message.dart';
import 'package:x_app/providers/activity/providers.dart';
import 'package:x_app/providers/chat/providers.dart';
import 'package:x_app/providers/main/providers.dart';
import 'package:x_app/providers/message/providers.dart';
import 'package:x_app/providers/settings/providers.dart';
import 'package:x_app/ui_utils/colors.dart';
import 'package:x_app/utils/enum.dart';
import 'package:x_app/widgets/buttons.dart';
import 'package:x_app/extensions/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_app/widgets/messenger_cell.dart';
import 'package:x_app/widgets/pop_view_top.dart';
import 'package:x_app/widgets/profile_photo_view.dart';

class SendEvent extends StatefulWidget {
  const SendEvent({
    required this.contacts,
    required this.eventModel,
  });

  final List<Contact> contacts;
  final EventModel eventModel;

  @override
  _SendEvent createState() => _SendEvent();
}

class _SendEvent extends State<SendEvent> {
  late List<Widget> contacts;


  Future<Uint8List?>? getMyIng() async {
    return context.read(profileImg).img;
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.read(profileProvider)!;
    final userImg = getMyIng();
    contacts = [];
    for (Contact contact in widget.contacts) {
      contacts.add(
        Container(
          height: 40,
          width: 40,
          child: ProfilePhotoView(
            profileName: contact.getName(),
            isOnline: contact.profiler.isActive,
            futurePhoto: contact.getPreviewImg(context),
            size: 40,
          ),
        ),
      );

      if (contacts.length == 8) {
        if (widget.contacts.length == 5) {
          contacts.add(
            Container(
              height: 40,
              width: 40,
              child: ProfilePhotoView(
                profileName: contact.getName(),
                isOnline: contact.profiler.isActive,
                futurePhoto: contact.getPreviewImg(context),
                size: 40,
              ),
            ),
          );
        } else {
          contacts.add(
            Container(
                height: 40,
                width: 40,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SYSTEM_BLUE,
                  ),
                  child: Center(
                    child: Text(
                      '+${widget.contacts.length - 4}',
                      style: Theme.of(context).textTheme.xMediumSmallText14,
                    ),
                  ),
                )
            ),
          );
        }
        break;
      }
      contacts.add(const SizedBox(width: 16));
    }

    return Material(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 44,
                child: Stack(
                  children: [
                    PopViewTop(),
                    Container(
                      alignment: Alignment.topLeft,
                      child: AppleTextButton(
                        title: 'Close',
                        textStyle: Theme.of(context).textTheme.regularLink,
                        callback: () async {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  // shrinkWrap: true,
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Send a Message',
                        style: Theme.of(context).textTheme.displaySecond,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Container(
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Send an Invitation Messsage to selected participants. You can write a message or use the one provided.',
                        style: Theme.of(context).textTheme.regularParagraphText,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...contacts,
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    SomeoneEventCell(
                      someoneName: profile.name,
                      myName: 'Name',
                      eventModel: widget.eventModel,
                      myMessage: false,
                      dateTime: DateTime.now(),
                      backAccountColor: SYSTEM_BLUE,
                      createUserIcon: true,
                      createInvite: false,
                      topDate: null,
                      lastMessage: false,
                      previousMessageMy: true,
                      longPress: (size, position, i) {},
                      userImg: userImg,
                      createTime: false,
                      isActive: profile.isActive,
                      status: MessageStatus.DELIVERED,
                      accenpt: true,
                      callback: (){},
                    ),

                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: AppleButton(
                          text: 'Edit Message',
                          backgroundColor: SYSTEM_WHITE,
                          textStyle: Theme.of(context).textTheme.regularSemiBoldLink,
                          callback: () async {},
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppleButton(
                      text: 'Send',
                      backgroundColor: SYSTEM_BLUE,
                      textStyle: Theme.of(context).textTheme.semiBoldButton,
                      callback: () async {
                        for (Contact contact in widget.contacts) {
                          final direct = context.read(directsProvider).getDirectByUserAddress(contact.profiler.userAddress)!;
                          final id = 'msgId_' + DateTime.now().millisecondsSinceEpoch.toString();
                          final firstMessage = direct.lastMessage == null;

                          final msg = Message(
                            directId: direct.directId,
                            messageId: id,
                            type: MessageType.Event,
                            ownerAddress: profile.userAddress,
                            messageText: json.encode(widget.eventModel),
                            status: MessageStatus.SENDING,
                            sendingTime: DateTime.now().toUtc(),
                          );

                          if(direct.hideDirect) {
                            direct.hideDirect = false;
                          }

                          final activity = EventActivity(
                            eventActivityId: id,
                            event: widget.eventModel,
                            contactId: direct.contactId,
                            myNotification: false,
                            hideNotification: true,
                          );

                          await context.read(eventActivitiesProvider.notifier).addEventActivity(activity);

                          direct.lastMessage = msg;
                          await context.read(messagesProvider(direct.directId).notifier).addMessage(direct.idListMessage, msg, direct);
                          await context.read(directsProvider.notifier).updateChatState(direct);

                          context.read(messengerStateNotifierProvider.notifier).sendMessage(
                            direct,
                            msg,
                            firstMsg: firstMessage,
                          );

                        }

                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        context.read(bottomNotifierProvider.notifier).openNotification('', 'Event added to your ', 'Schedule', 'scheduleNotif', 74);

                      },
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}
