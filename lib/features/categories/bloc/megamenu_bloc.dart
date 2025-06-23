import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/megamenu_repository.dart';
import 'megamenu_event.dart';
import 'megamenu_state.dart';


class MegamenuBloc extends Bloc<MegamenuEvent, MegamenuState> {
  final MegamenuRepository repository;

  MegamenuBloc(this.repository) : super(MegamenuInitial()) {
    on<LoadMegamenu>((event, emit) async {
      emit(MegamenuLoading());
      try {
        final data = await repository.fetchMegamenu();
        emit(MegamenuLoaded(data.menuNames));
      } catch (e) {
        emit(MegamenuError(e.toString()));
      }
    });
  }
}
