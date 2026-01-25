import 'package:flutter/foundation.dart';

class NavState extends ChangeNotifier {
  int index = 0;

  void setIndex(int value) {
    if (value == index) return;
    index = value;
    notifyListeners();
  }
}
