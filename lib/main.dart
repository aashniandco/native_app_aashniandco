import 'package:aashni_app/bloc/text_change/state/text_bloc.dart';
import 'package:aashni_app/constants/api_constants.dart';
import 'package:aashni_app/constants/environment.dart';
import 'package:aashni_app/features/designer/bloc/designers_bloc.dart';
import 'package:aashni_app/features/newin/bloc/new_in_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/app.dart';

void main() {

  ApiConstants.setEnvironment(Environment.stage);
  runApp(
    ProviderScope( // ✅ Wrap everything in ProviderScope for Riverpod
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => TextBloc()),
          BlocProvider(create: (context) => DesignersBloc()..add(FetchDesigners())),
          BlocProvider(create: (context) => NewInBloc())
          // BlocProvider(create: (_) => NewInBloc()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}
