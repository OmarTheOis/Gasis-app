class InputSanitizer {
  static String clean(String value) {
    return value.replaceAll(RegExp(r'[<>{};]'), '').trim();
  }
}
