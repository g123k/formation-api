import 'dart:convert';

import 'package:http/http.dart' as http;

const String _baseUrl = 'https://fr.openfoodfacts.org';

Future<dynamic> findProductByBarcode(String barcode) async {
  print('Finding product $barcode');

  try {
    var response =
        await http.get(Uri.parse('$_baseUrl/api/v0/produit/$barcode.json'));

    if (response.statusCode != 200) {
      print('Product $barcode not found');
      return null;
    } else {
      var body = json.decode(response.body);

      if (body['status'] == 0 &&
          body['status_verbose'] == 'product not found') {
        return null;
      } else {
        return body;
      }
    }
  } catch (e, trace) {
    print('$e:$trace');
    return null;
  }
}

Future<dynamic> findProductByName(String name) async {
  var productName = name.trim();
  print('Finding product $productName');

  try {
    var response = await http.get(
      Uri.parse(
          '$_baseUrl/cgi/search.pl?search_simple=1&json=1&action=process&search_terms=$productName'),
    );

    if (response.statusCode != 200) {
      print('Product $productName not found');
      return null;
    } else {
      var body = json.decode(response.body);

      if (body['status'] == 0 &&
          body['status_verbose'] == 'product not found') {
        return null;
      } else {
        return body;
      }
    }
  } catch (e, trace) {
    print('$e:$trace');
    return null;
  }
}
