import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/onboard/domain/models/onboarding_model.dart';
import 'package:Oxygen_Mart/features/onboard/domain/service/onboard_service_interface.dart';

class OnBoardingController extends GetxController implements GetxService {
  final OnboardServiceInterface onboardServiceInterface;
  OnBoardingController({required this.onboardServiceInterface});

  List<OnBoardingModel> _onBoardingList = [];
  List<int> showedOnBoardings = [];
  List<Color> _colorList = List.generate(4, (index) => Colors.white);

  List<Color> get colorList => _colorList;
  List<OnBoardingModel> get onBoardingList => _onBoardingList;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void changeSelectIndex(int index) {
    _selectedIndex = index;
    update();
  }

  void updateColor(int index, BuildContext context) {
    if (showedOnBoardings.contains(index)) {
      _colorList[index] = context.theme.primaryColor;
    }
    update();
  }

  void addShowOnBoardings(int index) {
    showedOnBoardings.add(index);
    update();
  }

  void removeShowOnBoardings(int index) {
    showedOnBoardings.remove(index);
    update();
  }

  void getOnBoardingList() async {
    Response response = await onboardServiceInterface.getOnBoardingList();
    if (response.statusCode == 200) {
      _onBoardingList = [];
      _onBoardingList.addAll(response.body);
      _onBoardingList.add(OnBoardingModel('', '', ''));
    }
    update();
  }
}
