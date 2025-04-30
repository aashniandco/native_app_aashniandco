
import 'package:aashni_app/constants/environment.dart';

class ApiConstants{

  static late Environment currentEnv;

  static void setEnvironment(Environment env){

    currentEnv = env;


  }

  static String  get _baseUrl{

    switch(currentEnv) {

      case Environment.dev:
        return "https://dev.aashniandco.com/rest/V1/solr";

      case Environment.stage:
        return "https://stage.aashniandco.com/rest/V1/solr";

      case Environment.prod:
        return "https://aashniandco.com/rest/V1/solr";
    }
    }

static String url = "https://stage.aashniandco.com/rest/V1/solr/search";



  static String get newIn => "$_baseUrl/newin";
  static String get newInAccessories => "$_baseUrl/new-in-accessories";
  static String get newInProducts => "$_baseUrl/products";
  static String get designers => "$_baseUrl/designers";
  static String get lehengas => "$_baseUrl/lehengas";
  static String get kurtasets => "$_baseUrl/kurtasets";
  static String get tops => "$_baseUrl/tops";
  static String get kaftans => "$_baseUrl/kaftans";
  static String get gowns => "$_baseUrl/gowns";
  static String get pants => "$_baseUrl/pants";
  static String get tunicskurtis => "$_baseUrl/tunicskurtis";
  static String get capes => "$_baseUrl/capes";
  static String get jumpsuits => "$_baseUrl/jumpsuits";
  static String get kurtas => "$_baseUrl/kurtas";
  static String get skirts => "$_baseUrl/skirts";
  static String get palazzosets => "$_baseUrl/palazzosets";
  static String get beach => "$_baseUrl/beach";
  static String get color => "$_baseUrl/color";


  //NewIn-Accessories
  static String get bags => "$_baseUrl/bags";
  static String get shoes => "$_baseUrl/shoes";
  static String get belts => "$_baseUrl/belts";
  static String get masks => "$_baseUrl/masks";


  // NewIn- Men
  // static String get kurtasets => "$_baseUrl/kurtasets";
  static String get sherwanis => "$_baseUrl/sherwanis";
  static String get jackets => "$_baseUrl/jackets";
  static String get menaccessories => "$_baseUrl/menaccessories";
  // static String get kurtas => "$_baseUrl/kurtas";
  static String get shirts => "$_baseUrl/shirts";
  static String get bandis => "$_baseUrl/bandis";
  static String get trousers=> "$_baseUrl/trousers";

  // NewIn- Jewelry
  static String get earrings => "$_baseUrl/earrings";
  static String get bangles => "$_baseUrl/bangles";
  static String get finejewelry => "$_baseUrl/finejewelry";
  static String get handharness => "$_baseUrl/handharness";
  static String get rings => "$_baseUrl/rings";
  static String get footharness => "$_baseUrl/footharness";
  static String get brooches => "$_baseUrl/brooches";
  static String get giftboxes => "$_baseUrl/giftboxes";

// Newin Kidswear
  static String get kurtasetsforboys => "$_baseUrl/kurtasetsforboys";
  static String get shararas => "$_baseUrl/shararas";
  static String get dresses => "$_baseUrl/dresses";
  static String get kidsaccessories => "$_baseUrl/kidsaccessories";
  // static String get shirts => "$_baseUrl/shirts";
  // static String get jackets => "$_baseUrl/jackets";
  static String get coordset=> "$_baseUrl/coordset";
  // static String get gowns => "$_baseUrl/gowns";
  static String get jumpsuit => "$_baseUrl/jumpsuit";
  // static String get sherwanis => "$_baseUrl/sherwanis";
  // static String get pants => "$_baseUrl/pants";
  // static String get bags => "$_baseUrl/bags";
  // static String get tops=> "$_baseUrl/tops";
  // static String get skirts => "$_baseUrl/skirts";
  static String get sarees => "$_baseUrl/sarees";

  //subcategory

  // Newin Theme
  static String get  contemporary => "$_baseUrl/contemporary";
  static String get  ethnic => "$_baseUrl/ethnic";

  // Newin Gender
  static String get  men => "$_baseUrl/men";
  static String get  women => "$_baseUrl/women";
// Newin Color
  static String get  black => "$_baseUrl/black";
  static String get  red => "$_baseUrl/red";
  static String get  blue => "$_baseUrl/blue";
  static String get  green => "$_baseUrl/green";
  static String get  yellow => "$_baseUrl/yellow";
  static String get  white => "$_baseUrl/white";
  static String get  pink => "$_baseUrl/pink";
  static String get  grey => "$_baseUrl/grey";
  // static String get  brown => "$_baseUrl/brown";

// Newin Size

  // static String get  xxsmall => "$_baseUrl/xxsmall";
  // static String get  xsmall => "$_baseUrl/xsmall";
  // static String get  small => "$_baseUrl/small";
  //
  // static String get  medium => "$_baseUrl/medium";
  // static String get  large => "$_baseUrl/large";
  // static String get  xlarge => "$_baseUrl/xlarge";
  // static String get  xxlarge => "$_baseUrl/xxlarge";
  // static String get  3xlarge => "$_baseUrl/3xlarge";
  // static String get  small => "$_baseUrl/small";
  // static String get  small => "$_baseUrl/small";
  // static String get  small => "$_baseUrl/small";
  // static String get  small => "$_baseUrl/small";
  // static String get  small => "$_baseUrl/small";

  // static Map<String, String> get sizes => {
  //
  // };


  static String getApiUrlForProducts(List<String> selectedThemes, String categoryId) {
    // Joining themes to form a comma-separated list
    final themes = selectedThemes.join(',');

    // Constructing the full URL with query parameters
    return '$_baseUrl/products?themes=$themes&categoryId=$categoryId';
  }

  /// ✅ All subcategory endpoints in one place
  // Inside ApiConstants
  static final Map<String, String> subcategoryApiMap = {
    'designers': '$_baseUrl/designers',
    'products': '$_baseUrl/products',
    'lehengas': "$_baseUrl/lehengas",
    'kurtasets':"$_baseUrl/kurtasets",
    'tops':"$_baseUrl/tops",
    'sarees': "$_baseUrl/sarees",
    'kaftans': "$_baseUrl/kaftans",
    'gowns': "$_baseUrl/gowns",
    'pants': "$_baseUrl/pants",
    'capes': "$_baseUrl/capes",
    'jumpsuits': "$_baseUrl/jumpsuits",
    'kurtas': "$_baseUrl/kurtas",
    'skirts': "$_baseUrl/skirts",
    'palazzosets': "$_baseUrl/palazzosets",
    'beach': "$_baseUrl/beach",

    'bags': "$_baseUrl/bags",
    'shoes': "$_baseUrl/shoes",
    'belts': "$_baseUrl/belts",
    'masks': "$_baseUrl/masks",

    'sherwanis': "$_baseUrl/sherwanis",
    'jackets': "$_baseUrl/jackets",
    'menaccessories': "$_baseUrl/menaccessories",

    'shirts': "$_baseUrl/shirts",
    'bandis': "$_baseUrl/bandis",
    'trousers': "$_baseUrl/trousers",



   'earrings': "$_baseUrl/earrings",
   'bangles': "$_baseUrl/bangles",
   'finejewelry': "$_baseUrl/finejewelry",
   'handharness': "$_baseUrl/handharness",
   'rings': "$_baseUrl/rings",
   'footharness': "$_baseUrl/footharness",
   'brooches': "$_baseUrl/brooches",
   'giftboxes': "$_baseUrl/giftboxes",


    'kurtasetsforboys': "$_baseUrl/kurtasetsforboys",
    'shararas': "$_baseUrl/shararas",
    'dresses': "$_baseUrl/dresses",
    'kidsaccessories ': "$_baseUrl/kidsaccessories ",
    'coordset': "$_baseUrl/coordset",
    'jumpsuit': "$_baseUrl/jumpsuit",
    'sarees': "$_baseUrl/sarees",


    'contemporary': "$_baseUrl/contemporary",
    'ethnic': "$_baseUrl/ethnic",

    'men': "$_baseUrl/men",
    'women': "$_baseUrl/women",
    'color': "$_baseUrl/color",

    'black': "$_baseUrl/black",
    'red': "$_baseUrl/red",
    'blue': "$_baseUrl/blue",
    'green': "$_baseUrl/green",
    'yellow': "$_baseUrl/yellow",
    'white': "$_baseUrl/white",
    'pink': "$_baseUrl/pink",
    'grey': "$_baseUrl/grey",
    'brown': "$_baseUrl/brown",


    'xlarge': '$_baseUrl/xlarge',
    'xxlarge': '$_baseUrl/xxlarge',
    '3xlarge': '$_baseUrl/3xlarge',
    '4xlarge': '$_baseUrl/4xlarge',
    '5xlarge': '$_baseUrl/5xlarge',
    '6xlarge': '$_baseUrl/6xlarge',
    'custommade': '$_baseUrl/custommade',
    'freesize': '$_baseUrl/freesize',
    'eurosize32': '$_baseUrl/eurosize32',
    'eurosize33': '$_baseUrl/eurosize33',
    'eurosize34': '$_baseUrl/eurosize34',
    'eurosize35': '$_baseUrl/eurosize35',
    'eurosize36': '$_baseUrl/eurosize36',
    'eurosize37': '$_baseUrl/eurosize37',
    'eurosize38': '$_baseUrl/eurosize38',
    'eurosize39': '$_baseUrl/eurosize39',
    'eurosize40': '$_baseUrl/eurosize40',
    'eurosize41': '$_baseUrl/eurosize41',
    'eurosize42': '$_baseUrl/eurosize42',
    'eurosize43': '$_baseUrl/eurosize43',
    'eurosize44': '$_baseUrl/eurosize44',
    'eurosize45': '$_baseUrl/eurosize45',
    'eurosize46': '$_baseUrl/eurosize46',
    'eurosize47': '$_baseUrl/eurosize47',
    'eurosize48': '$_baseUrl/eurosize48',
    'eurosize49': '$_baseUrl/eurosize49',
    'banglesize22': '$_baseUrl/banglesize22',
    'banglesize24': '$_baseUrl/banglesize24',
    'banglesize26': '$_baseUrl/banglesize26',
    'banglesize28': '$_baseUrl/banglesize28',
    '6_12months': '$_baseUrl/6_12months',
    '1_2years': '$_baseUrl/1_2years',
    '2_3years': '$_baseUrl/2_3years',
    '3_4years': '$_baseUrl/3_4years',
    '4_5years': '$_baseUrl/4_5years',
    '5_6years': '$_baseUrl/5_6years',
    '6_7years': '$_baseUrl/6_7years',
    '7_8years': '$_baseUrl/7_8years',
    '8_9years': '$_baseUrl/8_9years',
    '9_10years': '$_baseUrl/9_10years',
    '10_11years': '$_baseUrl/10_11years',
    '11_12years': '$_baseUrl/11_12years',
    '12_13years': '$_baseUrl/12_13years',
    '13_14years': '$_baseUrl/13_14years',
    '14_15years': '$_baseUrl/14_15years',
    '15_16years': '$_baseUrl/15_16years',

    'immediate': '$_baseUrl/immediate',
    '1_2weeks': '$_baseUrl/1_2weeks',
    '2_4weeks': '$_baseUrl/2_4weeks',
    '4_6weeks': '$_baseUrl/4_6weeks',
    '6_8weeks': '$_baseUrl/6_8weeks',
    '8weeks': '$_baseUrl/8weeks',
    'contemporary': '$_baseUrl/contemporary',
    'new in accessories': "$_baseUrl/new-in-accessories",
    'search': "$_baseUrl/search",

    // add more here
  };

  // static String? getApiKeyForSubcategory(String subcategoryName) {
  //   return subcategoryApiMap.entries.firstWhere(
  //         (entry) => entry.key.toLowerCase().trim() == subcategoryName.toLowerCase().trim(),
  //     orElse: () => const MapEntry('', ''),
  //   ).key;
  // }

  static String? getApiKeyForSubcategory(String subcategory) {
    return subcategoryApiMap[subcategory.toLowerCase()];
  }


  ///  Get URL for a given subcategory name
  // static String getApiUrlForSubcategory(String subcategoryName) {
  //   return subcategoryApiMap[subcategoryName.toLowerCase()] ??
  //       "$_baseUrl/newin "; // fallback
  // }

  // important message

  // static dynamic getApiUrlForSubcategory(String subcategoryName) {
  //   // Split the input into multiple subcategories
  //   List<String> subcategoryNames = subcategoryName
  //       .toLowerCase()
  //       .split(',')
  //       .map((s) => s.trim())
  //       .where((s) => s.isNotEmpty)
  //       .toList();
  //
  //   // If only one subcategory is selected, return a single URL
  //   if (subcategoryNames.length == 1) {
  //     return subcategoryApiMap[subcategoryNames.first] ?? "$_baseUrl/newin"; // Fallback URL
  //   }
  //
  //   // Otherwise, return a list of URLs for multiple subcategories
  //   return subcategoryNames
  //       .map((subcategory) => subcategoryApiMap[subcategory] ?? "$_baseUrl/newin") // Fallback URL
  //       .toList();
  // }

  static dynamic getApiUrlForSubcategory(String subcategoryName) {
    // If the input is a full URL, extract the subcategory name
    Uri uri = Uri.parse(subcategoryName);
    String path = uri.pathSegments.last.toLowerCase();  // Extract the last path segment as subcategory

    // Debug: Check the extracted subcategory
    print("Extracted Subcategory: $path");

    // Now check if the subcategory name exists in subcategoryApiMap
    if (subcategoryApiMap.containsKey(path)) {
      print("API URL found for $path: ${subcategoryApiMap[path]}");
      return subcategoryApiMap[path];
    } else {
      print("No API URL found in map for $path, returning fallback URL.");
      return "$_baseUrl/newin"; // Fallback URL
    }
  }





  ///  Add this method at the end
  static bool isSubcategory(String subcategory, String keyToCheck) {
    return subcategory.trim().toLowerCase() == keyToCheck.trim().toLowerCase();
  }

  static String getColorFilterUrl(String colorName) {
    final encodedColor = Uri.encodeComponent(colorName.trim());
    return "$_baseUrl/color?colorName=$encodedColor";
  }

  // static String getNewInByColor(String color) {
  //   final cleanColor = color.trim().toLowerCase().replaceAll(' ', '%20');
  //   return "$_baseUrl/newin?fq=attributes_color:$cleanColor";
  // }

}