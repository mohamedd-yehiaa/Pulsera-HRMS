import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/network/local/cache_helper.dart';

class LocalizationCubit extends Cubit<LocalizationStates> {
  LocalizationCubit() : super(LocalizationInitialState());

  static LocalizationCubit get(context) => BlocProvider.of(context);

  Locale locale = const Locale('en');

  void getSavedLanguage() {
    String? cachedLanguage = CacheHelper.getData(key: 'languageCode');
    if (cachedLanguage != null) {
      locale = Locale(cachedLanguage);
    } else {
      // Default to device locale if available, else English
      try {
        final platformDispatcher = PlatformDispatcher.instance;
        final deviceLocale = platformDispatcher.locale.languageCode;
        if (deviceLocale == 'ar') {
          locale = const Locale('ar');
        } else {
          locale = const Locale('en');
        }
      } catch (e) {
        locale = const Locale('en');
      }
    }
    emit(ChangeLanguageState(locale.languageCode));
  }

  void changeLanguage(String languageCode) {
    if (locale.languageCode == languageCode) return;

    // 1. Update memory and emit the state IMMEDIATELY
    locale = Locale(languageCode);
    emit(ChangeLanguageState(languageCode));

    // 2. Save to cache in the background (Notice: no .then() block)
    CacheHelper.saveData(key: 'languageCode', value: languageCode);
  }
}
