
import 'dart:typed_data';

import 'package:tuple/tuple.dart';

import 'files.dart';
import 'obj-in-core.dart';
import 'storage.dart';

enum FSType {
  device, synced, local, share, asmail_msg
}

abstract class ReadonlyFS extends Linkable {

  final FSType type;

  final ReadonlyFSVersionedAPI? v;

  final bool writable;

  /// Is a folder name, given by the outside to this file system. It may, or
  /// may not, be the same as an actual folder name. It may also be null.
  final String name;

  ReadonlyFS(this.type, this.v, this.writable, this.name);

  /// Checks presence of folder.
  ///
  /// [path] of a folder, which presence we want to check
  /// [throwIfMissing] is an optional flag, which forces with true value
  /// throwing of an exception, when folder does not exist. Default value is
  /// false.
  Future<bool> checkFolderPresence(String path, [ bool? throwIfMissing ]);

  /// Checks presence of folder.
  ///
  /// [path] of a file, which presence we want to check
  /// [throwIfMissing] is an optional flag, which forces with true value
  /// throwing of an exception, when file does not exist. Default value is
  /// false.
  Future<bool> checkFilePresence(String path, [ bool? throwIfMissing ]);

  /// Checks presence of link.
  ///
  /// [path] of a link, which presence we want to check
  /// [throwIfMissing] is an optional flag, which forces with true value
  /// throwing of an exception, when link does not exist. Default value is
  /// false.
  Future<bool> checkLinkPresence(String path, [ bool? throwIfMissing ]);

  /// Gives stats of an entity at a given [path].
  Future<Stats> stat(String path);

  /// Returns an extended attribute [xaName] of [path].
  ///
  /// Null is returned when attribute is not known.
  Future<XAttr?> getXAttr(String path, String xaName);

  /// Returns an array of set extended attributes.
  Future<List<String>> listXAttrs(String path);

  Future<SymLink> readLink(String path);

  Stream<FSEvent> watchFolder(String path);

  Stream<FileEvent> watchFile(String path);

  Stream<FSEvent> watchTree(String path);

  Future<void> close();

  /// Returns a file system object, rooted to a given folder [path].
  Future<ReadonlyFS> readonlySubRoot(String path);

  /// Lists folder at given [path].
  Future<List<ListingEntry>> listFolder(String path);

  /// Reads text from file at [path], using utf8 encoding.
  Future<String> readTxtFile(String path);

  /// Reads file from [path].
  ///
  /// Null is returned when there are no bytes.
  /// [path] of a file from which to read bytes
  /// [start] is an optional parameter, setting a beginning of read. If
  /// missing, read will be done as if neither [start], nor [end] parameters
  /// are given.
  /// [end] is an optional parameter, setting an end of read. If end is
  /// greater than file length, all available bytes are read. If parameter
  /// is missing, read will be done to file's end.
  Future<Uint8List?> readBytes(String path, [ int? start, int? end ]);

  /// Makes bytes source with seek, which allows random reads, from file at
  /// [path]
  Future<FileByteSource> getByteSource(String path);

  /// Makes a readonly file object for [path].
  Future<ReadonlyFile> readonlyFile(String path);

  /// This function selects items inside given [path], following given
  /// [criteria].
  ///
  /// It start selection process, which may be long, and returns a future,
  /// resolvable to items collection into selected items will eventually be
  /// placed, and a completion promise, that resolves when selection/search
  /// process completes. Note that collection can be watched for changes as
  /// they happen.
  Future<Tuple2<FSCollection, Future<void>>> select(
      String path, SelectCriteria criteria);

}

/// This is an interface for a symbolic link.
/// In unix file systems there are both symbolic and hard links. We do not
/// have hard links here, but we need to highlight that nature of links here
/// is symbolic. For example, when a target is deleted, symbolic link becomes
/// broken.
abstract class SymLink extends ObjectInCore {

  /// Flag that indicates if access to link's target is readonly (true), or
  /// can be writable (false value).
  final bool readonly;

  final FSItemType targetType;

  SymLink(this.readonly, this.targetType);

  Future<Linkable> target();

}

class SelectCriteria {

  /// This is a match for name. There are three match types:
  /// pattern, regexp and exact.
  /// 1) Pattern is a common cli search like "*.png" that treats *-symbol as
  /// standing for anything. Search isn't case-sensitive.
  /// When name field is a string, it is assumed to be this pattern type.
  /// 2) Regexp is used directly to make a match.
  /// 3) Exact matches given string exactly to names of fs items.
  final Tuple2<String, SelectCriteriaType> name;

  /// depth number, if present, limits search to folder depth in a file tree.
  final int? depth;

  /// type identifies type or types of elements this criteria should match.
  /// If missing, all fs types are considered for further matching.
  final List<FSItemType>? type;

  /// action specifies what happens with items that match given criteria:
  /// include or exclude from search results. Selection with include action
  /// returns only items that match criteria. Selection with exclude action
  /// returns all items that don't match criteria.
  final SelectCriteriaAction action;

  SelectCriteria(this.action, this.name, { this.depth, this.type });

}

enum SelectCriteriaType {
  pattern, regexp, exact
}
enum SelectCriteriaAction {
  include, exclude
}

abstract class ReadonlyFSVersionedAPI {

  Future<Tuple2<int, XAttr?>> getXAttr(String path, String xaName);

  Future<Tuple2<int, List<String>>> listXAttrs(String path);

  /// Lists folder at given [path], also giving current folder version.
  Future<Tuple2<int, List<ListingEntry>>> listFolder(String path);

  /// Reads text from file at [path], using utf8 encoding, also giving current
  /// folder version.
  Future<Tuple2<int, String>> readTxtFile(String path);

  /// Reads file from [path], also giving current folder version.
  ///
  /// Null is returned when there are no bytes.
  /// [path] of a file from which to read bytes
  /// [start] is an optional parameter, setting a beginning of read. If
  /// missing, read will be done as if neither [start], nor [end] parameters
  /// are given.
  /// [end] is an optional parameter, setting an end of read. If end is
  /// greater than file length, all available bytes are read. If parameter
  /// is missing, read will be done to file's end.
  Future<Tuple2<int, Uint8List?>> readBytes(
      String path, [ int? start, int? end ]);

  /// Makes bytes source with seek, which allows random reads, from file at
  /// [path], also giving current folder version.
  Future<Tuple2<int, FileByteSource>> getByteSource(String path);

}

class FSItem {
  /// [type] indicates fs type of an item. null stands for collection that
  /// isn't an item in a file system.
  final FSItemType? type;
  final ReadonlyFS? fs;
  final ReadonlyFile? file;
  final FSCollection? fsCollection;
  final FSItemLocation? location;
  FSItem(this.type, {
    this.fs, this.file, this.fsCollection, this.location
  });
}

class FSItemLocation {
  final ReadonlyFS fs;
  final String path;
  final StorageUse? storageUse;
  final StorageType? storageType;
  FSItemLocation({
    required this.storageUse, required this.storageType,
    required this.fs, required this.path
  });
}

abstract class FSCollection extends ObjectInCore {
  Future<FSItem?> get(String name);
  Future<List<Tuple2<String, FSItem>>> getAll();
  Future<FSItemsIterator> entries();
  Stream<CollectionEvent> watch();
}

abstract class FSItemsIterator extends ObjectInCore {
  Future<Tuple2<String, FSItem>?> next();
}

enum CollectionEventType {
  entry_removal, entry_addition
}

abstract class CollectionEvent {
  final CollectionEventType type;
  CollectionEvent(this.type);
}
class CollectionItemAdditionEvent extends CollectionEvent {
  final String path;
  final FSItem item;
  CollectionItemAdditionEvent({ required this.path, required this.item })
      : super(CollectionEventType.entry_addition);
}
class CollectionItemRemovalEvent extends CollectionEvent {
  final String? path;
  CollectionItemRemovalEvent({ required this.path })
      : super(CollectionEventType.entry_removal);
}

abstract class WritableFS extends ReadonlyFS {

  final WritableFSVersionedAPI? v;

  WritableFS(FSType type, this.v, bool writable, String name)
      : super(type, v, true, name);

  /// Updates extended attributes of item at [path].
  ///
  /// [changes] is an object with changes to attributes. Note these are
  /// explicit changes of extended attributes, not an implicit replacement.
  Future<void> updateXAttrs(String path, XAttrsChanges changes);

  /// This either finds existing, or creates new folder.
  ///
  /// [path] of a folder that should be created
  /// [exclusive] is an optional flag, which when set to true, throws
  /// if folder already exists. Default value is false, i.e. if folder
  /// exists, nothing happens.
  Future<void> makeFolder(String path, [ bool? exclusive ]);

  /// Deletes folder at [path]
  ///
  /// [removeContent] is an optional flag, which true values forces
  /// recursive removal of all content in the folder. Default value is false.
  /// If folder is not empty, and content removal flag is not set, then an
  /// error is thrown.
  Future<void> deleteFolder(String path, [ bool? removeContent ]);

  /// Deletes file at [path]
  Future<void> deleteFile(String path);

  /// Moves file/folder/link from [src] to [dst]
  Future<void> move(String src, String dst);

  /// Copies file at [src] to [dst]
  ///
  /// [overwrite] is an optional flag that with a true value allows
  /// overwrite of existing dst file. Default value is false.
  Future<void> copyFile(String src, String dst, [ bool? overwrite ]);

  /// Copies folder at [src] to [dst]
  ///
  /// [mergeAndOverwrite] is an optional flag that with true value allows
  /// merge into existing folder and files overwriting inside. Default
  /// value is false.
  Future<void> copyFolder(String src, String dst, [ bool? mergeAndOverwrite ]);

  /// Saves content of given [file] to [dst] path.
  ///
  /// [overwrite] is a flag that with a true value allows
  /// overwrite of existing dst file. Default value is false.
  Future<void> saveFile(ReadonlyFile file, String dst, [ bool? overwrite ]);

  /// Saves content of given [folder] to [dst] path.
  ///
  /// [mergeAndOverwrite] is a flag that with true value allows
  /// merge into existing folder and files overwriting inside. Default
  /// value is false.
  Future<void> saveFolder(
      ReadonlyFile folder, String dst, [ bool? mergeAndOverwrite ]);

  /// Deletes link at [path]
  Future<void> deleteLink(String path);

  Future<void> link(String path, Linkable target);

  /// Makes a writable folder object for [path].
  ///
  /// [flags] are optional flags. Default flags are create=true,
  /// exclusive=false.
  Future<WritableFS> writableSubRoot(String path, [ FileFlags? flags ]);

  /// Writes given [txt] as complete content of file at [path].
  ///
  /// [flags] are optional flags. Default flags are create=true,
  /// exclusive=false.
  Future<void> writeTxtFile(String path, String txt, [ FileFlags? flags ]);

  /// Writes given [bytes] as complete content of file at [path].
  ///
  /// [flags] are optional flags. Default flags are create=true,
  /// exclusive=false.
  Future<void> writeBytes(String path, Uint8List bytes, [ FileFlags? flags ]);

  /// Makes bytes sink with seek, allowing random reads, to file at [path]
  ///
  /// [flags] are optional flags. Default flags are create=true,
  /// exclusive=false, truncate=true.
  Future<FileByteSink> getByteSink(String path, [ FileFlags? flags ]);

  /// Makes a writable file object for [path].
  ///
  /// [flags] are optional flags. Default flags are create=true,
  /// exclusive=false.
  Future<WritableFile> writableFile(String path, [ FileFlags? flags ]);


}

class FileFlags {

  /// truncate flag is optional. True value forces truncation of file, if it
  /// already exists. Default value is true.
  final bool truncate;

  /// create flag is optional. True value forces creation of file, if it is
  /// missing. Default value is true.
  final bool create;

  /// exclusive flag is optional. This flag is applicable when create is true.
  /// True value ensures that file doesn't exist, and an error is thrown, when
  /// file exists. Default value is false.
  final bool exclusive;

  FileFlags({
    this.truncate = true, this.create = true, this.exclusive = false
  });

}

abstract class WritableFSVersionedAPI extends ReadonlyFSVersionedAPI {

  /// Updates extended attributes of item at [path], also giving new version.
  ///
  /// [changes] is an object with changes to attributes. Note these are explicit
  /// changes of extended attributes, not an implicit replacement.
  Future<int> updateXAttrs(String path, XAttrsChanges changes);

  /// Writes given [txt] as complete content of file at [path], also giving new
  /// version.
  ///
  /// [flags] are optional flags. Default flags are create=true,
  /// exclusive=false.
  Future<int> writeTxtFile(
      String path, String txt, [ VersionedFileFlags? flags ]);

  /// Writes given [bytes] as complete content of file at [path], also giving
  /// new version.
  ///
  /// [flags] are optional flags. Default flags are create=true,
  /// exclusive=false.
  Future<int> writeBytes(
      String path, Uint8List bytes, [ VersionedFileFlags? flags ]);

  /// Makes bytes sink with seek, allowing random writes, to file at [path],
  /// also giving new version.
  ///
  /// [flags] are optional flags. Default flags are create=true,
  /// exclusive=false, truncate=true.
  Future<Tuple2<int, FileByteSink>> getByteSink(
      String path, [ VersionedFileFlags? flags ]);

}

class VersionedFileFlags extends FileFlags {

  /// currentVersion flag is optional. This flag is applicable to existing file.
  /// An error is thrown when at the time of writing current file version is
  /// different from a given value.
  final int? currentVersion;

  VersionedFileFlags({
    this.currentVersion,
    bool truncate = true, bool create = true, bool exclusive = false
  })
      : super(truncate: truncate, create: create, exclusive: exclusive);

}
