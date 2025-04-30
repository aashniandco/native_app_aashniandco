

abstract class NewInProductsEvent {}

class FetchProductsEvent extends NewInProductsEvent {

}

// Events

class FetchProductsByPostEvent extends NewInProductsEvent {}



class FetchProducts extends NewInProductsEvent {}
// class FetchProductsEvent extends NewInProductsEvent {
//   final List<String>? themes;  // List of themes
//   final String? categoryId;    // Category ID
//
//   FetchProductsEvent({this.themes, this.categoryId});
// }


enum SortOrder { lowToHigh, highToLow }

class SortProductsEvent extends NewInProductsEvent {
  final SortOrder sortOrder;
  SortProductsEvent(this.sortOrder);
}

// class FetchProductsByGenderEvent extends NewInProductsEvent {
//   final String genderName;
//
//   FetchProductsByGenderEvent(this.genderName);
// }

class FetchProductsByGendersEvent extends NewInProductsEvent {
  final List<String> genders;
  FetchProductsByGendersEvent(this.genders);
}

class FetchProductsByThemesEvent extends NewInProductsEvent {
  final List<String> themes;
  FetchProductsByThemesEvent(this.themes);
}

class FetchProductsByColorsEvent extends NewInProductsEvent {
  final List<String> colors;
  FetchProductsByColorsEvent(this.colors);
}

class FetchProductsBySizesEvent extends NewInProductsEvent {
  final List<String> sizes;
  FetchProductsBySizesEvent(this.sizes);
}