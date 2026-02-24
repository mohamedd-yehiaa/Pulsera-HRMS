import 'package:flutter/material.dart';
import 'package:pulsera/shared/bloc_observer.dart';
import 'package:pulsera/shared/cubit/attendance_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/network/local/cache_helper.dart';
import 'package:pulsera/shared/network/remote/attendance_repository.dart';
import 'package:pulsera/shared/styles/theme.dart';
import 'modules/splash_screen.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await CacheHelper.init();
  runApp(Pulsera());
}

class Pulsera extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AttendanceCubit(AttendanceRepository()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        home: SplashScreen(),
      ),
    );
  }
}