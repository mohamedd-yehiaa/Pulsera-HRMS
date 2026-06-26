import 'package:flutter/material.dart';
import 'package:pulsera/l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pulsera/layout/home_layout.dart';
import 'package:pulsera/modules/kiosk/kiosk_qr_screen.dart';
import 'package:pulsera/modules/login/login_screen.dart';
import 'package:pulsera/shared/bloc_observer.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/cubit/attendance_cubit.dart';
import 'package:pulsera/shared/cubit/auth_cubit.dart';
import 'package:pulsera/shared/cubit/kiosk_cubit.dart';
import 'package:pulsera/shared/cubit/leave_cubit.dart';
import 'package:pulsera/shared/cubit/notification_cubit.dart';
import 'package:pulsera/shared/cubit/payroll_cubit.dart';
import 'package:pulsera/shared/cubit/payroll_config_cubit.dart';
import 'package:pulsera/shared/cubit/team_cubit.dart';
import 'package:pulsera/shared/cubit/profile_cubit.dart';
import 'package:pulsera/shared/cubit/register_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/cubit/localization_cubit.dart';
import 'package:pulsera/shared/network/local/cache_helper.dart';
import 'package:pulsera/shared/network/remote/attendance_repository.dart';
import 'package:pulsera/shared/network/remote/notification_repository.dart';
import 'package:pulsera/shared/network/remote/payroll_repository.dart';
import 'package:pulsera/shared/network/remote/team_repository.dart';
import 'package:pulsera/shared/styles/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pulsera/shared/services/push_notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  Bloc.observer = MyBlocObserver();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await PushNotificationService.initializeLocalNotifications();
  await CacheHelper.init();

  final uId = CacheHelper.getData(key: 'uId');
  final isKiosk = CacheHelper.getData(key: 'isKiosk') ?? false;

  Widget startWidget;

  if (uId != null && isKiosk == true) {
    // Kiosk user → fetch companyId and go directly to QR screen
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uId)
          .get();
      final companyId = doc.data()?['companyId'] ?? '';
      startWidget = KioskQrScreen(companyId: companyId);
    } catch (_) {
      // Fallback to login if Firestore fetch fails
      startWidget = LoginScreen();
    }
  } else if (uId != null) {
    startWidget = HomeLayout();
  } else {
    startWidget = LoginScreen();
  }

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
        BlocProvider(
          create: (context) => NotificationCubit(NotificationRepository()),
        ),

        BlocProvider(create: (context) => PayrollCubit(PayrollRepository())),
        BlocProvider(
          create: (context) => PayrollConfigCubit(PayrollRepository()),
        ),
        BlocProvider(create: (context) => TeamCubit(TeamRepository())),
        BlocProvider(create: (context) => KioskCubit()),
        BlocProvider(
          create: (context) => LocalizationCubit()..getSavedLanguage(),
        ),
      ],
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {},
        builder: (context, state) =>
            BlocBuilder<LocalizationCubit, LocalizationStates>(
              // 1. Force a rebuild specifically when the language state fires
              buildWhen: (previous, current) => current is ChangeLanguageState,
              builder: (context, localeState) {

                // 2. Safely determine the current locale
                Locale currentLocale = LocalizationCubit.get(context).locale;
                if (localeState is ChangeLanguageState) {
                  currentLocale = Locale(localeState.locale);
                }

                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: appTheme,
                  // 3. Pass the caught locale directly to MaterialApp
                  locale: currentLocale,
                  localizationsDelegates: S.localizationsDelegates,
                  supportedLocales: S.supportedLocales,
                  home: startWidget,
                );
              },
            ),
      ),
    );
  }
}