/**
 *  Copyright (C) 2022 Digniti Tech OÜ.  All rights reserved.
 */

import 'package:json_annotation/json_annotation.dart';

part 'event_model.g.dart';

@JsonSerializable()
class EventModel {
  final String name;
  String message;
  final String? type;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final String? timeZone;

  EventModel({
    required this.name,
    required this.message,
    this.type,
    this.description,
    required this.startDate,
    this.endDate,
    required this.timeZone,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => _$EventModelFromJson(json);

  Map<String, dynamic> toJson() => _$EventModelToJson(this);

  @override
  String toString() {
    return '(name: ' + name + ' type: ' + (type ?? 'null') + ' description: ' + (description ?? 'null') + ' startDate: ' + startDate.toString()
        + ' endDate: ' + (endDate?.toString() ?? 'null') + ' timeZone: ' + (timeZone ?? 'null');
  }

}