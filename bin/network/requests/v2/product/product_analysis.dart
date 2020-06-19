class ProductAnalysis {
  ProductAnalysisValue palmOil;
  ProductAnalysisValue vegan;
  ProductAnalysisValue vegetarian;

  ProductAnalysis.fromAPI(List tags)
      : palmOil = extractAnalysisValue(tags,
            trueLabel: 'en:palm-oil-free',
            falseLabel: 'en:palm-oil',
            unknownLabel: 'en:palm-oil-content-unknown',
            maybeLabel: 'en:may-contain-palm-oil'),
        vegan = extractAnalysisValue(tags,
            trueLabel: 'en:vegan',
            falseLabel: 'en:non-vegan',
            unknownLabel: 'en:vegan-status-unknown',
            maybeLabel: 'en:maybe-vegan'),
        vegetarian = extractAnalysisValue(tags,
            trueLabel: 'en:vegetarian',
            falseLabel: 'en:non-vegetarian',
            unknownLabel: 'en:vegetarian-status-unknown',
            maybeLabel: 'en:maybe-vegetarian');

  static ProductAnalysisValue extractAnalysisValue(List tags,
      {String trueLabel,
      String falseLabel,
      String unknownLabel,
      String maybeLabel}) {
    if (tags?.isEmpty ?? true) {
      return ProductAnalysisValue.unknown;
    } else if (tags.contains(trueLabel)) {
      return ProductAnalysisValue.yes;
    } else if (tags.contains(falseLabel)) {
      return ProductAnalysisValue.no;
    } else if (tags.contains(unknownLabel)) {
      return ProductAnalysisValue.unknown;
    } else if (tags.contains(maybeLabel)) {
      return ProductAnalysisValue.maybe;
    } else {
      return ProductAnalysisValue.unknown;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'palmOil': palmOil.toValue(),
      'vegan': vegan.toValue(),
      'vegetarian': vegetarian.toValue()
    };
  }
}

enum ProductAnalysisValue { yes, no, maybe, unknown }

extension ProductAnalysisValueExt on ProductAnalysisValue {
  String toValue() {
    switch (this) {
      case ProductAnalysisValue.yes:
        return 'yes';
      case ProductAnalysisValue.no:
        return 'no';
      case ProductAnalysisValue.maybe:
        return 'maybe';
      case ProductAnalysisValue.unknown:
      default:
        return 'unknown';
    }
  }
}
