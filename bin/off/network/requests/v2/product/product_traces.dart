import '../../../../../utils/text_utils.dart';
import '../../../../data/ingredients_list.dart';

class ProductTraces {
  final List<String>? list;
  final List<_TraceItem>? details;

  ProductTraces.fromAPI(Map<String, dynamic> api, String lng)
      : list = _extractList(api['traces_tags'], lng),
        details = _extractDetails(api['traces_tags']);

  static List<String>? _extractList(dynamic tags, String lng) {
    if (tags is! List) {
      return null;
    }

    var list = <String>[];

    for (var tag in tags) {
      var translations = ingredientsTranslations(tag);

      var ingredient = findIngredientTranslation(translations, lng);
      if (ingredient != null) {
        list.add(ingredient.value);
      } else {
        print('Ingredient not found tag');
      }
    }

    return list;
  }

  static List<_TraceItem>? _extractDetails(dynamic tags) {
    if (tags is! List) {
      return null;
    }

    var list = <_TraceItem>[];

    for (var tag in tags) {
      list.add(_TraceItem.fromAPI(tag));
    }

    return list;
  }

  Map<String, dynamic>? toJson(String language) {
    if (list?.isEmpty == true) {
      return null;
    } else if (TextUtils.isNotEmpty(language)) {
      return {
        'list': list,
      };
    } else {
      return {
        'list': list,
        'details': details?.map((i) => i.toJson()).toList(growable: false)
      };
    }
  }
}

class _TraceItem {
  final String id;
  final List<IngredientTranslation>? translations;

  _TraceItem.fromAPI(this.id) : translations = ingredientsTranslations(id);

  Map<String, dynamic> toJson() => {
        'translations':
            translations?.map((t) => t.toJson()).toList(growable: false)
      };
}
