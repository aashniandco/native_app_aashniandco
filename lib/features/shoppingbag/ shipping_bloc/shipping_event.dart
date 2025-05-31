abstract class ShippingEvent {}

class FetchCountries extends ShippingEvent {}

class EstimateShipping extends ShippingEvent {
  final String countryId;
  EstimateShipping(this.countryId);
}
