// //
// // part of 'new_in_bloc.dart';
// //
// //
// // abstract class NewInState extends Equatable {
// //   @override
// //   List<Object> get props => [];
// // }
// //
// // class NewInLoading extends NewInState {}
// //
// // class NewInLoaded extends NewInState {
// //   final List<NewInProduct> designers;
// //   NewInLoaded(this.designers);
// //
// //   @override
// //   List<Object> get props => [designers];
// // }
// //
// // class NewInError extends NewInState {
// //   final String message;
// //   NewInError(this.message);
// //
// //   @override
// //   List<Object> get props => [message];
// // }
//
//
import 'package:aashni_app/features/newin/model/new_in_model.dart';

abstract class NewInState {}

class NewInInitial extends NewInState {}

class NewInLoading extends NewInState {}

class NewInLoaded extends NewInState {
  final List<Product> products;

  NewInLoaded({required this.products});
}

class NewInError extends NewInState {
  final String message;

  NewInError(this.message);
}
