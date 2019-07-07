import 'package:queries/collections.dart';

class TextUtils {
  const TextUtils._();

  static String parseString(dynamic value) {
    if (value == null) {
      return null;
    } else if (value is String) {
      return value;
    } else {
      return value.toString();
    }
  }

  static bool isEmpty(String text) {
    if (text == null) {
      return true;
    } else {
      return text.isEmpty;
    }
  }

  static bool isNotEmpty(String text) {
    if (text == null) {
      return false;
    } else {
      return text.isNotEmpty;
    }
  }

  static List<String> stringToList(String text) {
    if (text == null || text.isEmpty) {
      return null;
    }

    RegExp('\\(.*?\\)').allMatches(text).forEach((match) {
      var group = match.group(0);
      text = text.replaceAll(
          group,
          group
              .replaceAll(',', '****')
              .replaceFirst('en:', '')
              .replaceFirst('fr:', ''));
    });

    return Collection(text
            .split(',')
            .map((item) => item
                .replaceAll('****', ',')
                .replaceFirst('en:', '')
                .replaceFirst('fr:', '')
                .trim())
            .toList(growable: false))
        .distinct()
        .toList(growable: false);
  }
}
