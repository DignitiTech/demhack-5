
abstract class Logger {

  Future<void> log(LogType type, String msg, [ Exception? err ]);

}

enum LogType {
  error, info, warning
}
