class EmailValidator {
  static String? validate(String? value) {
    if (value!.isEmpty) {
      return 'Email can\'t be empty';
    } else {
      return null;
    }
  }
}

class PasswordValidator {
  static String? validate(String? value) {
    if (value!.isEmpty) {
      return 'Password can\'t be empty';
    } else {
      return null;
    }
  }
}

class NameValidator {
  static String? validate(String? value) {
    if (value!.isEmpty) {
      return 'Name can\'t be empty';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    if (value.length > 15) {
      return 'Name must be less than 15 characters';
    } else {
      return null;
    }
  }
}
