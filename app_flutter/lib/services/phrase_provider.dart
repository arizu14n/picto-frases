import 'package:flutter/material.dart';
import 'package:app_flutter/models/pictogram.dart';

class PhraseProvider with ChangeNotifier {
  final List<Pictogram> _currentPhrase = [];

  List<Pictogram> get currentPhrase => _currentPhrase;

  void addPictogram(Pictogram pictogram) {
    _currentPhrase.add(pictogram);
    notifyListeners();
  }

  void addText(String text) {
    if (text.isNotEmpty) {
      _currentPhrase.add(Pictogram.fromText(text));
      notifyListeners();
    }
  }

  void removePictogram(Pictogram pictogram) {
    _currentPhrase.remove(pictogram);
    notifyListeners();
  }

  void clearPhrase() {
    _currentPhrase.clear();
    notifyListeners();
  }

  void onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Pictogram item = _currentPhrase.removeAt(oldIndex);
    _currentPhrase.insert(newIndex, item);
    notifyListeners();
  }
}