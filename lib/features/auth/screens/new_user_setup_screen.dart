import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_button.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/custom_text_field.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/helper/custom_validator.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/helper/validate_check.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class NewUserSetupScreen extends StatefulWidget {
  final String name;
  final String loginType;
  final String? phone;
  final String? email;
  final bool backFromThis;

  const NewUserSetupScreen({super.key,
    required this.name, required this.loginType, required this.phone, required this.email, required this.backFromThis,
  });

  @override
  State<NewUserSetupScreen> createState() => _NewUserSetupScreenState();
}

class _NewUserSetupScreenState extends State<NewUserSetupScreen> {
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _referCodeFocus = FocusNode();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _referCodeController = TextEditingController();
  String? _countryDialCode;
  GlobalKey<FormState>? _formKeyInfo;

  bool _isPhoneRequired = false;

  @override
  void initState() {
    super.initState();
    _isPhoneRequired = widget.phone == null || widget.phone!.isEmpty || widget.phone == 'null';
    _formKeyInfo = GlobalKey<FormState>();
    _countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
    _nameController.text = widget.name;
    if (widget.email != null && widget.email!.isNotEmpty && widget.email != 'null') {
      _emailController.text = widget.email!;
    }
    if (widget.phone != null && widget.phone!.isNotEmpty && widget.phone != 'null') {
      _phoneController.text = widget.phone!;
    }
  }

  Future<void> _handleCancelAndLogout() async {
    await Get.find<AuthController>().clearSharedData();
    Get.find<AuthController>().socialLogout();
    Get.offAllNamed(RouteHelper.getInitialRoute());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleCancelAndLogout();
      },
      child: Scaffold(
        backgroundColor: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).cardColor,
        appBar: ResponsiveHelper.isDesktop(context) ? null : AppBar(leading: IconButton(
          onPressed: () => _handleCancelAndLogout(),
          icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).textTheme.bodyLarge!.color),
        ), elevation: 0, backgroundColor: Theme.of(context).cardColor),
        body: SafeArea(child: Align(
          alignment: Alignment.center,
          child: Container(
            width: context.width > 700 ? 500 : context.width,
            padding: context.width > 700 ? const EdgeInsets.all(50) : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
            margin: context.width > 700 ? const EdgeInsets.all(50) : EdgeInsets.zero,
            decoration: context.width > 700 ? BoxDecoration(
              color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              boxShadow: ResponsiveHelper.isDesktop(context) ? null : [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, blurRadius: 5, spreadRadius: 1)],
            ) : null,
            child: SingleChildScrollView(
              child: Form(
                key: _formKeyInfo,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                  ResponsiveHelper.isDesktop(context) ? Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => _handleCancelAndLogout(),
                      icon: const Icon(Icons.clear),
                    ),
                  ) : const SizedBox(),

                Image.asset(Images.logo, width: 125),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Text('just_one_step_away'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor), textAlign: TextAlign.center),
                const SizedBox(height: Dimensions.paddingSizeExtremeLarge),

                CustomTextField(
                  titleText: 'ex_jhon'.tr,
                  labelText: 'user_name'.tr,
                  showLabelText: true,
                  required: true,
                  controller: _nameController,
                  focusNode: _nameFocus,
                  nextFocus: _isPhoneRequired ? _phoneFocus : _emailFocus,
                  inputType: TextInputType.name,
                  capitalization: TextCapitalization.words,
                  prefixIcon: CupertinoIcons.person_alt_circle_fill,
                  labelTextSize: Dimensions.fontSizeDefault,
                  validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_your_name".tr),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                _isPhoneRequired ? CustomTextField(
                  titleText: 'xxx-xxx-xxxxx'.tr,
                  labelText: 'phone'.tr,
                  showLabelText: true,
                  required: true,
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  nextFocus: _referCodeFocus,
                  inputType: TextInputType.phone,
                  isPhone: true,
                  onCountryChanged: (CountryCode countryCode) {
                    _countryDialCode = countryCode.dialCode;
                  },
                  countryDialCode: _countryDialCode != null ? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code
                      : Get.find<LocalizationController>().locale.countryCode,
                  validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_phone_number".tr),
                ) : CustomTextField(
                  titleText: 'enter_email'.tr,
                  labelText: 'email'.tr,
                  showLabelText: true,
                  required: false,
                  controller: _emailController,
                  focusNode: _emailFocus,
                  nextFocus: _referCodeFocus,
                  inputType: TextInputType.emailAddress,
                  prefixIcon: CupertinoIcons.mail_solid,
                  validator: (value) => ValidateCheck.validateEmail(value, required: false),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                (Get.find<SplashController>().configModel!.refEarningStatus == 1 ) ? CustomTextField(
                  titleText: 'refer_code'.tr,
                  labelText: 'refer_code'.tr,
                  showLabelText: true,
                  controller: _referCodeController,
                  focusNode: _referCodeFocus,
                  inputAction: TextInputAction.done,
                  inputType: TextInputType.text,
                  capitalization: TextCapitalization.words,
                  prefixImage : Images.referCode,
                  divider: false,
                  prefixSize: 14,
                ) : const SizedBox(),
                SizedBox(height: (Get.find<SplashController>().configModel!.refEarningStatus == 1 ) ? Dimensions.paddingSizeExtraOverLarge : 0),

                GetBuilder<AuthController>(builder: (authController) {
                  return CustomButton(
                    height: ResponsiveHelper.isDesktop(context) ? 50 : null,
                    width:  ResponsiveHelper.isDesktop(context) ? 250 : null,
                    radius: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusSmall : Dimensions.radiusDefault,
                    isBold: !ResponsiveHelper.isDesktop(context),
                    fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeSmall : null,
                    buttonText: 'done'.tr,
                    isLoading: authController.isLoading,
                    onPressed: () async {
                      if(_formKeyInfo!.currentState!.validate()) {
                        if(_isPhoneRequired) {
                          String numberWithCountryCode =  _countryDialCode! + _phoneController.text.trim();
                          PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
                          numberWithCountryCode = phoneValid.phone;
                          if(!phoneValid.isValid) {
                            showCustomSnackBar('invalid_phone_number'.tr);
                          } else {
                            _updatePersonalInfo(authController, numberWithCountryCode);
                          }
                        } else {
                          _updatePersonalInfo(authController, widget.phone ?? '');
                        }
                      }
                    },
                  );
                }),

              ]),
            ),
          ),

        ),
      ))),
    );
  }

  void _updatePersonalInfo(AuthController authController, String numberWithCountryCode) {
    String name = _nameController.text.trim();
    String emailText = _emailController.text.trim();
    String? email = (widget.email != null && widget.email!.isNotEmpty && widget.email != 'null')
        ? widget.email
        : (emailText.isNotEmpty ? emailText : null);
    authController.updatePersonalInfo(
      name: name.isNotEmpty ? name : widget.name,
      phone: _isPhoneRequired ? numberWithCountryCode : (widget.phone != null && widget.phone!.isNotEmpty ? widget.phone : numberWithCountryCode),
      loginType: widget.loginType,
      email: email,
      referCode: _referCodeController.text.trim(),
      alreadyInApp: widget.backFromThis,
    ).then((response) {
      if(response.isSuccess) {
        if(widget.backFromThis && AddressHelper.getUserAddressFromSharedPref() != null) {
          Get.find<LocationController>().syncZoneData();
          Get.back();
        } else {
          Get.find<LocationController>().navigateToLocationScreen('sign-in', offNamed: true);
        }
      } else {
        showCustomSnackBar(response.message);
      }
    });
  }
}
