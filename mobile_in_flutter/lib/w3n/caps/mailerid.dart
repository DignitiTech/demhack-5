
import '../userid.dart';

abstract class MailerId {

  /// Returns id (address) of a current signed user
  Future<UserId> getUserId();

  Future<String> login(String serviceUrl);

}