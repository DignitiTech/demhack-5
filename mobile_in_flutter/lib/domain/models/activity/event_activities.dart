/**
 *  Copyright (C) 2022 Digniti Tech OÜ.  All rights reserved.
 */

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';
import 'package:x_app/domain/models/activity/event_activity.dart';


part 'event_activities.g.dart';

const String EVENT_ACTIVITIES_FILE_PATH = '/eventActivities.json';

@JsonSerializable()
class EventActivities {

  @JsonKey(defaultValue: [])
  List<EventActivity> eventActivities;

  EventActivities({
    required this.eventActivities,
  });

  EventActivity? getEventActivityByUserId(String userAddress) => eventActivities.firstWhereOrNull((activity) => activity.contactId.toLowerCase() == userAddress);

  EventActivity? getEventActivityById(String activityId) => eventActivities.firstWhereOrNull((activity) => activity.eventActivityId == activityId);

  factory EventActivities.fromJson(Map<String, dynamic> json) => _$EventActivitiesFromJson(json);

  Map<String, dynamic> toJson() => _$EventActivitiesToJson(this);

}

