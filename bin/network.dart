import 'dart:convert';

import 'package:http/http.dart' as http;

import 'model.dart';

Future<Product> findProductByBarcode(String barcode) async {
  print("Finding product $barcode");

  try {
    var response = await http
        .get('https://fr.openfoodfacts.org/api/v0/produit/$barcode.json');

    if (response.statusCode != 200) {
      print("Product $barcode not found");
      return null;
    } else {
      return Product.fromAPI(json.decode(response.body));
    }
  } catch (e, trace) {
    print('$e:$trace');
    return null;
  }
}
