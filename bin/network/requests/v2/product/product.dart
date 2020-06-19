import '../../../../data/additives_list.dart';
import '../../../../utils/text_utils.dart';
import 'product_allergens.dart';
import 'product_analysis.dart';
import 'product_ingredients.dart';
import 'product_nutrition.dart';
import 'product_pictures.dart';
import 'product_traces.dart';

class ProductV2 {
  final String name;
  final String altName;
  final String barcode;
  final ProductPictures pictures;
  final String quantity;
  final List<String> brands;
  final List<String> countries;
  final List<String> manufacturingCountries;
  final List<String> packaging;
  final List<String> stores;
  final String nutriScore;
  final String novaScore;
  final int nutritionScore;
  final ProductIngredients ingredients;
  final ProductTraces traces;
  final ProductAllergens allergens;
  final Map<String, String> additives;
  final ProductNutrientLevels nutrientLevels;
  final ProductNutritionFacts nutritionFacts;
  final ProductAnalysis analysis;

  ProductV2.fromAPI(Map<String, dynamic> api, String lng)
      : name = api['product']['product_name_$lng'] ??
            api['product']['product_name'],
        altName = api['product']['generic_name_$lng'] ??
            api['product']['generic_name'],
        barcode = api['code'],
        pictures = ProductPictures.fromAPI(api['product']),
        quantity = api['product']['quantity'],
        nutritionScore =
            api['product']['nutriments']['nutrition-score-fr_100g'],
        brands = TextUtils.stringToList(api['product']['brands']),
        stores = TextUtils.stringToList(api['product']['stores']),
        countries = TextUtils.stringToList(api['product']['countries']),
        manufacturingCountries =
            TextUtils.stringToList(api['product']['manufacturing_places']),
        packaging = TextUtils.stringToList(api['product']['packaging']),
        nutriScore = api['product']['nutrition_grades'],
        novaScore = api['product']['nova_groups'],
        ingredients = ProductIngredients.fromAPI(api['product'], lng),
        traces = ProductTraces.fromAPI(api['product'], lng),
        allergens = ProductAllergens.fromAPI(api['product'], lng),
        additives = extractAdditives(api['product']['additives_tags']),
        nutritionFacts = ProductNutritionFacts.fromAPI(
            api['product']['nutriments'], api['product']['serving_size']),
        nutrientLevels = ProductNutrientLevels.fromAPI(
            api['product']['nutrient_levels'], api['product']['nutriments']),
        analysis = ProductAnalysis.fromAPI(
            api['product']['ingredients_analysis_tags']);

  static Map<String, String> extractAdditives(List additivesTags) {
    if (additivesTags == null || additivesTags.isEmpty) {
      return null;
    }

    Map<String, String> res = {};

    for (var additive in additivesTags) {
      if (additive is String) {
        var additiveId = additive.split(':')[1].toUpperCase();
        var additiveName = additivesList[additiveId];

        if (additiveId != null && additiveName != null) {
          res[additiveId] = additiveName;
        }
      }
    }

    return res.isEmpty ? null : res;
  }

  Map<String, dynamic> toJson(String language) {
    return {
      'name': name,
      'altName': altName,
      'barcode': barcode,
      'pictures': pictures.toJson(),
      'quantity': quantity,
      'brands': brands,
      'stores': stores,
      'countries': countries,
      'manufacturingCountries': manufacturingCountries,
      'nutriScore': nutriScore?.toUpperCase(),
      'novaScore': novaScore,
      'nutritionScore': nutritionScore,
      'ingredients': ingredients.toJson(language),
      'nutrientLevels': nutrientLevels.toJson(),
      'nutritionFacts': nutritionFacts.toJson(),
      'traces': traces.toJson(language),
      'additives': additives,
      'allergens': allergens.toJson(language),
      'packaging': packaging,
      'analysis': analysis.toJson()
    };
  }
}
