import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

const String _baseUrl =
    'https://us-central1-formation-31b4b.cloudfunctions.net/';

Future<dynamic> searchGame(String game) async {
  try {
    var response = await http.get(
      Uri.parse(
        path.join(_baseUrl, 'searchGame'),
      ).replace(queryParameters: {'game': game}),
    );

    if (response.statusCode != 200) {
      print('Error response: ${response.statusCode}');
      return null;
    } else {
      return response.body;
    }
  } catch (e, trace) {
    print('$e:$trace');
    return null;
  }
}

Future<dynamic> findGame(String gameId) async {
  try {
    var response = await http.get(
      Uri.parse(
        path.join(_baseUrl, 'game'),
      ).replace(queryParameters: {'id': gameId}),
    );

    if (response.statusCode != 200) {
      print('Error response: ${response.statusCode}');
      return null;
    } else {
      return response.body;
    }
  } catch (e, trace) {
    print('$e:$trace');
    return null;
  }
}
