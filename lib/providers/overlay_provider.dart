import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../overlay/overlay_service.dart';

/// Overlay Provider for state management
class OverlayProvider extends ChangeNotifier {
  bool _isOverlayActive = false;
  bool _isWatching = false;
  PopupSizeMode _currentSize = PopupSizeMode.medium;
  String _currentMode = 'Crush';
  String _ocrText = '';
  String? _sessionId;

  bool get isOverlayActive => _isOverlayActive;
  bool get isWatching => _isWatching;
  PopupSizeMode get currentSize => _currentSize;
  String get currentMode => _currentMode;
  String get ocrText => _ocrText;
  String? get sessionId => _sessionId;

  /// Start overlay
  Future<void> startOverlay() async {
    await OverlayService.startOverlay();
    _isOverlayActive = true;
    notifyListeners();
  }

  /// Close overlay
  Future<void> closeOverlay() async {
    await OverlayService.closeOverlay();
    _isOverlayActive = false;
    _isWatching = false;
    notifyListeners();
  }

  /// Start watching
  void startWatching(String mode) {
    _currentMode = mode;
    OverlayService.startWatching(mode);
    _isWatching = true;
    notifyListeners();
  }

  /// Stop watching
  void stopWatching() {
    OverlayService.stopWatching();
    _isWatching = false;
    notifyListeners();
  }

  /// Update mode
  void updateMode(String mode) {
    _currentMode = mode;
    OverlayService.updateMode(mode);
    notifyListeners();
  }

  /// Resize popup
  void resize(PopupSizeMode size) {
    _currentSize = size;
    notifyListeners();
  }

  /// Update OCR text
  void updateOcrText(String text) {
    _ocrText = text;
    notifyListeners();
  }

  /// Update session
  void updateSession(String sessionId) {
    _sessionId = sessionId;
    notifyListeners();
  }
}