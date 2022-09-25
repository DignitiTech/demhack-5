/**
 *  Copyright (C) 2022 Digniti Tech OÜ.  All rights reserved.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_app/domain/models/activity/event_activities.dart';
import 'package:x_app/domain/models/activity/event_activity.dart';
import 'package:x_app/domain/usecase/activity/get_event_activities_use_case.dart';
import 'package:x_app/domain/usecase/activity/update_event_activities_use_case.dart';
import 'package:x_app/providers/activity/providers.dart';
import 'package:x_app/utils/enum.dart';

class EventActivitiesStateNotifier extends StateNotifier<EventActivities> {
  EventActivitiesStateNotifier(ProviderReference ref)
      : _getEventActivitiesUseCaseProvider = ref.read(getEventActivitiesUseCaseProvider),
        _updateEventActivityUseCaseProvider = ref.read(updateEventActivityUseCaseProvider),
        super(EventActivities(eventActivities: []));


  final GetEventActivitiesUseCase _getEventActivitiesUseCaseProvider;
  final UpdateEventActivityUseCase _updateEventActivityUseCaseProvider;

  Future<void> startSearchEventActivities() async {
    final eventActivities = (await _getEventActivitiesUseCaseProvider.execute()).data;
    state = eventActivities!;
  }

  Future<bool> addEventActivity(EventActivity eventActivity) async {
    final result = await _updateEventActivityUseCaseProvider.execute(eventActivity, FileMethod.ADD);
    if(result.data != null) {
      state = result.data!;
      return true;
    }else{
      return false;
    }
  }

  Future<bool> updateEventActivity(EventActivity eventActivity) async {
    final result = await _updateEventActivityUseCaseProvider.execute(eventActivity, FileMethod.UPDATE);
    if(result.data != null) {
      state = result.data!;
      return true;
    }else{
      return false;
    }
  }

  Future<bool> removeEventActivity(EventActivity eventActivity) async {
    final result = await _updateEventActivityUseCaseProvider.execute(eventActivity, FileMethod.REMOVE);
    if(result.data != null) {
      state = result.data!;
      return true;
    }else{
      return false;
    }
  }

}