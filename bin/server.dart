import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

import 'network/network.dart';
import 'network/request.dart';
import 'network/requests/v1/product/product.dart';
import 'network/requests/v2/product/product.dart';
import 'network/response.dart';

void runServer(int port) async {
  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(_onNewRequest);

  var server = await io.serve(handler, 'localhost', port);
  print('Serving at http://${server.address.host}:${server.port}');
}

Future<shelf.Response> _onNewRequest(shelf.Request request) async {
  try {
    var urlRequest = InternalRequest(request.url, request.method);

    if (urlRequest.method == RequestMethod.GET &&
        urlRequest.endpoint == 'getProduct') {
      return await _getProductRequest(urlRequest);
    }

    return shelf.Response.internalServerError();
  } catch (e, trace) {
    print('$e\n$trace');
    return shelf.Response.internalServerError();
  }
}

Future<shelf.Response> _getProductRequest(InternalRequest request) async {
  String barcode = request.queryParameters('barcode');

  if (barcode == null || barcode.isEmpty) {
    return shelf.Response.internalServerError(
        body: InternalResponse.error('Barcode is missing').toJson(),
        headers: defaultResponseHeaders());
  }

  var resp = await findProductByBarcode(barcode);
  if (resp == null) {
    return shelf.Response.notFound(
        InternalResponse.error('Product with barcode $barcode not found')
            .toJson(),
        headers: defaultResponseHeaders());
  } else {
    if (request.version == 2) {
      String language =
          request.queryParameters('lng') ?? request.queryParameters('language');

      return shelf.Response.ok(
          InternalResponse.data(
                  ProductV2.fromAPI(resp, language ?? 'fr').toJson(language))
              .toJson(),
          headers: defaultResponseHeaders());
    } else {
      return shelf.Response.ok(
          InternalResponse.data(Product.fromAPI(resp)).toJson(),
          headers: defaultResponseHeaders());
    }
  }
}

Map<String, String> defaultResponseHeaders() =>
    {'Content-type': 'application/json', 'Access-Control-Allow-Origin': '*'};
