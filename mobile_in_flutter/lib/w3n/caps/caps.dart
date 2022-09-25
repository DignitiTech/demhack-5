
import './mailerid.dart';
import 'asmail.dart';
import 'logger.dart';
import 'storage.dart';

abstract class CAPs {

  Future<List<CAPType>> listCAPs();

  Future<Logger> getLogCAP();

  Future<ASMail> getMailCAP();

  Future<Storage> getStorageCAP();

  Future<MailerId> getMailerIdCAP();

}

enum CAPType {
  log, mail, storage, mailerid
}
