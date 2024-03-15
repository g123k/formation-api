import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart' as shelf;

import '../utils/network/request.dart';

Future<shelf.Response> middlewareToComicVine(InternalRequest request) async {
  // https://comicvine.gamespot.com/api/characters&api_key=ac0e4b56140119e1bf5433a18cbd8d63772bac5c&format=json&limit=20

  var endpoint = request.queryParameters('url');
  if (endpoint == null || endpoint.trim().isEmpty) {
    return shelf.Response.badRequest(
        headers: {'Access-Control-Allow-Origin': '*'});
  }

  var params = Map<String, String>.from(request.queryAllParameters);
  params.removeWhere((key, value) => key == 'url');

  var uri = Uri.parse('https://comicvine.gamespot.com/api/$endpoint')
      .replace(queryParameters: params);

  var response = await http.get(uri);
  if (response.statusCode == 200) {
    return shelf.Response.ok(response.body, headers: {
      'Access-Control-Allow-Origin': '*',
      'Content-Type': 'application/json; charset=utf-8',
    });
  } else {
    return shelf.Response.badRequest(
      body: response.body,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json; charset=utf-8',
      },
    );
  }
}
