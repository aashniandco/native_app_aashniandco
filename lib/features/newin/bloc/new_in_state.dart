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
  final bool hasReachedEnd;

  NewInLoaded({required this.products,this.hasReachedEnd = false});
}

class NewInError extends NewInState {
  final String message;

  NewInError(this.message);
}



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
// import 'package:aashni_app/features/newin/model/new_in_model.dart';
//
// abstract class NewInAccessoriesState {}
//
// class NewInAccessoriesInitial extends NewInAccessoriesState {}
//
// class NewInAccessoriesLoading extends NewInAccessoriesState {}
//
// class NewInAccessoriesLoaded extends NewInAccessoriesState {
//   final List<Product> products;
//
//   NewInAccessoriesLoaded({required this.products});
// }
//
// class NewInAccessoriesError extends NewInAccessoriesState {
//   final String message;
//
//   NewInAccessoriesError(this.message);
// }
