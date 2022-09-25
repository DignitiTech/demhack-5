
import '../userid.dart';

class StartupW3N {

  final SignInService signIn;
  final SignUpService signUp;

  StartupW3N(this.signIn, this.signUp);

}

///  This is a collection of functions, that are are used by startup
///  functionality, when user creates new account in 3NWeb domains.
abstract class SignUpService {

  /// Returns an array of available 3NWeb addresses with a given [name] part of
  /// the address.
  ///
  /// Returned array will be empty, when there are no available addresses for a
  /// given [name].
  /// [signupToken] is an optional signup token, setting context withing which
  /// address availability is done.
  Future<List<UserId>> getAvailableAddresses(
    String name, [ String? signupToken ]
  );

  /// Adds user with [userId], returning an indication whether an account has
  /// been created, or not.
  ///
  /// [signupToken] is an optional signup token, that might be required by
  /// provider.
  Future<bool> addUser(UserId userId, [ String? signupToken ]);

  /// Checks whether given user account is active or not.
  Future<bool> isActivated(UserId userId);

  /// Creates MailerId login and storage secret keys from given [pass].
  ///
  /// Returned future completes when creation completes, and [progressCB] is
  /// called with updates along the way.
  Future<void> createUserParams(String pass, Function(double p) progressCB);

}

/// This is a collection of functions, that are are used by startup
/// functionality, when user signs into existing account, whether already
/// cached on this device, or not.
abstract class SignInService {

  /// Returns an array of users, whose storages are found on a disk.
  Future<List<UserId>> getUsersOnDisk();

  /// Starts a login process, when application is started without user storage
  /// on a disk.
  Future<bool> startLoginToRemoteStorage(UserId userId);

  /// Completes login and setup of user's storage on a disk.
  ///
  /// Returned future resolves to true, when provisioning is done, or to false,
  /// when given password is incorrect.
  /// Entry keys are derived from given [pass].
  /// [progressCB] is a callback for progress notification.
  Future<bool> completeLoginAndLocalSetup(
    String pass, Function(double) progressCB
  );

  /// Initializes core to run from an existing on a disk storage.
  ///
  /// Returned future resolves to true, when password opens storage, and to
  /// false, when given password is incorrect.
  Future<bool> useExistingStorage(
    UserId userId, String pass, Function(double) progressCB
  );

}

