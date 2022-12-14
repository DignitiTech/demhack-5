
import 'dart:typed_data';

import 'package:tuple/tuple.dart';

import '../userid.dart';
import 'files.dart';
import 'fs.dart';

abstract class ASMail {

  /// Returns id (address) of a current signed user.
  Future<UserId> getUserId();

  final InboxService inbox;

  final DeliveryService delivery;

  ASMail(this.inbox, this.delivery);

}

abstract class InboxService {

  /// Returns info objects for messages that are present on a server.
  ///
  /// To get only messages starting from some point in time, pass [fromTS].
  Future<List<MsgInfo>> listMsgs([ int? fromTS ]);

  /// Removes message from inbox, identified by [msgId]
  Future<void> removeMsg(String msgId);

  /// Returns a message, identified by [msgId].
  Future<IncomingMessage> getMsg(String msgId);

  /// Subscribes inbox events, like notifications about new messages.
  Stream<IncomingMessage> subscribe(InboxEventType event);

}

enum InboxEventType {
  message
}

class MsgInfo {
  final String msgId;
  final String msgType;
  final int deliveryTS;
  MsgInfo({
    required this.msgId, required this.msgType, required this.deliveryTS
  });
}

class IncomingMessage {
  /// Message type can be
  /// (a) "mail" for messages that better be viewed in mail styly UI,
  /// (b) "chat" for messages that better be viewed in chat style UI,
  /// (c) "app:<app-domain>" for application messages, for example, messages
  /// for app with domain app.com should have type "app:app.com".
  final String msgType;
  final String msgId;
  final UserId sender;
  final int deliveryTS;
  final bool establishedSenderKeyChain;
  final ReadonlyFS? attachments;
  final String? subject;
  final String? plainTxtBody;
  final String? htmlTxtBody;
  final String? jsonBody;
  final List<UserId>? carbonCopy;
  final List<UserId>? recipients;
  IncomingMessage({
    required this.msgType, required this.msgId, required this.sender,
    required this.deliveryTS, required this.establishedSenderKeyChain,
    this.subject, this.carbonCopy, this.recipients,
    this.plainTxtBody, this.htmlTxtBody, this.jsonBody, this.attachments
  });
}

class OutgoingMessage {
  /// Message type can be
  /// (a) "mail" for messages that better be viewed in mail style UI,
  /// (b) "chat" for messages that better be viewed in chat style UI,
  /// (c) "app:<app-domain>" for application messages, for example, messages
  /// for app with domain app.com should have type "app:app.com".
  final String msgType;
  final String? msgId;
  final AttachmentsContainer? attachments;
  final String? subject;
  final String? plainTxtBody;
  final String? htmlTxtBody;
  final String? jsonBody;
  final List<UserId>? carbonCopy;
  final List<UserId>? recipients;
  OutgoingMessage({ this.msgType = 'mail',
    this.msgId, this.subject, this.carbonCopy, this.recipients,
    this.plainTxtBody, this.htmlTxtBody, this.jsonBody, this.attachments
  });
}

abstract class DeliveryService {

  /// Performs a pre-flight to [toAddress], returning an allowable total size
  /// of a message.
  Future<int> preFlight(UserId toAddress);

  /// Adds a message for delivery.
  ///
  /// If message requires small amount of network connection, it is set to be
  /// sent immediately. Else, when message is big, or is sent to too many
  /// recipients, it is added to an internal queue for orderly processing.
  /// [recipients] is an array of addresses, where this message should be sent.
  /// [msg] is a message to be sent
  /// [id] is associated with a given message, for referencing it in other
  /// delivery methods. This id should not be confused with ids, generated by
  /// message accepting servers, associated with each message delivery.
  /// [opts] is an optional object with delivery options. Default value has no
  /// defined fields.
  Future<void> addMsg(
    List<UserId> recipients, OutgoingMessage msg, String id,
    [ DeliveryOptions? opts ]
  );

  /// Lists messages currently in a delivery sub-system, even those with
  /// completed delivery process.
  ///
  /// Tuples in returned array have message ids, used when message
  /// was added, and a respective delivery progress info. This shows all
  /// messages currently in a delivery sub-system, even those with completed
  /// delivery process.
  Future<List<Tuple2<String, DeliveryProgress>>> listMsgs();

  /// Return current delivery info. If [id] is not known, null is returned.
  Future<DeliveryProgress?> currentState(String id);

  /// Makes a stream to observe delivery process of a particular message.
  ///
  /// [id] of a message, used when the message was added
  Stream<DeliveryProgress> observeDelivery(String id);

  /// Removes message with [id] from a delivery sub-system.
  ///
  /// [cancelSending] is a flag, which true value forces delivery cancelation
  /// of a message. With a default false value, message is not removed,
  /// if its delivery process hasn't completed, yet.
  Future<void> rmMsg(String id, [ bool? cancelSending ]);

  /// Makes a stream to observe delivery process of all messages.
  Stream<Tuple2<String, DeliveryProgress>> observeAllDeliveries();

}

class DeliveryOptions {

  /// sendImmeditely flag forces immediate delivery with true value.
  final bool sendImmeditely;

  /// localMeta is an optional data field that is attached to this message's
  /// delivery progress. This data never leaves local machine and is
  /// associated with particular delivery.
  final Uint8List? localMeta;

  DeliveryOptions(this.sendImmeditely, [ this.localMeta ]);
}

class DeliveryProgress {
  final bool notConnected;
  final bool allDone;
  final int msgSize;
  final Uint8List? localMeta;
  final Map<UserId, DeliveryInfo> recipients;
  DeliveryProgress({
    required this.recipients, required this.notConnected, required this.allDone,
    required this.msgSize, required this.localMeta
  });
}

class DeliveryInfo {
  final bool done;
  final int bytesSent;
  final String? idOnDelivery;
  final Exception? err;
  DeliveryInfo({
    required this.done, required this.bytesSent, this.idOnDelivery, this.err
  });
}

/// This container is for entities that will be present in attachments
/// fs/folder of recipient's incoming message.
class AttachmentsContainer {
  final Map<String, ReadonlyFile>? files;
  final Map<String, ReadonlyFS>? folders;
  AttachmentsContainer({ this.files, this.folders });
}
