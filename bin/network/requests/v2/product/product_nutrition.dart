class ProductNutritionFacts {
  final String servingSize;
  final _Nutriment calories;
  final _Nutriment fat;
  final _Nutriment saturatedFat;
  final _Nutriment carbohydrate;
  final _Nutriment sugar;
  final _Nutriment fiber;
  final _Nutriment proteins;
  final _Nutriment sodium;
  final _Nutriment salt;
  final _Nutriment energy;

  ProductNutritionFacts.fromAPI(Map<String, dynamic> api, dynamic servingSize)
      : servingSize = servingSize,
        calories = _Nutriment.fromAPI(api, 'calories'),
        fat = _Nutriment.fromAPI(api, 'fat'),
        saturatedFat = _Nutriment.fromAPI(api, 'saturated-fat'),
        carbohydrate = _Nutriment.fromAPI(api, 'carbohydrates'),
        sugar = _Nutriment.fromAPI(api, 'sugars'),
        fiber = _Nutriment.fromAPI(api, 'fiber'),
        proteins = _Nutriment.fromAPI(api, 'proteins'),
        sodium = _Nutriment.fromAPI(api, 'sodium'),
        energy = _Nutriment.fromAPI(api, 'energy'),
        salt = _Nutriment.fromAPI(api, 'salt');

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

class _Nutriment {
  final String unit;
  final dynamic perServing;
  final dynamic per100g;

  _Nutriment.fromAPI(Map<String, dynamic> api, String name)
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

class ProductNutrientLevels {
  final _NutrientLevel salt;
  final _NutrientLevel saturatedFat;
  final _NutrientLevel sugars;
  final _NutrientLevel fat;

  ProductNutrientLevels.fromAPI(
      Map<String, dynamic> nutrientLevels, Map<String, dynamic> nutriments)
      : salt = _NutrientLevel.fromAPI(
            nutrientLevels['salt'], nutriments['salt_100g']),
        saturatedFat = _NutrientLevel.fromAPI(
            nutrientLevels['saturated-fat'], nutriments['saturated-fat_100g']),
        sugars = _NutrientLevel.fromAPI(
            nutrientLevels['sugars'], nutriments['sugars_100g']),
        fat = _NutrientLevel.fromAPI(
            nutrientLevels['fat'], nutriments['fat_100g']);

  Map<String, dynamic> toJson() => {
        'fat': fat?.toJson(),
        'salt': salt?.toJson(),
        'saturatedFat': saturatedFat?.toJson(),
        'sugars': sugars?.toJson()
      };
}

class _NutrientLevel {
  final String level;
  final dynamic quantity;

  _NutrientLevel.fromAPI(this.level, this.quantity);

  Map<String, dynamic> toJson() {
    if (quantity == null || level == null) {
      return null;
    }

    return {
      'level': level,
      'per100g': quantity,
    };
  }
}
