/**
 *  Copyright (C) 2022 Digniti Tech OÜ.  All rights reserved.
 */


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_app/data/usecase/activity/get_contact_activities_use_case_impl.dart';
import 'package:x_app/data/usecase/activity/get_event_activities_use_case_impl.dart';
import 'package:x_app/data/usecase/activity/get_messenger_activities_use_case_impl.dart';
import 'package:x_app/data/usecase/activity/update_contact_activity_use_case_impl.dart';
import 'package:x_app/data/usecase/activity/update_event_activities_use_case_impl.dart';
import 'package:x_app/data/usecase/activity/update_messenger_activity_use_case_impl.dart';
import 'package:x_app/domain/models/activity/contact_activities.dart';
import 'package:x_app/domain/models/activity/event_activities.dart';
import 'package:x_app/domain/models/activity/messenger_activities.dart';
import 'package:x_app/domain/usecase/activity/get_contact_activities_use_case.dart';
import 'package:x_app/domain/usecase/activity/get_event_activities_use_case.dart';
import 'package:x_app/domain/usecase/activity/get_messenger_activities_use_case.dart';
import 'package:x_app/domain/usecase/activity/update_contact_activity_use_case.dart';
import 'package:x_app/domain/usecase/activity/update_event_activities_use_case.dart';
import 'package:x_app/domain/usecase/activity/update_messenger_activity_use_case.dart';
import 'package:x_app/providers/activity/contact_activity_state_notifier.dart';
import 'package:x_app/providers/activity/event_activity_state_notifier.dart';
import 'package:x_app/providers/activity/message_activity_state_notifier.dart';
import 'package:x_app/providers/w3n_providers.dart';
import 'package:x_app/utils/w3n_providers_initializator.dart';

final StateNotifierProvider<MessengerActivitiesStateNotifier, MessengerActivities> messengerActivitiesProvider
= StateNotifierProvider((ref) => MessengerActivitiesStateNotifier(ref));

final StateNotifierProvider<ContactActivitiesStateNotifier, ContactActivities> contactActivitiesProvider
= StateNotifierProvider((ref) => ContactActivitiesStateNotifier(ref));

final StateNotifierProvider<EventActivitiesStateNotifier, EventActivities> eventActivitiesProvider
= StateNotifierProvider((ref) => EventActivitiesStateNotifier(ref));

final Provider<GetMessengerActivitiesUseCase> getMessengerActivitiesUseCaseProvider = Provider((ref) {
  final fs =  ref.read(pathFSProvider(CHATS_PATH)).state;
  return GetMessengerActivitiesUseCaseImpl(ref, fs: fs);
});

final Provider<UpdateMessengerActivityUseCase> updateMessengerActivityUseCaseProvider = Provider((ref) {
  final fs =  ref.watch(pathFSProvider(CHATS_PATH)).state;
  return UpdateMessengerActivityUseCaseImpl(ref, fs: fs);
});

final Provider<GetContactActivitiesUseCase> getContactActivitiesUseCaseProvider = Provider((ref) {
  final fs =  ref.read(pathFSProvider(CONTACTS)).state;
  return GetContactActivitiesUseCaseImpl(ref, fs: fs);
});

final Provider<UpdateContactActivityUseCase> updateContactActivityUseCaseProvider = Provider((ref) {
  final fs =  ref.watch(pathFSProvider(CONTACTS)).state;
  return UpdateContactActivityUseCaseImpl(ref, fs: fs);
});

final Provider<GetEventActivitiesUseCase> getEventActivitiesUseCaseProvider = Provider((ref) {
  final fs =  ref.read(pathFSProvider(CONTACTS)).state;
  return GetEventActivitiesUseCaseImpl(ref, fs: fs);
});

final Provider<UpdateEventActivityUseCase> updateEventActivityUseCaseProvider = Provider((ref) {
  final fs =  ref.watch(pathFSProvider(CONTACTS)).state;
  return UpdateEventActivityUseCaseImpl(ref, fs: fs);
});