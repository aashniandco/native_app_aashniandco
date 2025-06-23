abstract class ShippingEvent {}

class FetchCountries extends ShippingEvent {}

class EstimateShipping extends ShippingEvent {
  final String countryId;

  final double weight;

  EstimateShipping(this.countryId,this.weight);
}


class SubmitShippingInfo extends ShippingEvent {
  final String firstName;
  final String lastName;
  final String streetAddress;
  final String city;
  final String zipCode;
  final String phone;
  final String email;
  final String countryId;
  final String regionName;
  final String regionId;
  final String regionCode;
  final String carrierCode;
  final String methodCode;

   SubmitShippingInfo({
    required this.firstName,
    required this.lastName,
    required this.streetAddress,
    required this.city,
    required this.zipCode,
    required this.phone,
    required this.email,
    required this.countryId,
    required this.regionName,
    required this.regionId,
    required this.regionCode,
    required this.carrierCode,
    required this.methodCode,
  });




  @override
  List<Object> get props => [
    firstName, lastName, streetAddress, city, zipCode, phone, email,
    countryId, regionName, regionId, regionCode, carrierCode, methodCode
  ];



}

class SubmitPaymentInfo extends ShippingEvent {
  final String paymentMethodCode;
  final Map<String, dynamic> billingAddress;
  final String paymentMethodNonce;

   SubmitPaymentInfo({
    required this.paymentMethodCode,
    required this.billingAddress,
     required this.paymentMethodNonce,
  });
}

// 🔄 REPLACE EstimateShipping event
class FetchShippingMethods extends ShippingEvent {
  final String countryId;
  final String regionId;
  final String postcode;

  // Add other address fields if you need them
  FetchShippingMethods({required this.countryId, required this.regionId, this.postcode = ""});

}