
import 'package:tuple/tuple.dart';

import 'fs.dart';

abstract class Storage {

  /// Returns app's fs in local storage.
  ///
  /// Optional [appName] is a reversed app's domain, for those times when
  /// you need access to child apps.
  Future<WritableFS> getAppLocalFS([ String? appName ]);

  /// Returns app's fs in synced storage.
  ///
  /// Optional [appName] is a reversed app's domain, for those times when
  /// you need access to child apps.
  Future<WritableFS> getAppSyncedFS([ String? appName ]);

  Future<FSItem> getFS(Tuple2<StorageUse, StorageType> type, [ String? path ]);

}

enum StorageType {
  device, synced, local
}

enum StorageUse {
  user, system, app
}
