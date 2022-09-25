/**
 *  Copyright (C) 2022 Digniti Tech OÜ.  All rights reserved.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_app/data/response.dart';
import 'package:x_app/domain/models/activity/event_activities.dart';
import 'package:x_app/domain/service/file_system_service.dart';
import 'package:x_app/domain/usecase/activity/get_event_activities_use_case.dart';
import 'package:x_app/providers/w3n_providers.dart';
import 'package:x_app/w3n/caps/fs.dart';

class GetEventActivitiesUseCaseImpl implements GetEventActivitiesUseCase {

  GetEventActivitiesUseCaseImpl(ProviderReference ref, {this.fs}): _service = ref.read(fileSystemProvider);

  final FileSystemService _service;
  final WritableFS? fs;

  @override
  Future<XResponse<EventActivities>> execute() async {
    if(fs == null) {
      return XResponse(exception: Error.localError('Fs is null'));
    }

    final eventActivity = await _service.readTextFileWritingDefaultValue(
      fs!,
      EVENT_ACTIVITIES_FILE_PATH,
          (json) => EventActivities.fromJson(json),
          () => EventActivities(eventActivities: []).toJson(),
    );

    return XResponse(data: eventActivity);
  }
}