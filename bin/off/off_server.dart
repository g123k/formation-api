import 'package:shelf/shelf.dart' as shelf;

import '../server.dart';
import '../utils/network/request.dart';
import '../utils/network/response.dart';
import 'network/network.dart';
import 'network/requests/v1/product/product.dart';
import 'network/requests/v2/product/product.dart';

Future<shelf.Response> getProductRequest(InternalRequest request) async {
  var barcode = request.queryParameters('barcode');

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
      var language = request.queryParameters('lng') ??
          request.queryParameters('language') ??
          'fr';

      return shelf.Response.ok(
          InternalResponse.data(
                  ProductV2.fromAPI(resp, language).toJson(language))
              .toJson(),
          headers: defaultResponseHeaders());
    } else {
      return shelf.Response.ok(
          InternalResponse.data(Product.fromAPI(resp)).toJson(),
          headers: defaultResponseHeaders());
    }
  }
}

Future<shelf.Response> findProductRequest(InternalRequest request) async {
  var search = request.queryParameters('search');

  if (search == null || search.isEmpty) {
    return shelf.Response.internalServerError(
        body: InternalResponse.error('Search is missing').toJson(),
        headers: defaultResponseHeaders());
  }

  var resp = await findProductByName(search);
  if (resp == null || (resp is Map && resp['count'] == 0)) {
    return shelf.Response.notFound(
        InternalResponse.error('No product found with search $search').toJson(),
        headers: defaultResponseHeaders());
  } else {
    var language = request.queryParameters('lng') ??
        request.queryParameters('language') ??
        'fr';

    return shelf.Response.ok(
        InternalResponse.data(Products.fromAPI(resp, language).toJson(language))
            .toJson(),
        headers: defaultResponseHeaders());
  }
}
