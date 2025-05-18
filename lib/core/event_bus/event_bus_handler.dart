import 'dart:async';

class EventBusHandler {
  final StreamController<String> _sessionStreamCtrl =
      StreamController<String>.broadcast();

  Stream<String> get stream => _sessionStreamCtrl.stream;

  void fire(String event) {
    _sessionStreamCtrl.add(event);
  }

  void close() {
    _sessionStreamCtrl.close();
  }

  static const String addEvent = 'add_event';
  static const String removeEvent = 'remove_event';
  static const String updateEvent = 'update_event';
  static const String clearEvent = 'clear_event';
  static const String refreshEvent = 'refresh_event';
}
