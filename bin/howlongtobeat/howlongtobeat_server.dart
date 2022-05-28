import 'package:shelf/shelf.dart' as shelf;

import '../server.dart';
import '../utils/network/request.dart';
import '../utils/network/response.dart';
import 'network.dart';

Future<shelf.Response> searchGames(InternalRequest request) async {
  var game = request.queryParameters('game');

  if (game == null || game.trim().isEmpty) {
    return shelf.Response.internalServerError();
  } else {
    return shelf.Response.ok(
      await searchGame(game),
      headers: defaultResponseHeaders(),
    );
  }
}

Future<shelf.Response> searchGameById(InternalRequest request) async {
  var game = request.queryParameters('id');

  if (game == null || game.trim().isEmpty) {
    return shelf.Response.internalServerError();
  } else {
    return shelf.Response.ok(
      await findGame(game),
      headers: defaultResponseHeaders(),
    );
  }
}
