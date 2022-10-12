extension TextFieldValidators on String {
  bool isValidEmail() {
    return RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
        .hasMatch(this);
  }

  bool isValidPincode() {
    return RegExp('([1-9]{1}[0-9]{5}|[1-9]{1}[0-9]{3}\\s[0-9]{3})')
        .hasMatch(this);
  }

  bool isValidMobileNumber() {
    return RegExp(r'^(?:[+0]9)?[0-9]{10}$').hasMatch(this);
  }

  bool isValidAadhaarNumber() {
    return RegExp(r'^[2-9]{1}[0-9]{3}\s[0-9]{4}\s[0-9]{4}$').hasMatch(this);
  }

  bool isValidDrivingLicenseNumber() {
    return RegExp(
            r'^(([A-Z]{2}[0-9]{2})( )|([A-Z]{2}-[0-9]{2}))((19|20)[0-9][0-9])[0-9]{7}$')
        .hasMatch(this);
  }
}
