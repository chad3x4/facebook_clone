import 'package:flutter/material.dart';

class FieldLogic {
  late bool _isInputValid;
  late bool _isPasswordValid;
  FieldLogic() {
    _isInputValid = true;
    _isPasswordValid = true;
  }

  bool isEmailValid(String email) {
    const pattern = r'^[\w-]+(\.[\w-]+)*@([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$';

    final regex = RegExp(pattern);

    return regex.hasMatch(email);
  }

  void SetInputValid(bool isValid) {
    _isInputValid = isValid;
  }

  void SetPasswordValid(bool isValid) {
    _isPasswordValid = isValid;
  }
}
