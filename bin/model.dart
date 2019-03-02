import 'package:queries/collections.dart';

class Product {
  final String name;
  final String altName;
  final String barcode;
  final String picture;
  final String quantity;
  final List<String> brands;
  final List<String> manufacturingCountries;
  final String nutriScore;
  final String novaScore;
  final List<String> ingredients;
  final List<String> traces;
  final List<String> allergens;
  final Map<String, String> additives;
  final NutritionFacts nutritionFacts;
  final bool ingredientsFromPalmOil;

  Product.fromAPI(Map<String, dynamic> api)
      : name = api['product']['product_name'],
        altName = api['product']['generic_name_fr'],
        barcode = api['code'],
        picture = api['product']['image_front_url'],
        quantity = api['product']['quantity'],
        brands = stringToList(api['product']['brands']),
        manufacturingCountries =
            stringToList(api['product']['manufacturing_places']),
        nutriScore = api['product']['nutrition_grades'],
        novaScore = api['product']['nova_groups'],
        ingredients = stringToList(api['product']['ingredients_text_fr']),
        traces = stringToList(api['product']['traces']),
        allergens = stringToList(api['product']['allergens']),
        additives = extractAdditives(api['product']['additives_tags']),
        nutritionFacts = NutritionFacts.fromAPI(
            api['product']['nutriments'], api['product']['serving_size']),
        ingredientsFromPalmOil = extractPalmOil(
            api['product']['ingredients_from_or_that_may_be_from_palm_oil_n']);

  static List<String> stringToList(String text) {
    if (text == null || text.isEmpty) {
      return null;
    }

    RegExp('\\(.*?\\)').allMatches(text).forEach((match) {
      var group = match.group(0);
      text = text.replaceAll(group, group.replaceAll(',', '****'));
    });

    return Collection(text
            .split(',')
            .map((item) => item.replaceAll('****', ',').trim())
            .toList(growable: false))
        .distinct()
        .toList(growable: false);
  }

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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'altName': altName,
      'barcode': barcode,
      'picture': picture,
      'quantity': quantity,
      'brands': brands,
      'manufacturingCountries': manufacturingCountries,
      'nutriScore': nutriScore,
      'novaScore': novaScore,
      'ingredients': ingredients,
      'traces': traces,
      'additives': additives,
      'allergens': allergens,
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
  final dynamic servingSizeQuantity;
  final dynamic servingSizeUnit;
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
      : servingSizeQuantity = extractServingSizeQuantity(servingSize),
        servingSizeUnit = extractServingSizeUnit(servingSize),
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
      'servingSize': {
        'unit': servingSizeUnit,
        'quantity': servingSizeQuantity,
      },
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

Map<String, String> additivesList = {
  'E330': 'Acide citrique',
  'E322': 'Lécithines',
  'E14XX': 'Amidons modifiés',
  'E322i': 'Lécithine',
  'E500': 'Carbonates de sodium',
  'E300': 'Acide ascorbique',
  'E250': 'Nitrite de sodium',
  'E415': 'Gomme xanthane',
  'E450': 'Sels métalliques de diphosphates',
  'E471': 'Mono- et diglycérides d\'acides gras alimentaires',
  'E440': 'Pectines',
  'E412': 'Gomme de guar',
  'E202': 'Sorbate de potassium',
  'E407': 'Carraghénanes',
  'E500ii': 'Carbonate acide de sodium',
  'E440i': 'Pectine',
  'E301': 'Ascorbate de sodium',
  'E331': 'Citrates de sodium',
  'E503': 'Carbonates d\'ammonium',
  'E160c': 'Extrait de paprika',
  'E316': 'Erythorbate de sodium',
  'E422': 'Glycérol',
  'E160a': 'Bêta-carotène',
  'E420': 'Sorbitol',
  'E410': 'Farine de graines de caroube',
  'E428': 'Gélatine',
  'E270': 'Acide lactique',
  'E621': 'Glutamate monosodique',
  'E120': 'Acide carminique',
  'E450i': 'Pyrophosphate de sodium acide',
  'E451': 'Triphosphates',
  'E100': 'Curcumine',
  'E160': 'Caroténoïdes',
  'E150a': 'Caramel E150a',
  'E414': 'Gomme d\'acacia',
  'E262': 'Acétates de sodium',
  'E252': 'Nitrate de potassium',
  'E452': 'Polyphosphates',
  'E420i': 'Sorbitol',
  'E955': 'Sucralose',
  'E950': 'Acésulfame K',
  'E160b': 'Rocou',
  'E296': 'Acide malique',
  'E160ai': 'Bêta-carotène',
  'E224': 'Disulfite de potassium',
  'E392': 'Extrait de romarin',
  'E903': 'Cire de carnauba',
  'E163': 'Anthocyanes',
  'E401': 'Alginate de sodium',
  'E282': 'Propionate de calcium',
  'E150d': 'Caramel au sulfite d\'ammonium',
  'E466': 'Carboxyméthylcellulose',
  'E223': 'Disulfite de sodium',
  'E161b': 'Lutéine',
  'E220': 'Anhydride sulfureux',
  'E326': 'Lactate de potassium',
  'E503ii': 'Carbonate acide d\'ammonium',
  'E341': 'Phosphate de calcium d\'hydrogène',
  'E211': 'Benzoate de sodium',
  'E472e': 'Ester Monoacéthyltartrique de mono- et diglycérides d\'acides gras',
  'E476': 'Esters polyglycériques d\'acides gras d\'huile de ricin',
  'E306': 'Extrait riche en tocophérols',
  'E133': 'Bleu brillant FCF',
  'E200': 'Acide sorbique',
  'E171': 'Oxyde de titane',
  'E951': 'Aspartame',
  'E965': 'Maltitol',
  'E481': 'Stéaroyl-2-lactylate de sodium',
  'E325': 'Lactate de sodium',
  'E500i': 'Carbonate de sodium',
  'E150c': 'Caramel ammoniacal',
  'E339': 'Orthophosphates de sodium',
  'E260': 'Acide acétique',
  'E262i': 'Acétate de sodium',
  'E631': 'Inosinate disodique',
  'E162': 'Rouge de betterave',
  'E627': 'Guanylate disodique',
  'E141': 'Complexe cuivrique des chlorophylles',
  'E1400': 'Dextrines',
  'E460': 'Celluloses',
  'E901': 'Cire d\'abeille',
  'E960': 'Glucosides de stéviol',
  'E965i': 'Maltitol',
  'E502': 'Carbonates',
  'E150': 'Caramel',
  'E406': 'Agar-agar',
  'E509': 'Chlorure de calcium',
  'E461': 'Méthylcellulose',
  'E101': 'Riboflavine',
  'E334': 'Acide L-tartrique',
  'E445': 'Esters glycériques de résine de bois',
  'E153': 'Charbon végétal médicinal',
  'E501': 'Carbonates de potassium',
  'E407a': 'Algues euchema transformées',
  'E472b': 'Ester diacétyl-lactique de mono- et diglycérides d\'acides gras',
  'E290': 'Dioxyde de carbone',
  'E304': 'Acide palmityle-6-L-ascorbique',
  'E551': 'Dioxyde de silicium',
  'E1105': 'Lysozyme',
  'E904': 'Gomme-laque',
  'E331iii': 'Citrate trisodique',
  'E385': 'Éthylène diamine tétra-acétate de calcium disodium',
  'E338': 'Acide orthophosphorique',
  'E575': 'Glucono-delta-lactone',
  'E235': 'Natamycine',
  'E333': 'Citrates de calcium',
  'E1510': 'Éthanol',
  'E340': 'Orthophosphates de potassium',
  'E327': 'Lactate de calcium',
  'E102': 'Tartrazine',
  'E336': 'Tartrates de potassium',
  'E222': 'Bisulfite de sodium',
  'E307': 'Alphatocophérol',
  'E420ii': 'Sirop de sorbitol',
  'E170': 'Carbonate de calcium',
  'E131': 'Bleu patenté V',
  'E953': 'Isomalt',
  'E101i': 'Riboflavine',
  'E503i': 'Carbonate d\'ammonium',
  'E524': 'Hydroxyde de sodium',
  'E579': 'Gluconate ferreux',
  'E129': 'Rouge allura AC',
  'E635': '5-ribonucléotide disodique',
  'E172': 'Oxyde de fer',
  'E473': 'Sucroester',
  'E464': 'Hydroxypropylméthylcellulose',
  'E418': 'Gomme gellane',
  'E965ii': 'Sirop de maltitol',
  'E417': 'Gomme tara',
  'E920': 'L-Cystéine et ses chlorhydrates',
  'E320': 'Buthylhydroxyanisol',
  'E967': 'Xylitol',
  'E304i': 'Palmitate d\'ascorbyle',
  'E1200': 'Polydextrose',
  'E451i': 'Triphosphate de sodium',
  'E1442': 'Phosphate de diamidon hydroxypropyle',
  'E475': 'Esters polyglycériques d\'acides gras',
  'E321': 'Buthylhydroxytoluène',
  'E570': 'Acide stéarique',
  'E150b': 'Caramel de sulfite caustique',
  'E307c': 'Tocophérol',
  'E1100': 'Amylases',
  'E350': 'Malate de sodium',
  'E1103': 'Invertase',
  'E251': 'Nitrate de sodium',
  'E1422': 'Adipate de diamidon acétylé',
  'E508': 'Chlorure de potassium',
  'E140': 'Chlorophylles',
  'E132': 'Indigotine carmin d\'indigo',
  'E110': 'Jaune orangé S',
  'E954': 'Saccharine et ses sels',
  'E952': 'Acide cyclamique et ses sels',
  'E160aii': 'Carotènes végétaux',
  'E472c':
      'Ester citrique des mono et diglycérides d\'acides gras alimentaires',
  'E442': 'Phosphatides d\'ammonium',
  'E332': 'Citrates de potassium',
  'E452i': 'Polyphosphate de sodium',
  'E263': 'Acétate de calcium',
  'E262ii': 'Diacétate de sodium',
  'E501i': 'Carbonate de potassium',
  'E421': 'Mannitol',
  'E470b': 'Sels de magnésium d\'acides gras',
  'E175': 'Or',
  'E535': 'Ferrocyanure de sodium',
  'E472a': 'Ester diacétyl-acétique d\'acides gras',
  'E160e': 'Apocaroténal 168',
  'E341i': 'Phosphate monocalcique',
  'E127': 'Érythrosine',
  'E553b': 'Talc',
  'E504': 'Carbonates de magnésium',
  'E1101': 'Protéases',
  'E492': 'Tristéarate de sorbitane',
  'E572': 'Stéarate de magnésium',
  'E339ii': 'Phosphate disodique',
  'E122': 'Azorubine carmoisine',
  'E641': 'L-leucine',
  'E350ii': 'Malate acide de sodium',
  'E450iii': 'Diphosphate tétrasodique',
  'E261': 'Acétates de potassium',
  'E141ii':
      'Sels de sodium et de potassium de complexes cupriques de chlorophyllines',
  'E140ii': 'Chlorophyllines',
  'E435': 'Monostéarate de polyoxyéthylène sorbitane',
  'E140i': 'Chlorophylles',
  'E516': 'Sulfate de calcium',
  'E124': 'Ponceau 4R',
  'E640': 'Glycines',
  'E968': 'Érythritol',
  'E491': 'Monostéarate de sorbitane',
  'E341ii': 'Phosphate dicalcique',
  'E477': 'Esters du propylène-glycol d\'acide gras',
  'E472': 'Esters d\'acides gras alimentaires',
  'E319': 'Butylhydroquinone tertiaire',
  'E460i': 'Cellulose microcristalline',
  'E1414': 'Phosphate de diamidon acétylé',
  'E529': 'Oxyde de calcium',
  'E333iii': 'Citrate tricalcique',
  'E331i': 'Citrate monosodique',
  'E336i': 'Tartrate monopotassique',
  'E1505': 'Citrate de triéthyle',
  'E501ii': 'Carbonate acide de potassium',
  'E340ii': 'Phosphate dipotassique',
  'E440ii': 'Pectine amidée',
  'E1104': 'Lipases',
  'E315': 'Acide érythorbique',
  'E341iii': 'Phosphate tricalcique',
  'E142': 'Vert acide brillant BS',
  'E228': 'Sulfite acide de potassium',
  'E413': 'Gomme de dragon',
  'E310': 'Gallate de propyle',
  'E242': 'Dicarbonate de diméthyle',
  'E444': 'Acétate isobutyrate de saccharose',
  'E221': 'Sulfite de sodium',
  'E1520': 'Propylène glycol',
  'E281': 'Propionate de sodium',
  'E339iii': 'Phosphate trisodique',
  'E151': 'Noir brillant BN',
  'E433': 'Monooléate de polyoxyéthylène de sorbitane',
  'E640i': 'Glycine',
  'E400': 'Acide alginique',
  'E210': 'Acide benzoïque',
  'E141i': 'Complexes cuivriques de chlorophylles',
  'E297': 'Acide fumarique',
  'E203': 'Sorbate de calcium',
  'E172ii': 'Oxyde de fer rouge',
  'E104': 'Jaune de quinoléine',
  'E1450': 'Octényle succinate d\'amidon sodique',
  'E525': 'Hydroxyde de potassium',
  'E470a': 'Stéarate de sodium/potassium/calcium',
  'E536': 'Ferrocyanure de potassium',
  'E249': 'Nitrite de potassium',
  'E425': 'Gomme de konjac',
  'E942': 'Protoxyde d\'azote',
  'E302': 'Ascorbate de calcium',
  'E900': 'Polydiméthylsiloxane',
  'E468': 'Carboxyméthylcellulose de sodium réticulée',
  'E510': 'Chlorure d\'ammonium',
  'E541': 'Phosphate d\aluminium et de sodium',
  'E526': 'Hydroxyde de calcium',
  'E1412': 'Phosphate de diamidon',
  'E482': 'Stéaroyl-2-lactylate de calcium',
  'E280': 'Acide propionique',
  'E405': 'Alginate de propane-35',
  'E959': 'Néohespéridine dihydrochalcone',
  'E450ii': 'Diphosphate trisodique',
  'E404': 'Alginate de calcium',
  'E941': 'Azote',
  'E1404': 'Amidon oxydé',
  'E1420': 'Amidon acétylé',
  'E1518': 'Triacétine',
  'E962': 'Sel d\'aspartame-acésulfame',
  'E232': 'Orthophénylphénate de sodium',
  'E914': 'Cire de polyéthylène oxydée',
  'E340i': 'Phosphate monopotassique',
  'E958': 'Acide glycyrrhizique et sels',
  'E472f':
      'Esters mixtes acétiques et tartriques des mono- et diglycérides d\'acides gras',
  'E576': 'Gluconate de sodium',
  'E285': 'Tétraborate de sodium',
  'E460ii': 'Cellulose en poudre',
  'E555': 'Silicate alumino-potassique',
  'E103': 'Jaune chrysoïne',
  'E350i': 'Malate de sodium',
  'E160d': 'Lycopène',
  'E307b': 'Tocophérol concentré',
  'E234': 'Nisine',
  'E957': 'Thaumatine',
  'E504i': 'Carbonate de magnésium',
  'E182': 'Orseille',
  'E201': 'Sorbate de sodium',
  'E212': 'Benzoate de potassium',
  'E335': 'Tartrate monosodique',
  'E927b': 'Carbamide',
  'E626': 'Acide guanylique',
  'E921': 'Cystine',
  'E620': 'Acide glutamique',
  'E944': 'Propane',
  'E639': 'Alanine',
  'E1102': 'Glucose oxydase',
  'E552': 'Silicate de calcium',
  'E174': 'Argent',
  'E363': 'Acide succinique',
  'E511': 'Chlorure de magnésium',
  'E155': 'Brun chocolat HT',
  'E1201': 'Poly vinyl pyrrolidone',
  'E463': 'Hydroxypropylcellulose',
  'E233': 'Thiabendazole',
  'E514': 'Sulfates de sodium',
  'E355': 'Acide adipique',
  'E332ii': 'Citrate tripotassique',
  'E331ii': 'Citrate disodique',
  'E470': 'Sels de sodium/potassium/calcium d\'acides gras',
  'E925': 'Chlore',
  'E905a': 'Huile minérale de qualité alimentaire',
  'E943a': 'Butane',
  'E515': 'Sulfate de potassium',
  'E1001': 'Sels et esters de choline',
  'E905c': 'Cire de pétrole',
  'E472d': 'Ester tartrique de mono- et diglycérides d\'acides gras',
  'E101ii': 'Riboflavine-5′-phosphate',
  'E411': 'Gomme d\'avoine',
  'E1521': 'Polyéthylène glycol',
  'E650': 'Acétate de zinc',
  'E999': 'Extraits de quillaia',
  'E966': 'Lactitol',
  'E329': 'Lactate de magnésium',
  'E160aiii': 'Bêta-carotène issu de blakeslea trispora',
  'E402': 'Alginate de potassium',
  'E236': 'Acide formique',
  'E225': 'Disulfite de calcium',
  'E160aiv': 'Carotènes d\'algues',
  'E530': 'Oxyde de magnésium Périclase',
  'E963': 'Tagatose',
  'E905': 'Paraffine',
  'E339i': 'Phosphate monosodique',
  'E452ii': 'Polyphosphate potassique',
  'E585': 'Lactate ferreux',
  'E554': 'Silicate alumino-sodique',
  'E943b': 'Isobutane',
  'E713': 'Tylosine Antibiotique',
  'E1519': 'Alcool benzylique',
  'E949': 'Dihydrogène',
  'E487': 'Laurylsulfate de sodium',
  'E364': 'Succinates de sodium',
  'E961': 'Néotame',
  'E15x': 'CI 8',
  'E630': 'Acide inosinique',
  'E218': '4-hydroxybenzoate de méthyle',
  'E636': 'Maltol',
  'E505': 'Carbonate de fer',
  'E507': 'Acide chlorhydrique',
  'E542': 'Phosphate d\'os comestible',
  'E343': 'Orthophosphates de magnésium',
  'E948': 'Dioxygène',
  'E231': 'Orthophénylphénol',
  'E173': 'Aluminium',
  'E580': 'Gluconate de magnésium',
  'E216': '4-hydroxybenzoate de propyle',
  'E500iii': 'Sesquicarbonate de sodium',
  'E180': 'Lithol-rubine BK',
  'E425i': 'Gomme de konjac',
  'E1204': 'Pullulane',
  'E172iii': 'Oxyde de fer jaune',
  'E318': 'Isoascorbate de calcium',
  'E1440': 'Amidon hydroxypropyle',
  'E152': 'Noir de carbone',
  'E1202': 'Polyvinylpolypyrrolidone',
  'E416': 'Gomme karaya',
  'E520': 'Sulfate d\'aluminium',
  'E517': 'Sulfate d\'ammonium',
  'E553a': 'Silicate de magnésium',
  'E166': 'Bois de santal',
  'E266': 'Déhydroacétate de sodium',
  'E559': 'Silicate d\'aluminium',
  'E457': 'Alpha-Cyclodextrine',
  'E450v': 'Diphosphate tétrapotassique',
  'E469': 'Carboxyméthylcellulose hydrolysée de manière enzymatique',
  'E473a': 'Oligoesters de saccharose de type I',
  'E425ii': 'Glucomannane de konjac',
  'E451ii': 'Triphosphate pentapotassique',
  'E522': 'Sulfate d\'aluminium potassique',
  'E452vi': 'Tripolyphosphate de sodium et de potassium',
  'E577': 'Gluconate de potassium',
  'E521': 'Sulfate d\'aluminium sodique',
  'E370': '4-Heptonolactone',
  'E514i': 'Sulfate de sodium',
  'E130': 'Manascorubine',
  'E586': 'Héxylresorcinol',
  'E553ai': 'Silicate de magnésium',
  'E230': 'Biphényle',
  'E462': 'Éthylcellulose',
  'E1411': 'Glycérol de diamidon',
  'E161': 'Xanthophylles',
  'E574': 'Acide gluconique',
  'E391': 'Acide phytique',
  'E430': 'Stéarate de polyoxyéthylène (8)',
  'E121': 'Rouge citrus no.3',
  'E349': 'Malate d\'ammonium',
  'E1403': 'Amidon blanchi',
  'E446': 'Succistéarine',
  'E541i': 'Phosphate de sodium-aluminium acide',
  'E431': 'Stéarate de polyoxyéthylène (40)',
  'E515i': 'Sulfate de potassium',
  'E106': 'Riboflavine-5-Sodium Phosphate',
  'E919': 'Chlorure de nitrosyle',
  'E337': 'Tartrate double de sodium et de potassium',
  'E311': 'Gallate d\'octyle',
  'E514ii': 'Sulfate acide de sodium',
  'E900a': 'Polydiméthylsiloxane',
  'E578': 'Gluconate de calcium',
  'E333ii': 'Citrate dicalcique',
  'E239': 'Hexaméthylènetétramine',
  'E1503': 'Huile de ricin',
  'E332i': 'Citrate monopotassique',
  'E902': 'Cire de Candelilla',
  'E226': 'Sulfite de calcium',
  'E336ii': 'Tartrate dipotassique',
  'E386': 'EDTA disodique',
  'E172i': 'Oxyde de fer noir',
  'E622': 'Glutamate monopotassique',
  'E432': 'Monolaurate de polyoxyéthylène sorbitane',
  'E352': 'Malate de calcium',
  'E640ii': 'Sodiumglycinate',
  'E504ii': 'Carbonate acide de magnésium',
  'E550': 'Silicate de sodium',
  'E161h': 'Zéaxanthine',
  'E265': 'Acide déhydracétique',
  'E553': 'Silicate de magnésium',
  'E324': 'Ethoxyquine',
  'E913': 'Lanoline',
  'E637': 'Éthyl-maltol',
  'E628': 'Guanylate dipotassique',
  'E459': 'Béta-cyclodextrine',
  'E340iii': 'Phosphate tripotassique',
  'E927a': 'Azoformamide',
  'E515ii': 'Sulfate acide de potassium',
  'E930': 'Peroxyde de Calcium',
  'E546': 'Pyrophosphate de magnésium',
  'E1203': 'Alcool polyvinylique',
  'E351': 'Malate de potassium',
  'E427': 'Gomme de casse',
  'E916': 'Iodate de calcium',
  'E419': 'Gomme ghatti',
  'E125': 'Ponceau SX',
  'E353': 'Acide métatartrique',
  'E343ii': 'Phosphate dimagnésique',
  'E303': 'Diacétate d\'ascorbyle',
  'E513': 'Acide sulfurique',
  'E381': 'Citrate d\'ammonium ferrique vert',
  'E284': 'Acide borique',
  'E452iv': 'Polyphosphate de calcium',
  'E1410': 'Phosphate d\amidon',
  'E181': 'Tannin',
  'E553aii': 'Trisilicate de magnésium',
  'E486': 'Stearoylfumarate de calcium',
  'E465': 'Éthylméthylcellulose',
  'E128': 'Rouge 2G',
  'E518': 'Sulfate de magnésium',
  'E964': 'Sirop de polyglycitol',
  'E1205': 'Copolymère méthacrylate basique',
  'E328': 'Lactate d\'ammonium',
  'E399': 'Lactobionate de calcium',
  'E243': 'Arginate d\'éthyle laurique',
  'E938': 'Argon',
  'E493': 'Monolaurate de sorbitane',
  'E939': 'Hélium',
  'E467': 'Ethyl-hydroxyéthyl-cellulose',
  'E538': 'Ferrocyanure de calcium',
  'E485': 'E485',
  'E238': 'Formiate de calcium',
  'E540': 'Phosphate acide de calcium',
  'E345': 'Citrate de magnésium',
  'E304ii': 'Stéarate d\'ascorbyle',
  'E906': 'Gomme benzoïque',
  'E165': 'Bleu de gardénia',
  'E478': 'Esters lactyles d\'acides gras du glycérol et du propane-1',
  'E496': 'Trioléate de sorbitane',
  'E443': 'Huile végétale bromée',
  'E209': 'Hydroxybenzoate d\'hépthyle',
  'E519': 'Sulfate de cuivre',
  'E365': 'Fumarate de sodium',
  'E309': 'Delta-tocophérol de synthèse',
  'E528': 'Hydroxyde de magnésium',
  'E440b': 'Pectine amidée',
  'E323': 'Anoxomère',
  'E375': 'Acide nicotinique',
  'E164': 'Jaune de gardénia',
  'E558': 'Bentonite',
  'E308': 'Gamma-tocophérol de synthèse',
  'E335i': 'Tartrate monosodique',
  'E160f': 'Ester éthylique de l\'acide -apocaroténique-1',
  'E450vii': 'Diphosphate biacide de calcium',
  'E474': 'Sucroglycérides',
  'E436': 'Tristéarate de polyoxyéthylène sorbitane',
  'E123': 'Amarante',
  'E1000': 'Acide cholique',
  'E1401': 'Amidon traité aux acides',
  'E440a': 'Pectine',
  'E512': 'Chlorure stanneux',
  'E1451': 'Amidon oxydé acétylé',
  'E638': 'Aspartame de sodium',
  'E342': 'Phosphates d\'ammonium',
  'E389': 'Thiodipropionate de dilauryle',
  'E333i': 'Citrate monocalcique',
  'E305': 'Stéarate d\'ascorbyle',
  'E905b': 'Vaseline',
  'E560': 'Silicate de potassium',
  'E214': '4-hydroxybenzoate d\'éthyle',
  'E490': 'Glycole de propylène',
  'E143': 'Vert solide FCF',
  'E380': 'Citrate de triammonium',
  'E458': 'Gamma-Cyclodextrine',
  'E910': 'Esters de cires',
  'E312': 'Gallate dodécyle',
  'E313': 'Gallate d\'éthyle',
  'E1441': 'Glycérine de diamidon hydroxypropylé',
  'E335ii': 'Tartrate disodique',
  'E111': 'Orange GGN',
  'E429': 'Peptones',
  'E354': 'Tartrate de calcium'
};
