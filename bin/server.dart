import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

import 'network.dart';

main(List<String> args) async {
  var parser = ArgParser()..addOption('port', abbr: 'p', defaultsTo: '8080');

  var result = parser.parse(args);

  var port = int.tryParse(result['port']);

  if (port == null) {
    stdout.writeln(
        'Could not parse port value "${result['port']}" into a number.');
    // 64: command line usage error
    exitCode = 64;
    return;
  }

  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(_echoRequest);

  var server = await io.serve(handler, 'localhost', port);
  print('Serving at http://${server.address.host}:${server.port}');
}

Future<shelf.Response> _echoRequest(shelf.Request request) async {
  var url = request.url;
  if (request.method == "GET" && url.path.startsWith("getProduct")) {
    String barcode = url.queryParameters['barcode'];

    if (barcode == null || barcode.isEmpty) {
      return shelf.Response.internalServerError(
          body: json.encode({'response': null, 'error': 'Barcode is missing'}),
          headers: headers());
    }

    var product = await findProductByBarcode(barcode);
    if (product == null) {
      return shelf.Response.notFound(
          json.encode({
            'response': null,
            'error': 'Product with barcode $barcode not found'
          }),
          headers: headers());
    } else {
      return shelf.Response.ok(
          json.encode({'response': product.toJson(), 'error': null}),
          headers: headers());
    }
  }

  return shelf.Response.internalServerError();
}

Map<String, String> headers() => {"Content-type": "application/json"};
