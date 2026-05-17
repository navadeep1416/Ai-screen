import 'package:flutter/foundation.dart';

class ModeProvider with ChangeNotifier {
  final List<String> _availableModes = [
    'Crush',
    'Friend',
    'Love',
    'Fight',
    'Savage',
    'Funny',
    'Cold',
    'Flirty',
    'Soft',
    'Dating',
    'Relationship',
  ];

  String _currentMode = 'Crush';

  List<String> get availableModes => _availableModes;
  String get currentMode => _currentMode;

  void setMode(String mode) {
    if (_availableModes.contains(mode)) {
      _currentMode = mode;
      notifyListeners();
    }
  }
}
