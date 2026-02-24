import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';
import '../../models/user_model.dart';
import '../../modules/home_screen.dart';
import '../../modules/leave_screen.dart';
import '../../modules/payroll_screen.dart';
import '../../modules/settings_screen.dart';
import '../components/constants.dart';
import '../network/local/cache_helper.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);
  UserModel? userModel;
  int currentIndex = 0;

  List<Widget> screens = [
    HomeScreen(),
    LeaveScreen(),
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
          emit(GetUserSuccessState());
        })
        .catchError((error) {
          print(error.toString());
          emit(GetUserErrorState(error.toString()));
        });
  }
}
