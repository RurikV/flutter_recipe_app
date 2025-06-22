/// A wrapper class for safely accessing ingredient properties
class SafeIngredient {
  final dynamic _ingredient;

  SafeIngredient(this._ingredient);

  String get name {
    if (_ingredient == null) return '';
    try {
      return _ingredient.name ?? '';
    } catch (e) {
      return '';
    }
  }

  String get quantity {
    if (_ingredient == null) return '';
    try {
      return _ingredient.quantity ?? '';
    } catch (e) {
      return '';
    }
  }

  String get unit {
    if (_ingredient == null) return '';
    try {
      return _ingredient.unit ?? '';
    } catch (e) {
      return '';
    }
  }
}