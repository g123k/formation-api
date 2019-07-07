import '../../../../data/additives_list.dart';
import '../../../../utils/text_utils.dart';

class Product {
  final String name;
  final String altName;
  final String barcode;
  final String picture;
  final String quantity;
  final List<String> brands;
  final List<String> countries;
  final List<String> manufacturingCountries;
  final String nutriScore;
  final String novaScore;
  final List<String> ingredients;
  final List<String> traces;
  final List<String> allergens;
  final Map<String, String> additives;
  final NutrientLevels nutrientLevels;
  final NutritionFacts nutritionFacts;
  final bool ingredientsFromPalmOil;

  Product.fromAPI(Map<String, dynamic> api)
      : name = api['product']['product_name'],
        altName = api['product']['generic_name_fr'],
        barcode = api['code'],
        picture = api['product']['image_front_url'],
        quantity = api['product']['quantity'],
        brands = TextUtils.stringToList(api['product']['brands']),
        countries = TextUtils.stringToList(api['product']['countries']),
        manufacturingCountries =
            TextUtils.stringToList(api['product']['manufacturing_places']),
        nutriScore = api['product']['nutrition_grades'],
        novaScore = api['product']['nova_groups'],
        ingredients =
            TextUtils.stringToList(api['product']['ingredients_text_fr']),
        traces = TextUtils.stringToList(api['product']['traces']),
        allergens = TextUtils.stringToList(api['product']['allergens']),
        additives = _extractAdditives(api['product']['additives_tags']),
        nutritionFacts = NutritionFacts.fromAPI(
            api['product']['nutriments'], api['product']['serving_size']),
        nutrientLevels =
            NutrientLevels.fromAPI(api['product']['nutrient_levels']),
        ingredientsFromPalmOil = extractPalmOil(
            api['product']['ingredients_from_or_that_may_be_from_palm_oil_n']);

  static Map<String, String> _extractAdditives(List additivesTags) {
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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'altName': altName,
      'barcode': barcode,
      'picture': picture,
      'quantity': quantity,
      'brands': brands,
      'countries': countries,
      'manufacturingCountries': manufacturingCountries,
      'nutriScore': nutriScore,
      'novaScore': novaScore,
      'ingredients': ingredients,
      'traces': traces,
      'additives': additives,
      'allergens': allergens,
      'nutrientLevels': nutrientLevels.toJson(),
      'nutritionFacts': nutritionFacts.toJson(),
      'containsPalmOil': ingredientsFromPalmOil
    };
  }

  static bool extractPalmOil(dynamic object) {
    if (object == null || object is! num) {
      return false;
    }
    return object >= 1;
  }
}

class NutritionFacts {
  final String servingSize;
  final Nutriment calories;
  final Nutriment fat;
  final Nutriment saturatedFat;
  final Nutriment carbohydrate;
  final Nutriment sugar;
  final Nutriment fiber;
  final Nutriment proteins;
  final Nutriment sodium;
  final Nutriment salt;
  final Nutriment energy;

  NutritionFacts.fromAPI(Map<String, dynamic> api, dynamic servingSize)
      : servingSize = servingSize,
        calories = Nutriment.fromAPI(api, 'calories'),
        fat = Nutriment.fromAPI(api, 'fat'),
        saturatedFat = Nutriment.fromAPI(api, 'saturated-fat'),
        carbohydrate = Nutriment.fromAPI(api, 'carbohydrates'),
        sugar = Nutriment.fromAPI(api, 'sugars'),
        fiber = Nutriment.fromAPI(api, 'fiber'),
        proteins = Nutriment.fromAPI(api, 'proteins'),
        sodium = Nutriment.fromAPI(api, 'sodium'),
        energy = Nutriment.fromAPI(api, 'energy'),
        salt = Nutriment.fromAPI(api, 'salt');

  static String extractServingSizeQuantity(dynamic servingSize) {
    if (servingSize == null || servingSize is! String) {
      return null;
    }

    var lastIndex = (servingSize as String).lastIndexOf(' ');
    return (servingSize as String).substring(0, lastIndex);
  }

  static String extractServingSizeUnit(dynamic servingSize) {
    if (servingSize == null || servingSize is! String) {
      return null;
    }

    var splitted = (servingSize as String).trim().split(" ");
    if (splitted.isNotEmpty) {
      return splitted[splitted.length - 1];
    } else {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'servingSize': servingSize,
      'calories': calories.toJson(),
      'fat': fat.toJson(),
      'saturatedFat': saturatedFat.toJson(),
      'carbohydrate': carbohydrate.toJson(),
      'sugar': sugar.toJson(),
      'fiber': fiber.toJson(),
      'proteins': proteins.toJson(),
      'sodium': sodium.toJson(),
      'salt': salt.toJson(),
      'energy': energy.toJson(),
    };
  }
}

class Nutriment {
  final String unit;
  final dynamic perServing;
  final dynamic per100g;

  Nutriment.fromAPI(Map<String, dynamic> api, String name)
      : per100g = api['${name}_100g'],
        perServing = api['${name}_serving'],
        unit = api['${name}_unit'];

  Map<String, dynamic> toJson() {
    if (unit == null && perServing == null && per100g == null) {
      return null;
    }

    return {
      'unit': unit,
      'perServing': perServing.toString(),
      'per100g': per100g.toString()
    };
  }
}

class NutrientLevels {
  final String salt;
  final String saturatedFat;
  final String sugars;
  final String fat;

  NutrientLevels.fromAPI(Map<String, dynamic> api)
      : salt = api['salt'],
        saturatedFat = api['saturated-fat'],
        sugars = api['sugars'],
        fat = api['fat'];

  Map<String, dynamic> toJson() {
    return {
      'fat': fat,
      'salt': salt,
      'saturatedFat': saturatedFat,
      'sugars': sugars
    };
  }
}
