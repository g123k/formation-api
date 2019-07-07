import '../../../../data/ingredients_list.dart';
import '../../../../utils/text_utils.dart';

class ProductAllergens {
  final List<String> list;
  final List<_TraceItem> details;

  ProductAllergens.fromAPI(Map<String, dynamic> api, String lng)
      : list = _extractList(api['allergens_tags'], lng),
        details = _extractDetails(api['allergens_tags']);

  static List<String> _extractList(Object tags, String lng) {
    if (tags == null || tags is! List) {
      return null;
    }

    List<String> list = [];

    for (var tag in tags) {
      var translations = ingredientsTranslations[tag];

      var ingredient = findIngredientTranslation(translations, lng);
      if (ingredient != null) {
        list.add(ingredient.value);
      } else {
        print('Ingredient not found tag');
      }
    }

    return list;
  }

  static List<_TraceItem> _extractDetails(Object tags) {
    if (tags == null || tags is! List) {
      return null;
    }

    List<_TraceItem> list = [];

    for (var tag in tags) {
      list.add(_TraceItem.fromAPI(tag));
    }

    return list;
  }

  Map<String, Object> toJson(String language) {
    if (list == null || list.isEmpty) {
      return null;
    } else if (TextUtils.isNotEmpty(language)) {
      return {
        'list': list,
      };
    } else {
      return {
        'list': list,
        'details': details?.map((i) => i.toJson())?.toList(growable: false)
      };
    }
  }
}

class _TraceItem {
  final String id;
  final List<IngredientTranslation> translations;

  _TraceItem.fromAPI(this.id) : translations = ingredientsTranslations[id];

  Map<String, Object> toJson() => {
        'translations':
            translations?.map((t) => t.toJson())?.toList(growable: false)
      };
}
