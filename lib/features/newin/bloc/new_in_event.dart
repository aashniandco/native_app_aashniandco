part of 'new_in_bloc.dart';
@immutable
abstract class NewInEvent {}

class FetchNewIn extends NewInEvent {
  final int page;

  FetchNewIn({this.page = 0}); // default page = 0
}




