import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:x_app/domain/models/event/event_model.dart';
import 'package:x_app/extensions/theme_extensions.dart';
import 'package:x_app/ui_utils/colors.dart';
import 'package:x_app/utils/callback.dart';
import 'package:x_app/utils/enum.dart';
import 'package:x_app/utils/global_value.dart';
import 'package:x_app/widgets/calendar.dart';
import 'package:x_app/widgets/messenger_cell.dart';
import 'package:x_app/widgets/profile_photo_view.dart';
import 'package:x_app/widgets/sending_text_animation.dart';

class SomeoneEventCell extends StatelessWidget {

  const SomeoneEventCell({
    Key? key,
    required this.someoneName,
    required this.accenpt,
    required this.myName,
    required this.eventModel,
    required this.dateTime,
    required this.backAccountColor,
    required this.createUserIcon,
    required this.topDate,
    required this.lastMessage,
    required this.previousMessageMy,
    required this.longPress,
    required this.userImg,
    required this.createTime,
    required this.isActive,
    required this.myMessage,
    required this.status,
    this.comment = true,
    this.createInvite = true,
    this.eventImg = null,
    this.height = null,
    required this.callback,
  }) : super(key: key);

  final String someoneName;
  final String myName;
  final bool accenpt;
  final EventModel eventModel;
  final Color backAccountColor;
  final bool createUserIcon;
  final DateTime? topDate;
  final bool lastMessage;
  final bool previousMessageMy;
  final bool comment;
  final bool createTime;
  final bool myMessage;
  final bool createInvite;
  final bool? isActive;
  final double? height;
  final Future<Uint8List?>? eventImg;
  final SizePositionCallback longPress;
  final Future<Uint8List?>? userImg;
  final DateTime? dateTime;
  final MessageStatus status;
  final GestureTapCallback callback;


  @override
  Widget build(BuildContext context) {
    final GlobalKey cellKey = GlobalKey();
    final scrollbarController = ScrollController();

    final span = TextSpan(text: eventModel.message, style: comment ? Theme.of(context).textTheme.regularParagraphText : Theme.of(context).textTheme.xSmallLink40);
    final tp = TextPainter(text: span, maxLines: 10, textDirection: TextDirection.ltr);
    tp.layout(maxWidth: logicalWidth - 116);

    EdgeInsetsGeometry offset = myMessage ? EdgeInsets.only(left: 80, right: 12) : EdgeInsets.only(left: 0, right: 46);
    final bottomPadding = EdgeInsets.only(bottom: !myMessage ? (lastMessage ? 12 : previousMessageMy ? 2 : 8)
        : (lastMessage || status == MessageStatus.ERROR || status == MessageStatus.ERROR_UPDATE)
        ? 4
        : previousMessageMy ? 2 : 8);

    final Widget personalIcon = (createUserIcon && !myMessage) ? Container(
      width: 46,
      alignment: Alignment.bottomLeft,
      padding: EdgeInsets.only(left: 12),
      child: Container(
        height: 30,
        width: 30,
        child: ProfilePhotoView(
          profileName: someoneName,
          futurePhoto: userImg,
          size: 30,
          onlineIndicatorSize: 10,
          isOnline: null,
          // isOnline: isOnline,
          backgroundColor: backAccountColor,
          transformX: 0,
          transformY: 1,
        ),
      ),
    ) : SizedBox(width: myMessage ? 0 : 46);

    final double? width = (tp.width + 24) < 74 ? 74 : null;

    final  messageText = eventModel.message.split('@Name');

    return GestureDetector(
      onLongPress: (){
        RenderBox box = cellKey.currentContext!.findRenderObject() as RenderBox;
        final size = Size(box.size.width, box.size.height);
        final position = box.localToGlobal(Offset.zero);
        longPress(size, position, 0);
      },
      child: Column(
        children: [
          topDate != null ? timeWidget(context, topDate!) : Container(),
          (dateTime != null && (createTime || !previousMessageMy || topDate != null) && !myMessage) ? Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(left: 58),
            height: 18,
            child: Text(
              dateToTime(dateTime!),
              style: Theme.of(context).textTheme.xxSmallGray,
            ),
          ) : Container(),
          Container(
            padding: offset,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: bottomPadding,
                  child: personalIcon,
                ),
                Expanded(
                  child: Column(
                    children: [
                      if (createInvite) Container(
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: const Radius.circular(17.5),
                            topLeft: const Radius.circular(17.5),
                          ),
                          border: Border.all(width: 1, color: SYSTEM_BACKGROUND_THIRD),
                          color: SYSTEM_WHITE,
                        ),
                        child: Stack(
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              padding: EdgeInsets.only(top: 9, bottom: 0, left: 12),
                              child: Container(
                                height: 15,
                                width: 15,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(const Radius.circular(10)),
                                ),
                                child: SvgPicture.asset(
                                  'assets/img/eventTaskIcon.svg',
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              padding: EdgeInsets.only(top: 9, bottom: 0, left: 32, right: 12),
                              child: Text(
                                'Event Invitation',
                                style: Theme.of(context).textTheme.xxSmallGray48,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            height: height,
                            width: width,
                            key: cellKey,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(createInvite ? 0 : 17.5),
                                topLeft: Radius.circular(createInvite ? 0 : 17.5),
                              ),
                              border: comment ? null : Border.all(width: 1, color: SYSTEM_BACKGROUND_THIRD),
                              color: comment ? SYSTEM_BACKGROUND_ONE : SYSTEM_WHITE,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            child: Container(
                              padding: EdgeInsets.zero,
                              child: Scrollbar(
                                thumbVisibility: true,
                                controller: scrollbarController,
                                child: SingleChildScrollView (
                                  controller: scrollbarController,
                                  padding: EdgeInsets.zero,
                                  child: RichText(
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.start,
                                    text: TextSpan(
                                      text: messageText[0],
                                      style: Theme.of(context).textTheme.regularParagraphText,
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: myMessage ? someoneName : myName,
                                          style: Theme.of(context).textTheme.regularLink,
                                        ),
                                        TextSpan(
                                          text: messageText[1],
                                          style: Theme.of(context).textTheme.regularParagraphText,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Text(
                                  //   eventModel.message,
                                  //   style: comment ? Theme.of(context).textTheme.regularParagraphText : Theme.of(context).textTheme.xSmallLink40,
                                  // ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 64,
                        padding: bottomPadding,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomRight: const Radius.circular(17.5),
                            bottomLeft: const Radius.circular(17.5),
                          ),
                          border: Border.all(width: 1, color: SYSTEM_BACKGROUND_THIRD),
                          color: SYSTEM_WHITE,
                        ),
                        child: Stack(
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              padding: EdgeInsets.only(top: 12, left: 12),
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(const Radius.circular(10)),
                                ),
                                child: eventImg == null ? SvgPicture.asset(
                                  'assets/img/eventTaskButton.svg',
                                ) : FutureBuilder<Uint8List?>(
                                  future: eventImg,
                                  builder: (_, snapshot) {
                                    final image = snapshot.data;
                                    if (image == null) return SvgPicture.asset('assets/img/eventTaskButton.svg');
                                    return Image.memory(
                                      image,
                                      fit: BoxFit.cover,
                                      height: double.infinity,
                                      width: double.infinity,
                                      alignment: Alignment.center,
                                    );
                                  },
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              padding: EdgeInsets.only(top: 13, left: 62, right: 102),
                              child: Text(
                                eventModel.name,
                                style: Theme.of(context).textTheme.regularSemiBold,
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              padding: EdgeInsets.only(top: 35, left: 62, right: 102),
                              child: Text(
                                dateToStringMessage(eventModel.startDate),
                                style: Theme.of(context).textTheme.xSmallLink48,
                              ),
                            ),
                            Container(
                              alignment: Alignment.topRight,
                              padding: EdgeInsets.only(top: 19, right: 12),
                              child:GestureDetector (
                                onTap: callback,
                                child:  Container(
                                  height: 26,
                                  width: 76,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(17)),
                                    color: SYSTEM_BACKGROUND_GRAY_BUTTON,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Center(
                                      child: Text(
                                        accenpt ? 'GOING' : 'VIEW',
                                        textDirection: TextDirection.ltr,
                                        softWrap: true,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.start,
                                        style: Theme.of(context).textTheme.smallSemiBoldLink,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      bottomBar(context),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bottomBar(BuildContext context) {
    return !myMessage ? Container() : (status == MessageStatus.ERROR || status == MessageStatus.ERROR_UPDATE) ? Container(
      padding: EdgeInsets.only(left: 0, bottom: lastMessage ? 12 : previousMessageMy ? 2 : 8),
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 13,
                height: 13,
                child: SvgPicture.asset('assets/img/error_circle_icon.svg'),
              ),
              SizedBox(
                width: 6,
              ),
              Text(
                'Message not sent',
                style: Theme.of(context).textTheme.xxSmallTAGLink40,
              ),
              SizedBox(
                width: 6,
              ),
            ],
          ),
          Container(
            alignment: Alignment.topRight,
            child: Container(
              child: GestureDetector(
                onTap: (){
                },
                child: Text(
                  'Resend',
                  textAlign: TextAlign.right,
                  // maxLines: 1,
                  style: Theme.of(context).textTheme.xxSmallTAG,
                ),
              ),
            ),
          ),
        ],
      ),
    ) : (lastMessage) ? Container(
      padding: EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.topRight,
        child: status == MessageStatus.SENDING ? SendingTextAnimation() : RichText(
          textDirection: TextDirection.ltr,
          softWrap: true,
          textAlign: TextAlign.center,
          text: TextSpan(
            text: '${status.name}',
            style: Theme.of(context).textTheme.xxSmallTAGLink40,
            children: <TextSpan>[
              TextSpan(
                text: ' ${dateToTimeMessage(dateTime!)}',
                style: Theme.of(context).textTheme.xxSmallGray,
              ),
            ],
          ),
        ),
      ),
    ) : Container();
  }
}
