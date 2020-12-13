import 'package:flutter/cupertino.dart';
import 'package:isolator/isolator.dart';

abstract class BaseState<T> with ChangeNotifier, BackendMixin<T> {}
