abstract class ShippingEvent {}

class FetchCountries extends ShippingEvent {}

class EstimateShipping extends ShippingEvent {
  final String countryId;

  final double weight;

  EstimateShipping(this.countryId,this.weight);
}
