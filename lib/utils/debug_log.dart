// Common utility file for debug logging
// ignore_for_file: avoid_print

class DebugLog {
  static void log(String message) {
    // Only log in debug mode
    assert(() {
      print(message);
      return true;
    }());
  }
}
