part of 'isolator.dart';

typedef FrontendObserver = Future<void> Function(Message<dynamic, dynamic> message);

/// [errorAndStackTrace] can be a [error, stackTrace], or anything else, keep it in mind
typedef BackendErrorObserver = Future<void> Function(dynamic errorAndStackTrace);

/// Configuration class for Isolator (all Backends and it's Frontends)
class IsolatorConfig {
  IsolatorConfig._();

  static IsolatorConfig _instanceProp;

  static IsolatorConfig get _instance => _instanceProp ??= IsolatorConfig._();

  static void setLogging(bool log) => _instance.logEvents = log;

  static void setLoggingErrors(bool log) => _instance.logErrors = log;

  static void setTransferTimeLogging(bool log) => _instance.logTimeOfDataTransfer = log;

  static void setValuesShowing(bool show) => _instance.showValuesInLogs = show;

  static void setInitTimeoutDuration(Duration duration) => _instance.backendInitTimeout = duration;

  static void setFrontendObservers(List<FrontendObserver> observers) => _instance.frontendObservers = observers;

  static void setBackendErrorsObservers(List<BackendErrorObserver> observers) => _instance.backendErrorsObservers = observers;

  /// Enable [Frontend] and [Backend] logging
  bool logEvents = false;

  /// Enable logging errors on [Frontend]
  bool logErrors = true;

  /// Enable logging of time, which requires to transfer [_Message] from frontend to backend and vice versa
  bool logTimeOfDataTransfer = false;

  /// Print or not values in logs
  bool showValuesInLogs = false;

  /// Timeout for init method of every backend
  Duration backendInitTimeout = const Duration(seconds: 10);

  /// Observers, which will running before handling messages from backend, in frontend part
  /// Can be any function
  List<FrontendObserver> frontendObservers = [];

  /// Observers, which will running on every error, which was in backend layer
  /// Can be any function
  List<BackendErrorObserver> backendErrorsObservers = [];

  /// Copy config for use in isolates
  Map<String, dynamic> toJson() => {
        'logEvents': logEvents,
        'logErrors': logErrors,
        'showValuesInLogs': showValuesInLogs,
        'logTimeOfDataTransfer': logTimeOfDataTransfer,
        'backendInitTimeout': backendInitTimeout.inMilliseconds,
      };

  void setParamsFromJson(Map<String, dynamic> json) {
    setLogging(json['logEvents'] ?? false);
    setLoggingErrors(json['logErrors'] ?? true);
    setValuesShowing(json['showValuesInLogs'] ?? false);
    setTransferTimeLogging(json['logTimeOfDataTransfer'] ?? false);
    setInitTimeoutDuration(Duration(milliseconds: json['backendInitTimeout'] ?? 1000 * 10));
  }
}
