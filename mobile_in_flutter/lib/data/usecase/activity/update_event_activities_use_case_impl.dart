import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_app/data/response.dart';
import 'package:x_app/domain/models/activity/event_activities.dart';
import 'package:x_app/domain/models/activity/event_activity.dart';
import 'package:x_app/domain/service/file_system_service.dart';
import 'package:x_app/domain/usecase/activity/update_event_activities_use_case.dart';
import 'package:x_app/providers/w3n_providers.dart';
import 'package:x_app/utils/enum.dart';
import 'package:x_app/w3n/caps/fs.dart';


class UpdateEventActivityUseCaseImpl implements UpdateEventActivityUseCase {

  UpdateEventActivityUseCaseImpl(ProviderReference ref, {this.fs}): _service = ref.read(fileSystemProvider);

  final FileSystemService _service;
  final WritableFS? fs;

  @override
  Future<XResponse<EventActivities>> execute(EventActivity eventActivity, FileMethod fileMethod) async {
    if(fs == null) {
      return XResponse(exception: Error.localError('Fs is null'));
    }

    final eventActivityOnDisk = await _service.readTextFileWritingDefaultValue(
      fs!,
      EVENT_ACTIVITIES_FILE_PATH,
          (json) => EventActivities.fromJson(json),
          () => EventActivities(eventActivities: []).toJson(),
    );

    switch (fileMethod) {
      case FileMethod.ADD:
        eventActivityOnDisk.eventActivities.add(eventActivity);
        break;
      case FileMethod.UPDATE:
        bool foundChat = false;
        for (int i = 0; i < eventActivityOnDisk.eventActivities.length; i++){
          if(eventActivity.eventActivityId == eventActivityOnDisk.eventActivities[i].eventActivityId){
            eventActivityOnDisk.eventActivities[i] = eventActivity;
            foundChat = true;
            break;
          }
        }
        if(!foundChat){
          eventActivityOnDisk.eventActivities.add(eventActivity);
        }
        break;
      case FileMethod.REMOVE:
        eventActivityOnDisk.eventActivities.remove(eventActivity);
        break;
    }

    await _service.saveJsonOnDisk(fs!, EVENT_ACTIVITIES_FILE_PATH, eventActivityOnDisk.toJson());

    return XResponse(data: eventActivityOnDisk);
  }
}