import 'dart:convert';

import 'package:http/http.dart' as http;

Future<dynamic> findProductByBarcode(String barcode) async {
  print("Finding product $barcode");

  try {
    var response = await http
        .get('https://fr.openfoodfacts.org/api/v0/produit/$barcode.json');

    if (response.statusCode != 200) {
      print("Product $barcode not found");
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
