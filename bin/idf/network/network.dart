import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

const String _baseUrl = 'https://data.iledefrance-mobilites.fr/explore';

Future<dynamic> listElevators() async {
  try {
    var queries = {'format': 'json', 'timezone': 'Europe/Berlin', 'lang': 'fr'};

    var response = await http.get(
      Uri.parse(
        path.join(_baseUrl, 'dataset/etat-des-ascenseurs/download'),
      ).replace(queryParameters: queries),
    );

    if (response.statusCode != 200) {
      print('Error response: ${response.statusCode}');
      return null;
    } else {
      return json.decode(response.body);
    }
  } catch (e, trace) {
    print('$e:$trace');
    return null;
  }
}
