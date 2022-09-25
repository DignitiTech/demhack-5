/**
 *  Copyright (C) 2022 Digniti Tech OÜ.  All rights reserved.
 */

import 'package:x_app/data/response.dart';
import 'package:x_app/domain/models/activity/event_activities.dart';
import 'package:x_app/domain/models/activity/event_activity.dart';
import 'package:x_app/utils/enum.dart';

abstract class UpdateEventActivityUseCase {
  Future<XResponse<EventActivities>> execute(EventActivity contactActivity, FileMethod fileMethod);
}