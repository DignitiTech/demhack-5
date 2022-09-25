/**
 *  Copyright (C) 2022 Digniti Tech OÜ.  All rights reserved.
 */

import 'package:x_app/data/response.dart';
import 'package:x_app/domain/models/activity/event_activities.dart';

abstract class GetEventActivitiesUseCase {
  Future<XResponse<EventActivities>> execute();
}