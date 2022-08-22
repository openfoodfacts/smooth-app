import 'dart:math';

class SmoothRandomUtils {
  const SmoothRandomUtils._();

  static String generateRandomString(int length) {
    final Random random = Random();
    const String availableChars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final String randomString = List<String>.generate(
        length,
        (int index) =>
            availableChars[random.nextInt(availableChars.length)]).join();
    return randomString;
  }
}
