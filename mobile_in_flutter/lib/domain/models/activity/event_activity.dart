/**
 *  Copyright (C) 2022 Digniti Tech OÜ.  All rights reserved.
 */

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:x_app/domain/models/activity/main_activities.dart';
import 'package:x_app/domain/models/event/event_model.dart';
import 'package:x_app/ui_utils/colors.dart';

part 'event_activity.g.dart';

@JsonSerializable()
class EventActivity extends MainActivities{

  final String eventActivityId;
  final String contactId;
  final EventModel event;
  bool isNewNotification = true;
  bool myNotification = true;
  bool hideNotification;
  bool isError;


  EventActivity({
    required this.event,
    required this.eventActivityId,
    required this.contactId,
    required this.myNotification,
    this.hideNotification = false,
    this.isError = false,
  });


  factory EventActivity.fromJson(Map<String, dynamic> json) => _$EventActivityFromJson(json);

  Map<String, dynamic> toJson() => _$EventActivityToJson(this);

  @override
  bool operator ==(other) {
    return (other is EventActivity) && eventActivityId == other.eventActivityId;
  }

  @override
  int get hashCode => super.hashCode;

  @override
  String getContactId() {
    return contactId;
  }

  @override
  String getButtonName() {
    return myNotification ? 'VIEW' : 'ADD';
  }

  @override
  Color getColor() {
    return SYSTEM_ADDING;
  }

  @override
  String getImgName() {
    return "notificationContact";
  }

  @override
  bool newNotification() {
    return isNewNotification;
  }

  @override
  String getTypeActivity() {
    return myNotification ? 'Added to contacts list' : 'Added you to contacts list';
  }

  @override
  Color buttonColorText() {
    return SYSTEM_WHITE;
  }

  @override
  Size getSmallImageSize() {
    return Size(8, 12);
  }

}

