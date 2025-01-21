extension UriExtention on Uri {
  static bool isUri(String input) {
    try {
      final uri = Uri.tryParse(input);
      return uri != null && uri.hasScheme && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
