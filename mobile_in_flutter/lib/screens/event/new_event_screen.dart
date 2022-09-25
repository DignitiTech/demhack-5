/**
 *  Copyright (C) 2022 Digniti Tech OÜ.  All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:x_app/domain/models/contacts/contact.dart';
import 'package:x_app/domain/models/event/event_model.dart';
import 'package:x_app/providers/settings/providers.dart';
import 'package:x_app/screens/evet/send_event.dart';
import 'package:x_app/screens/settings/edit/edit_access_add_users.dart';
import 'package:x_app/ui_utils/animation_speed.dart';
import 'package:x_app/ui_utils/colors.dart';
import 'package:x_app/widgets/buttons.dart';
import 'package:x_app/extensions/theme_extensions.dart';
import 'package:x_app/widgets/calendar.dart';
import 'package:x_app/widgets/edit_settings_custom_block.dart';
import 'package:x_app/widgets/scaffold_factory.dart';
import 'package:x_app/widgets/small_contact_view.dart';

class CreateNewEventScreen extends StatefulWidget {
  @override
  _CreateNewEventScreen createState() => _CreateNewEventScreen();
}

class _CreateNewEventScreen extends State<CreateNewEventScreen> {
  final TextEditingController nameController = TextEditingController(text: '');
  final TextEditingController typeController = TextEditingController(text: '');
  final TextEditingController descriptionController = TextEditingController(text: '');

  List<Contact> selectedUsers = [];
  bool keyBoardOpen = false;
  double keyBoardHeight = 0.0;
  final ScrollController _scrollController = ScrollController();
  double startPosition = 0.0;
  late double viewHeight;
  double textFieldPosition = 0.0;

  late double height;

  final GlobalKey textFiledNameGlobalKey = GlobalKey();
  final GlobalKey textFiledTypeGlobalKey = GlobalKey();
  final GlobalKey textFiledDescriptionGlobalKey = GlobalKey();


  @override
  Widget build(BuildContext context) {
    final profile = context.read(profileProvider)!;
    final startDate = DateTime.now();
    final endDate = DateTime(startDate.year, startDate.month, startDate.day, startDate.hour + 1, startDate.minute, startDate.second);

    viewHeight = MediaQuery.of(context).size.height;

    return Material(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          keyBoardOpen = false;
          updateKeyboardHeight();
          setState(() {});
        },
        child: ScaffoldView(Theme.of(context).platform).build(
          background: SYSTEM_WHITE,
          middle: Text(
            'New Event',
            style: Theme.of(context).textTheme.regularSemiBold,
          ),
          title: Text(
            'New Event',
            style: Theme.of(context).textTheme.regularSemiBold,
          ),
          androidLeading: AndroidBackButton(callback: () {
            Navigator.of(context).pop();
          }),
          iosLeading: AppleBackButton(
            callback: () => {Navigator.of(context).pop()},
            textStyle: Theme.of(context).textTheme.textButton,
          ),
          iosTrailing: AppleTextButton(
            title:  'Create',
            rightOffset: 0,
            leftOffset: 12,
            textStyle: (selectedUsers.length != 0 && nameController.text.isNotEmpty) ? Theme.of(context).textTheme.regularSemiBoldLink : Theme.of(context).textTheme.regularSemiBoldNotActive,
            callback: () {
              if (selectedUsers.length != 0 && nameController.text.isNotEmpty) {
                final eventModel = EventModel(
                    name: nameController.text,
                    message:  'Hello, @Name The application for participation of your team has passed the competitive selection and we invite to become a member of the ${nameController.text}.',
                    type: typeController.text,
                    description: descriptionController.text,
                    startDate: startDate,
                    endDate: endDate,
                    timeZone: null,
                );
                showCupertinoModalBottomSheet(
                  useRootNavigator: true,
                  context: context,
                  barrierColor: SYSTEM_TEXT_DARK_GRAY,
                  builder: (context) => SendEvent(
                    contacts: selectedUsers,
                    eventModel: eventModel,
                  ),
                );
              }
            },
          ),
          child: SafeArea(
            child: ListView(
              controller: _scrollController,
              shrinkWrap: true,
              physics: _keyboardVisible() ? NeverScrollableScrollPhysics() : null,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      height: 102,
                      width: 102,
                      child: SvgPicture.asset(
                        'assets/img/eventTaskButton.svg',
                      ),
                    ),
                    AppleTextButton(
                      title: 'EDIT COVER',
                      textStyle: Theme.of(context).textTheme.xSmallTAG.copyWith(color: SYSTEM_BLUE),
                      callback: () {},
                    ),

                    const SizedBox(height: 16),

                    Container(
                      color: SYSTEM_WHITE,
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ABOUT',
                        style: Theme.of(context).textTheme.xSmallTAG,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          color: SYSTEM_BACKGROUND_ONE,
                        ),
                        child: TextField(
                          key: textFiledNameGlobalKey,
                            style: Theme.of(context).textTheme.regularParagraphText,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: SYSTEM_CLEAR,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: InputBorder.none,
                              hintText: 'Name',
                              hintStyle: Theme.of(context).textTheme.regularGrayText,
                            ),
                            controller: nameController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 1,
                            onTap: (){
                              keyBoardOpen = true;
                              RenderBox box = textFiledNameGlobalKey.currentContext!.findRenderObject() as RenderBox;
                              height = box.size.height;
                              Offset position = box.localToGlobal(Offset.zero);
                              startPosition = _scrollController.position.pixels.abs();
                              textFieldPosition = position.dy;
                              setState(() {});
                            },
                            onChanged: (text){
                              setState(() {});
                            },
                          ),
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      height: 0.5,
                      child: Container(
                        color: SYSTEM_BACKGROUND_ONE,
                        child: Divider(
                          height: 0,
                          thickness: 0.5,
                          color: SYSTEM_OPAQUE_SEPARATOR,
                          indent: 16,
                          endIndent: 0,
                        ),
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          color: SYSTEM_BACKGROUND_ONE,
                        ),
                        child: TextField(
                          key: textFiledTypeGlobalKey,
                            style: Theme.of(context).textTheme.regularParagraphText,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: SYSTEM_CLEAR,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: InputBorder.none,
                              hintText: 'Type',
                              hintStyle: Theme.of(context).textTheme.regularGrayText,
                            ),
                            controller: typeController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 1,
                          onTap: (){
                            keyBoardOpen = true;
                            RenderBox box = textFiledTypeGlobalKey.currentContext!.findRenderObject() as RenderBox;
                            height = box.size.height;
                            Offset position = box.localToGlobal(Offset.zero);
                            startPosition = _scrollController.position.pixels.abs();
                            textFieldPosition = position.dy;
                            setState(() {});
                          },
                            onChanged: (text){
                              setState(() {});
                            },
                          ),
                        // ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      key: textFiledDescriptionGlobalKey,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: SYSTEM_BACKGROUND_ONE,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: 44.0,
                            maxHeight: 124.0,
                          ),
                          child: TextField(
                            style: Theme.of(context).textTheme.regularParagraphText,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: SYSTEM_CLEAR,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              border: InputBorder.none,
                              hintText: 'Description',
                              hintStyle:
                              Theme.of(context).textTheme.regularGrayText,
                            ),
                            controller: descriptionController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            onTap: (){
                              keyBoardOpen = true;
                              RenderBox box = textFiledDescriptionGlobalKey.currentContext!.findRenderObject() as RenderBox;
                              height = box.size.height;
                              Offset position = box.localToGlobal(Offset.zero);
                              startPosition = _scrollController.position.pixels.abs();
                              textFieldPosition = position.dy;
                              setState(() {});
                            },
                            onChanged: (text) {
                              RenderBox box = textFiledDescriptionGlobalKey.currentContext!.findRenderObject() as RenderBox;
                              if (height != box.size.height) {
                                height = box.size.height;
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      color: SYSTEM_WHITE,
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'DETAILS',
                        style: Theme.of(context).textTheme.xSmallTAG,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          EditSettingsCustomWidget(
                            title: 'Schedule',
                            subTitle: timeIntervalString(startDate, endDate),
                            smallImg: 'profile',
                            callbackHeader: () {},
                            children: [
                              if (profile.showCountry() || profile.showCity()) ButtonForEventSmall(
                                title: 'Time zone',
                                subTitle: profile.showCountry() ? '${profile.country!.country}' : '' + ', ${profile.showCity() ? ', ${profile.administrativeArea}' : ''}',
                                topFlat: true,
                                bottomFlat: true,
                                callback: () {},
                              ),

                              ButtonForEventSmall(
                                title: 'Repeat',
                                subTitle: 'Never',
                                topFlat: true,
                                bottomFlat: true,
                                callback: () {},
                              ),

                              ButtonForEventSmall(
                                title: 'Reminder',
                                leftOffsetSubTitle: 75,
                                subTitle: '1 hour before',
                                topFlat: true,
                                bottomFlat: false,
                                callback: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    DignitiButton(
                      title: 'Add Location',
                      img: 'locationTaskButtonWhite',
                      smallImg: false,
                      height: 56,
                      callback: () async {},
                    ),

                    const SizedBox(height: 12),

                    DignitiButton(
                      title: 'Add Link',
                      img: 'linksTaskButtonWhite',
                      smallImg: false,
                      height: 56,
                      callback: () async {},
                    ),

                    const SizedBox(height: 16),

                    Container(
                      color: SYSTEM_WHITE,
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'INVITEES',
                        style: Theme.of(context).textTheme.xSmallTAG,
                      ),
                    ),

                    const SizedBox(height: 12),

                    if(selectedUsers.isNotEmpty) DignitiButton(
                      title: 'Participants',
                      rightText: '${selectedUsers.length}',
                      img: 'contactIcon',
                      smallImg: false,
                      bottomFlat: true,
                      height: 56,
                      dividerOffset: 68,
                      textOffset: 68,
                      createDisclosure: true,
                      callback: () async {
                        final result = await showCupertinoModalBottomSheet(
                          context: context,
                          builder: (context) => EditAccessAddUsers(
                            access: selectedUsers.map((e) => e.contactId).toList(),
                            returnContact: true,
                            headerText: 'Participants',
                          ),
                        );

                        if (result is List<Contact>) {
                          selectedUsers = result;
                          setState(() {});
                        }
                      },
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      height: 134,
                      width: double.infinity,
                      child: Container(
                        padding: EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(selectedUsers.isNotEmpty ? 0 : 10),
                            topRight: Radius.circular(selectedUsers.isNotEmpty ? 0 : 10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          color: SYSTEM_BACKGROUND_ONE,
                        ),
                        child: ContactScrollView(
                          contacts: selectedUsers,
                          addContact: () async {
                            final result = await showCupertinoModalBottomSheet(
                              context: context,
                              builder: (context) => EditAccessAddUsers(
                                access: selectedUsers.map((e) => e.contactId).toList(),
                                returnContact: true,
                                headerText: 'Participants',
                              ),
                            );

                            if (result is List<Contact>) {
                              selectedUsers = result;
                              setState(() {});
                            }
                          },
                          callback: (value) {
                            selectedUsers.remove(value);
                            setState((){});
                          },
                        ) ,
                      ),
                    ),
                    //selectedUsers

                    const SizedBox(height: 30),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _keyboardVisible() {
    if(keyBoardHeight != MediaQuery.of(context).viewInsets.bottom){
      keyBoardHeight = MediaQuery.of(context).viewInsets.bottom;
      updateKeyboardHeight();
    }

    return MediaQuery.of(context).viewInsets.bottom != 0.0;
  }

  updateKeyboardHeight() {
    if(!keyBoardOpen){
      _scrollController.animateTo(startPosition, duration: SUPER_FAST_ANIMATION, curve: Curves.fastOutSlowIn);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_)  {
      final pos = startPosition + textFieldPosition + height + 14;
      final Hs = viewHeight - keyBoardHeight;
      if((-Hs + pos) > 0){
        _scrollController.animateTo((-Hs + pos), duration: FAST_ANIMATION, curve: Curves.fastOutSlowIn);
      }
    });
  }
}