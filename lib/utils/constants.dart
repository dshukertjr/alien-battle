import 'dart:math';

String generateRandomString() {
  const len = 24;
  var r = Random();
  return String.fromCharCodes(
      List.generate(len, (index) => r.nextInt(33) + 89));
}

const initialHealthPoints = 100.0;
