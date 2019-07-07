import '../../../../data/ingredients_list.dart';
import '../../../../utils/text_utils.dart';

class ProductIngredients {
  final List<String> list;
  final List<_IngredientItem> details;
  final bool containsPalmOil;

  ProductIngredients.fromAPI(Map<String, dynamic> api, String lng)
      : list = TextUtils.stringToList(
            api['ingredients_text_$lng'] ?? api['ingredients_text']),
        details = _extractDetails(api['ingredients']),
        containsPalmOil = _extractPalmOil(
            api['ingredients_from_or_that_may_be_from_palm_oil_n']);

  static List<_IngredientItem> _extractDetails(List ingredients) {
    if (ingredients == null || ingredients is! List) {
      return null;
    }

    List<_IngredientItem> list = [];

    for (var ingredient in ingredients) {
      var ingredientItem = _IngredientItem.fromAPI(ingredient);

      if (ingredientItem != null && ingredientItem.translations != null) {
        list.add(ingredientItem);
      } else {
        print('Ingredient not found: $ingredient');
      }
    }

    return list;
  }

  static bool _extractPalmOil(dynamic object) {
    if (object == null || object is! num) {
      return false;
    }
    return object >= 1;
  }

  Map<String, Object> toJson(String language) => {
        'containsPalmOil': containsPalmOil,
        'list': list,
        'details': details
            ?.map((i) {
              if (language != null) {
                var translation =
                    findIngredientTranslation(i.translations, language);
                if (translation != null) {
                  return i.toJson()
                    ..remove('translations')
                    ..addAll({'value': translation.value});
                }
                return translation;
              } else {
                return i.toJson();
              }
            })
            ?.where((i) => i != null)
            ?.toList(growable: false),
      };
}

class _IngredientItem {
  final String id;
  final bool vegan;
  final bool vegetarian;
  final String percent;
  final List<IngredientTranslation> translations;
  final bool containsPalmOil;

  _IngredientItem.fromAPI(Map<String, dynamic> api)
      : id = api['id'],
        vegan = api['vegan'] == 'yes',
        vegetarian = api['vegetarian'] == 'yes',
        percent = api['percent'],
        translations = ingredientsTranslations(api['id']),
        containsPalmOil = api['from_palm_oil'] == 'yes';

  Map<String, Object> toJson() => {
        'vegan': vegan,
        'vegetarian': vegetarian,
        'translations':
            translations?.map((t) => t.toJson())?.toList(growable: false),
        'containsPalmOil': containsPalmOil,
        'percent': percent
      };
}
