import 'package:flutter/material.dart';
import 'package:pulsera/layout/home_layout.dart';
import 'package:pulsera/shared/bloc_observer.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/attendance_cubit.dart';
import 'package:pulsera/shared/cubit/auth_cubit.dart';
import 'package:pulsera/shared/cubit/profile_cubit.dart';
import 'package:pulsera/shared/cubit/register_cubit.dart';
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
  late var uId = CacheHelper.getData(key: 'uId');
  late Widget widget;


  if(uId != null)
  {
    widget = HomeLayout();
  } else
  {
    widget = SplashScreen();
  }

  runApp(Pulsera(
      startWidget: widget));
}

class Pulsera extends StatelessWidget {
  final Widget startWidget;
  const Pulsera({super.key, required this.startWidget});
  @override
  Widget build(BuildContext context) {
    return
    
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => RegisterCubit()),
          BlocProvider(create: (context) => AuthCubit()),
          BlocProvider(create: (context) => AppCubit()..getUserData()),
          BlocProvider(create: (context) => AttendanceCubit(AttendanceRepository()),),
          BlocProvider(create: (context) => ProfileCubit()),
        ],
          child: BlocConsumer<AppCubit, AppStates>(
          listener: (context, state) {},
          builder: (context, state) => MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: appTheme,
              home: startWidget,
            ),
          ),
      );
  }
}