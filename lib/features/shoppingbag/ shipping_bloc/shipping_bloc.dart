

import 'package:aashni_app/features/shoppingbag/%20shipping_bloc/shipping_event.dart';
import 'package:aashni_app/features/shoppingbag/%20shipping_bloc/shipping_state.dart';

import '../model/countries.dart';
import '../repository/shipping_repository.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ShippingBloc extends Bloc<ShippingEvent, ShippingState> {
  ShippingBloc() : super(ShippingInitial()) {
    on<FetchCountries>(_onFetchCountries);
    on<EstimateShipping>(_onEstimateShipping);
  }

  Future<void> _onFetchCountries(FetchCountries event, Emitter<ShippingState> emit) async {
    emit(CountriesLoading());
    try {
      final shippingRepository = ShippingRepository();
      final rawCountries = await shippingRepository.fetchCountries();
      final countries = rawCountries.map((json) => Country.fromJson(json)).toList();
      emit(CountriesLoaded(countries));
    } catch (e) {
      emit(ShippingError("Failed to load countries"));
    }
  }

  Future<void> _onEstimateShipping(EstimateShipping event, Emitter<ShippingState> emit) async {
    emit(ShippingRateLoading());
    try {
      final shippingRepository = ShippingRepository();
      final shippingRate = await shippingRepository.estimateShipping(event.countryId,event.weight);
      emit(ShippingRateLoaded(shippingRate!));
    } catch (e) {
      emit(ShippingError("Failed to estimate shipping"));
    }
  }
}

