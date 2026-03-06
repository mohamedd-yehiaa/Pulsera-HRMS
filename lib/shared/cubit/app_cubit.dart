import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/models/company_model.dart';
import 'package:pulsera/models/user_model.dart';
import 'package:pulsera/modules/home_screen.dart';
import 'package:pulsera/modules/leave_screen.dart';
import 'package:pulsera/modules/payroll_screen.dart';
import 'package:pulsera/modules/settings_screen.dart';
import 'package:pulsera/modules/team_members_screen.dart';
import 'package:pulsera/shared/components/constants.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/network/local/cache_helper.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';


class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  UserModel? userModel;

  CompanyModel? companyModel;

  int currentIndex = 0;

  List<Widget> screens = [
    HomeScreen(),
    LeaveScreen(),
    TeamMembersScreen(),
    PayrollScreen(),
    SettingsScreen(),
  ];

  late List<PreferredSizeWidget> appBars = [
    AppBar(
      elevation: 0,
      leadingWidth: 70,

      leading: Padding(
        padding: const EdgeInsetsDirectional.only(start: 15.0),
        child: GestureDetector(
          onTap: () {
            print("Profile");
          },
          child: CircleAvatar(
            backgroundImage: AssetImage("assets/images/avatar.jpg"),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome back $hiEmoji",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "${userModel?.firstName ?? ''} ${userModel?.lastName ?? ''}",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),

      // 3. ACTIONS (Notification)
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 8.0),
          child: IconButton.outlined(
            icon: Icon(IconBroken.Notification),
            onPressed: () {
              print("Notification");
            },
          ),
        ),
      ],
    ),
    AppBar(
      title: const Text("All Leaves", style: TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
      elevation: 0,
    ),
    AppBar(
      title: const Text("All Leaves", style: TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
      elevation: 0,),
    AppBar(
      title: const Text(
        "Payroll History",
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
    ),
    AppBar(
      title: const Text("Settings", style: TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
      elevation: 0,
    ),
  ];
  //----------------------------------------------------------------------------
  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }
  //----------------------------------------------------------------------------
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
          print(error.toString());
          emit(GetUserErrorState(error.toString()));
        });
  }
  //----------------------------------------------------------------------------
  void getCompanyData() {
    String? userCompanyId = userModel?.companyId ?? CacheHelper.getData(key: 'companyId');

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

        print("Successfully linked to: ${companyModel?.organizationName}");
        emit(GetCompanySuccessState());
      } else {
        emit(GetCompanyErrorState("Company document not found in database."));
      }
    })
        .catchError((error) {
      print(error.toString());
      emit(GetCompanyErrorState(error.toString()));
    });
  }
}
