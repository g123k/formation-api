class ProductPictures {
  final String front;
  final String product;
  final String ingredients;
  final String nutrition;

  ProductPictures.fromAPI(Map<String, dynamic> api)
      : front = api['image_front_url'],
        product = api['image_url'],
        ingredients = api['image_ingredients_url'],
        nutrition = api['image_nutrition_url'];

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'front': front,
      'ingredients': nutrition,
      'nutrition': nutrition
    };
  }
}
