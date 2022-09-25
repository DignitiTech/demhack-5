/**
 *  Copyright (C) 2022 Digniti Tech OÜ.  All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:x_app/domain/models/contacts/contact.dart';
import 'package:x_app/domain/models/event/event_model.dart';
import 'package:x_app/ui_utils/animation_speed.dart';
import 'package:x_app/ui_utils/colors.dart';
import 'package:x_app/extensions/theme_extensions.dart';
import 'package:x_app/widgets/profile_photo_view.dart';

class EventRequestWidget extends StatefulWidget {
  const EventRequestWidget({
    required this.event,
    required this.contact,
    required this.isError,
    required this.callback,
  });


  final EventModel event;
  final Contact contact;
  final bool isError;
  final GestureTapCallback callback;

  @override
  _EventRequestWidget createState() => _EventRequestWidget();
}

class _EventRequestWidget extends State<EventRequestWidget>{

  bool buttonTap = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.callback,
      onTapUp: (detail) {
        buttonTap = false;
        setState(() {});
      },
      onPanUpdate: (detail) {
        buttonTap = false;
        setState(() {});
      },
      onTapDown: (detail) {
        buttonTap = true;
        setState(() {});
      },
      onPanCancel: (){
        buttonTap = false;
        setState(() {});
      },
      child: AnimatedOpacity(
        opacity: buttonTap ? 0.6 : 1,
        duration: FAST_ANIMATION,
        child: Container(
          height: 76,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: SYSTEM_WHITE,
          ),
          child: Stack(
            children: [
              Container(
                height: 61,
                width: 58,
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(top: 18, left: 16),
                child: Stack(
                  children: [
                    Container(
                      child: Container(
                        height: 40,
                        width: 40,
                        child: ProfilePhotoView(
                          profileName: widget.event.name,
                          isOnline: null,
                          futurePhoto: widget.contact.getPreviewImg(context),
                          chatPhotoView: true,
                          backgroundColor: Color(widget.contact.profileColorIntValue),
                          size: 40,
                        ),
                      ),
                    ) ,
                    Container(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        height: 17,
                        width: 17,
                        decoration: new BoxDecoration(
                          color: SYSTEM_PURPLE,
                          shape: BoxShape.circle,
                          border: Border.all(width: 2, color: SYSTEM_WHITE),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Container(
                            width: 9,
                            height: 8,
                            child: SvgPicture.asset('assets/img/eventTaskButton.svg'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 16, left: 68, right: 106),
                child: Text(
                  widget.contact.getName(),
                  style: Theme.of(context).textTheme.regularSemiBold,
                ),
              ),

              Container(
                padding: EdgeInsets.only(top: 38, left: 68, right: 106),
                child: Text(
                  widget.isError ? 'Response send failure' : 'Direct message',
                  style: Theme.of(context).textTheme.smallGrayText48Black,
                ),
              ),

              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 16),
                child: Container(
                  height: 28,
                  width: 76,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(17)),
                    color: SYSTEM_BACKGROUND_GRAY_BUTTON,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      child: Text(
                        'GOING',
                        textDirection: TextDirection.ltr,
                        softWrap: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: widget.isError ? Theme.of(context).textTheme.smallSemiBoldLink.copyWith(color: SYSTEM_DESTRUCTIVE) : Theme.of(context).textTheme.smallSemiBoldLink,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
