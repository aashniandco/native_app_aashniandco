import '../model/countries.dart';

abstract class ShippingState {}

class ShippingInitial extends ShippingState {}

class CountriesLoading extends ShippingState {}

class CountriesLoaded extends ShippingState {
  final List<Country> countries;
  CountriesLoaded(this.countries);
}

class ShippingRateLoading extends ShippingState {}

class ShippingRateLoaded extends ShippingState {
  final double shippingPrice;
  ShippingRateLoaded(this.shippingPrice);
}

class ShippingError extends ShippingState {
  final String message;
  ShippingError(this.message);
}
