import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:pulsera/layout/home_layout.dart';
import 'package:pulsera/modules/login/login_screen.dart';
import 'package:pulsera/shared/bloc_observer.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/apply_leave_cubit.dart';
import 'package:pulsera/shared/cubit/attendance_cubit.dart';
import 'package:pulsera/shared/cubit/auth_cubit.dart';
import 'package:pulsera/shared/cubit/leave_cubit.dart';
import 'package:pulsera/shared/cubit/profile_cubit.dart';
import 'package:pulsera/shared/cubit/register_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/cubit/team_cubit.dart';
import 'package:pulsera/shared/network/local/cache_helper.dart';
import 'package:pulsera/shared/network/remote/attendance_repository.dart';
import 'package:pulsera/shared/network/remote/team_repository.dart';
import 'package:pulsera/shared/styles/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  Bloc.observer = MyBlocObserver();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await CacheHelper.init();
  late var uId = CacheHelper.getData(key: 'uId');

  Widget startWidget = (uId != null) ? HomeLayout() : LoginScreen();
  FlutterNativeSplash.remove();

  runApp(Pulsera(startWidget: startWidget));
}

class Pulsera extends StatelessWidget {
  final Widget startWidget;
  const Pulsera({super.key, required this.startWidget});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => RegisterCubit()),
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(
          create: (context) => AppCubit()
            ..getUserData()
            ..getCompanyData(),
        ),
        BlocProvider(
          create: (context) => AttendanceCubit(AttendanceRepository()),
        ),
        BlocProvider(create: (context) => ProfileCubit()),
        BlocProvider(create: (context) => LeaveCubit()),
        BlocProvider(create: (context) => ApplyLeaveCubit()),
        BlocProvider(create: (context) => TeamCubit(TeamRepository())),

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
