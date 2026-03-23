import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/models/company_model.dart';
import 'package:pulsera/models/user_model.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/network/local/cache_helper.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  UserModel? userModel;

  CompanyModel? companyModel;

  int currentIndex = 0;

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  void getUserData() {
    var uId = CacheHelper.getData(key: 'uId');
    emit(GetUserLoadingState());

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .get()
        .then((value) {
          userModel = UserModel.fromJson(value.data()!);

          if (userModel?.companyId != null) {
            getCompanyData();
          }
          emit(GetUserSuccessState());
        })
        .catchError((error) {
          emit(GetUserErrorState(error.toString()));
        });
  }

  void getCompanyData() {
    String? userCompanyId =
        userModel?.companyId ?? CacheHelper.getData(key: 'companyId');

    if (userCompanyId == null || userCompanyId.isEmpty) {
      emit(GetCompanyErrorState("No company assigned to this user."));
      return;
    }
    emit(GetCompanyLoadingState());

    FirebaseFirestore.instance
        .collection('companies')
        .doc(userCompanyId)
        .get()
        .then((value) {
          if (value.exists && value.data() != null) {
            companyModel = CompanyModel.fromJson(value.data()!);

            emit(GetCompanySuccessState());
          } else {
            emit(
              GetCompanyErrorState("Company document not found in database."),
            );
          }
        })
        .catchError((error) {
          emit(GetCompanyErrorState(error.toString()));
        });
  }
}
