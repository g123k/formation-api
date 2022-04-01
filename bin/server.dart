import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

import 'idf/idf_server.dart';
import 'off/off_server.dart';
import 'utils/network/request.dart';

Future runServer(int port) async {
  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(_onNewRequest);

  var server = await io.serve(handler, 'localhost', port);
  server.autoCompress = true;
  print('Serving at http://${server.address.host}:${server.port}');
}

Future<shelf.Response> _onNewRequest(shelf.Request request) async {
  try {
    var urlRequest = InternalRequest(request.url, request.method);

    if (urlRequest.method == RequestMethod.GET) {
      switch (urlRequest.endpoint) {
        case 'off_getProduct':
        case 'getProduct':
          return await getProductRequest(urlRequest);
        case 'off_findProduct':
        case 'findProduct':
          return await findProductRequest(urlRequest);
        case 'idf_elevators':
          return await findElevators(urlRequest);
      }
    }

    return shelf.Response.internalServerError();
  } catch (e, trace) {
    print('$e\n$trace');
    return shelf.Response.internalServerError();
  }
}

Map<String, String> defaultResponseHeaders() => {
      'Content-type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    };
