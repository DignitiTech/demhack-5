
import 'dart:typed_data';

import 'package:tuple/tuple.dart';

import 'obj-in-core.dart';

abstract class FileByteSource extends ObjectInCore {

  /// Reads file bytes from a current position.
  ///
  /// Null is returned when there are no bytes.
  /// Read advances current position. Seek method sets position to a particular
  /// value. Initial value of current read position is zero.
  /// [len] is maximum number of bytes to read from file. If null is given, all
  /// bytes are read from current position to the end of file.
  Future<Uint8List?> read(int? len);

  /// Gets size of this file.
  Future<int> getSize();

  /// Sets read position to a given [offset].
  Future<void> seek(int offset);

  /// Gets current read position.
  Future<int> getPosition();

}

abstract class FileByteSink extends ObjectInCore {

  /// Gets current size. This size changes when sink is spliced/truncated.
  Future<int> getSize();

  /// Splices file.
  ///
  /// It removes bytes, and inserts new ones. Note that it is an insertion of
  /// [bytes], and not over-writing.
  /// [pos] in file at which deletion should occur, followed by insertion of
  /// given [bytes], if any given. If position is greater than current size,
  /// empty section will be inserted up to it.
  /// [del] number of bytes to cut at given position.
  Future<void> splice(int pos, int del, [ Uint8List? bytes ]);

  /// Truncates file to a given [size].
  ///
  /// If size is reduced, bytes are cut.
  Future<void> truncate(int size);

  /// Returns current file layout.
  ///
  /// Returned layout is not a shared object, and any new changes will be
  /// reflected in layouts from following calls of this method.
  Future<FileLayout> showLayout();

  /// This completes sink. Completion with error cancels file writing.
  ///
  /// Regular completion may get an error thrown back, while canceling will not.
  /// [err] is an optional error, presence of which indicates closing of sink
  /// with this error. When err is given, no errors will be thrown back to this
  /// call.
  Future<void> done([ Exception? err ]);

}

class FileLayout {
  final int? base;
  final List<LayoutSection> sections;
  FileLayout(this.base, this.sections);
}

class LayoutSection {
  final LayoutSectionType src;
  final int ofs;
  final int len;
  LayoutSection(this.src, this.ofs, this.len);
}

enum LayoutSectionType {
  tNew, base, empty
}

abstract class Linkable extends ObjectInCore {}

abstract class ReadonlyFile extends Linkable {

  final bool writable;

  final ReadonlyFileVersionedAPI? v;

  /// Is a file name, given by the outside to this file. It may, or may not,
  /// be the same as an actual file name in the file system. It may also be
  /// null.
  final String name;

  /// Is a flag that says, whether file existed at the moment of this object's
  /// creation.
  final bool isNew;

  ReadonlyFile(this.writable, this.v, this.name, this.isNew);

  /// Stats this file.
  Future<Stats> stat();

  /// Returns an extended attribute [xaName] of this file.
  ///
  /// Null is returned when attribute is not known.
  Future<XAttr?> getXAttr(String xaName);

  /// Returns an array of set extended attributes.
  Future<List<String>> listXAttrs();

  /// Reads bytes from this file.
  ///
  /// Null is returned when there are no bytes.
  /// [path] of a file from which to read bytes
  /// [start] is an optional parameter, setting a beginning of read. If
  /// missing, read will be done as if neither [start], nor [end] parameters
  /// are given.
  /// [end] is an optional parameter, setting an end of read. If end is
  /// greater than file length, all available bytes are read. If parameter
  /// is missing, read will be done to file's end.
  Future<Uint8List?> readBytes([ int? start, int? end ]);

  /// Reads text from this file, using utf8 encoding.
  Future<String> readTxt();

  /// Makes bytes source with seek, which allows random reads, from this file.
  Future<FileByteSource> getByteSource();

  Stream<FileEvent> watch();

}

enum XAttrType {
  string, bytes, json
}

abstract class XAttr<T> {
  final XAttrType type;
  final T value;
  XAttr(this.type, this.value);
}
class XAttrString extends XAttr<String> {
  XAttrString(String value) : super(XAttrType.string, value);
}
class XAttrJSON extends XAttr<String> {
  XAttrJSON(String value) : super(XAttrType.json, value);
}
class XAttrBytes extends XAttr<Uint8List> {
  XAttrBytes(Uint8List value) : super(XAttrType.bytes, value);
}

class XAttrsChanges {
  final Map<String, XAttr>? set;
  final List<String>? remove;
  XAttrsChanges(this.set, this.remove);
}

enum FSItemType {
  file, folder, link
}

class Stats {

  final FSItemType type;
  final bool writable;

  /// File size in bytes.
  final int? size;

  /// Last content modification time stamp.
  /// If such information cannot be provided, this field will be absent.
  final int? mtime;

  /// Last change of metadata time stamp.
  /// If such information cannot be provided, this field will be absent.
  final int? ctime;

  /// This tells object's version.
  /// If such information cannot be provided, this field will be absent.
  final int? version;

  Stats(this.type, this.writable, {
    this.size, this.mtime, this.ctime, this.version
  });
}

enum FSEventType {
  removed, moved, synced, unsynced, conflicting,
  entry_removal, entry_addition, entry_renaming,
  file_change
}

abstract class FSEvent {
  final FSEventType type;
  final String path;
  final bool isRemote;
  FSEvent(this.type, this.path, this.isRemote);
}

abstract class FileEvent extends FSEvent {
  FileEvent(FSEventType type, String path, bool isRemote)
      : super(type, path, isRemote);
}
class FileChangeEvent extends FileEvent {
  FileChangeEvent(String path, bool isRemote)
      : super(FSEventType.file_change, path, isRemote);
}
class RemovedEvent extends FileEvent {
  RemovedEvent(String path, bool isRemote)
      : super(FSEventType.removed, path, isRemote);
}
class MovedEvent extends FileEvent {
  MovedEvent(String path, bool isRemote)
      : super(FSEventType.moved, path, isRemote);
}
class SyncedEvent extends FileEvent {
  final int current;
  SyncedEvent(String path, bool isRemote, this.current)
      : super(FSEventType.synced, path, isRemote);
}
class UnsyncedEvent extends FileEvent {
  final int lastSynced;
  UnsyncedEvent(String path, bool isRemote, this.lastSynced)
      : super(FSEventType.unsynced, path, isRemote);
}
class ConflictEvent extends FileEvent {
  final int remoteVersion;
  ConflictEvent(String path, bool isRemote, this.remoteVersion)
      : super(FSEventType.conflicting, path, isRemote);
}

abstract class FolderEvent extends FSEvent {
  FolderEvent(FSEventType type, String path, bool isRemote)
      : super(type, path, isRemote);
}
class EntryRemovalEvent extends FolderEvent {
  final String name;
  EntryRemovalEvent(String path, bool isRemote, this.name)
      : super(FSEventType.entry_removal, path, isRemote);
}
class EntryAdditionEvent extends FolderEvent {
  final ListingEntry entry;
  EntryAdditionEvent(String path, bool isRemote, this.entry)
      : super(FSEventType.entry_addition, path, isRemote);
}
class EntryRenamingEvent extends FolderEvent {
  final String oldName;
  final String newName;
  EntryRenamingEvent(String path, bool isRemote, this.oldName, this.newName)
      : super(FSEventType.entry_renaming, path, isRemote);
}

class ListingEntry {
  final FSItemType type;
  /// This is name of an entity in its parent folder.
  final String name;
  ListingEntry(this.type, this.name);
}

abstract class ReadonlyFileVersionedAPI {

  Future<Tuple2<int, XAttr?>> getXAttr(String xaName);

  Future<Tuple2<int, List<String>>> listXAttrs();

  /// Returns either non-empty byte array, or null, with file version.
  ///
  /// Optional [start] parameter, setting a beginning of read. If
  /// missing, read will be done as if neither start, nor end parameters
  /// are given.
  /// Optional [end] parameter, setting an end of read. If end is greater than
  /// file length, all available bytes are read. If parameter is missing, read
  /// will be done to file's end.
  Future<Tuple2<int, Uint8List?>> readBytes([ int? start, int? end ]);

  /// Returns text, read from file, assuming utf8 encoding, with file version.
  Future<Tuple2<int, String>> readTxt();

  /// Returns bytes source with seek, which allows random reads, with file
  /// version.
  Future<Tuple2<int, FileByteSource>> getByteSource();

}

abstract class WritableFile extends ReadonlyFile {

  final WritableFileVersionedAPI? v;

  WritableFile(this.v, String name, bool isNew)
      : super(true, v, name, isNew);

  /// Updates extended attributes of this file.
  ///
  /// [changes] is an object with changes to attributes. Note these are
  /// explicit changes of extended attributes, not an implicit replacement.
  Future<void> updateXAttrs(XAttrsChanges changes);

  /// Writes given [bytes] as complete content to this file.
  Future<void> writeBytes(Uint8List bytes);

  /// Write given [txt], using utf8 encoding, as complete content to this file.
  Future<void> writeTxt(String txt);

  /// Makes bytes sink with seek, allowing random reads, to this file.
  ///
  /// [truncateFile] is an optional flag that truncates file content before any
  /// bytes are writen to produced sink. When flag is false, produced sink
  /// updates existing bytes. Default value is true.
  Future<FileByteSink> getByteSink([ bool truncateFile ]);

  /// Copies content of given [file] into this file.
  Future<void> copy(ReadonlyFile file);

}

abstract class WritableFileVersionedAPI extends ReadonlyFileVersionedAPI {

  /// Updates extended attributes of this file, also giving new version.
  ///
  /// [changes] is an object with changes to attributes. Note these are
  /// explicit changes of extended attributes, not an implicit replacement.
  Future<int> updateXAttrs(XAttrsChanges changes);

  /// Writes given [bytes] as complete content of this file, also giving new
  /// version.
  Future<int> writeBytes(Uint8List bytes);

  /// Writes given [txt] as complete content of file file, also giving new
  /// version.
  Future<int> writeTxt(String txt);

  /// Makes bytes sink with seek, allowing random reads, to file at [path], also
  /// giving new version.
  ///
  /// [truncateFile] is an optional flag that truncates file content before any
  /// bytes are written to produced sink. When flag is false, produced sink
  /// updates existing bytes. Default value is true.
  /// [currentVersion] is an optional parameter, for non-truncated sink. When
  /// current version is given, an error is thrown, if file version at the
  /// moment of writing is different.
  Future<Tuple2<int, FileByteSink>> getByteSink({
    bool truncateFile, int? currentVersion
  });

  /// Copies content of given file into this file
  Future<int> copy(ReadonlyFile file);

}
