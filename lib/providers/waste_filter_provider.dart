import 'package:flutter/foundation.dart';

class WasteFilterProvider extends ChangeNotifier {
  Set<String> _filters = {};

  Set<String> get filters => _filters;

  void updateFilters(Set<String> updated) {
    _filters = updated;
    notifyListeners();
  }

  void clear() {
    _filters.clear();
    notifyListeners();
  }
}
