part of 'isolator.dart';

abstract class Logger {
  static const String FRONTEND = '[FRONTEND]';
  static const String BACKEND = '[BACKEND]';
  static const String MESSAGE_BUS = '[MESSAGE BUS]';

  static _log(String prefix, String message, {dynamic value, dynamic id}) {
    print('$prefix${_printId(id)} - $message${_printValue(value)}');
  }

  static _printValue(dynamic value) => (value == null || !IsolatorConfig._instance.showValuesInLogs) ? '' : ' - Value was: $value';

  static _printId(dynamic id) => id == null ? '' : ' - [ID: $id]';

  static sendToBackend(dynamic id, dynamic value) {
    if (IsolatorConfig._instance.logEvents) {
      _log(FRONTEND, 'Send message from frontend to backend', value: value, id: id);
    }
  }

  static sendToFrontend(dynamic id, dynamic value) {
    if (IsolatorConfig._instance.logEvents) {
      _log(BACKEND, 'Send message from backend to frontend', value: value, id: id);
    }
  }

  static frontendError(dynamic id) {
    if (IsolatorConfig._instance.logErrors) {
      _log(FRONTEND, 'An error was thrown in backend, see logs for additional information', id: id);
    }
  }

  static gotFromBackend(dynamic id, dynamic value) {
    if (IsolatorConfig._instance.logEvents) {
      _log(FRONTEND, 'Got a message from backend', value: value, id: id);
    }
  }

  static gotFromFrontend(dynamic id, dynamic value) {
    if (IsolatorConfig._instance.logEvents) {
      _log(BACKEND, 'Got a message from frontend', value: value, id: id);
    }
  }

  static frontendCallback(dynamic id) {
    if (IsolatorConfig._instance.logEvents) {
      _log(FRONTEND, 'Run callback on event', id: id);
    }
  }

  static runBackendMethod(dynamic id, dynamic value) {
    if (IsolatorConfig._instance.logEvents) {
      _log(FRONTEND, 'Run backend\'s method in sync mode in frontend', value: value, id: id);
    }
  }

  static gotFromBackendMethod(dynamic id, dynamic value) {
    if (IsolatorConfig._instance.logEvents) {
      _log(FRONTEND, 'Got a response from backend\'s method in sync mode in frontend', value: value, id: id);
    }
  }

  static durationOnFrontend(double sendTime, dynamic id) {
    if (IsolatorConfig._instance.logTimeOfDataTransfer) {
      _log(FRONTEND, 'Duration of transmission of this message from backend to frontend was ${sendTime.toStringAsFixed(3)}ms', id: id);
    }
  }

  static durationOnBackend(double sendTime, dynamic id) {
    if (IsolatorConfig._instance.logTimeOfDataTransfer) {
      _log(BACKEND, 'Duration of transmission of this message from frontend to backend was ${sendTime.toStringAsFixed(3)}ms', id: id);
    }
  }

  static longDurationOnFrontend(double sendTime, dynamic id) {
    if (IsolatorConfig._instance.logLongOperations && sendTime > (1000 / 60)) {
      _log(FRONTEND, '[SLOW FRAMERATE] - Duration of transmission of data was larger than ${(1000 / 60).toStringAsFixed(3)}ms and took ${sendTime.toStringAsFixed(3)}ms', id: id);
    }
  }
}
