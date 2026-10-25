import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_app_bar.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/footer_view.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/common/widgets/no_data_screen.dart';
import 'package:Oxygen_Mart/common/widgets/not_logged_in_screen.dart';
import 'package:Oxygen_Mart/common/widgets/web_page_title_widget.dart';
import 'package:Oxygen_Mart/features/coupon/controllers/coupon_controller.dart';
import 'package:Oxygen_Mart/features/coupon/widgets/coupon_card_widget.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';

class CouponScreen extends StatefulWidget {
  const CouponScreen({super.key});

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initCall();
  }

  void initCall() {
    if (AuthHelper.isLoggedIn()) {
      Get.find<CouponController>().getCouponList();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: 'coupon'.tr),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: isLoggedIn
          ? GetBuilder<CouponController>(builder: (couponController) {
              return couponController.couponList != null
                  ? couponController.couponList!.isNotEmpty
                      ? RefreshIndicator(
                          onRefresh: () async {
                            await couponController.getCouponList();
                          },
                          child: SingleChildScrollView(
                            controller: scrollController,
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            child: Column(
                              children: [
                                WebScreenTitleWidget(title: 'coupon'.tr),
                                Center(
                                  child: FooterView(
                                    child: Container(
                                      width: Dimensions.webMaxWidth,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeDefault,
                                        vertical: Dimensions.paddingSizeDefault,
                                      ),
                                      child: ResponsiveHelper.isDesktop(context)
                                          ? GridView.builder(
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                mainAxisSpacing: Dimensions.paddingSizeDefault,
                                                crossAxisSpacing: Dimensions.paddingSizeDefault,
                                                childAspectRatio: 2.6,
                                              ),
                                              itemCount: couponController.couponList!.length,
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                return CouponCardWidget(
                                                  coupon: couponController.couponList![index],
                                                  index: index,
                                                );
                                              },
                                            )
                                          : ListView.separated(
                                              itemCount: couponController.couponList!.length,
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              separatorBuilder: (context, index) =>
                                                  const SizedBox(height: Dimensions.paddingSizeDefault),
                                              itemBuilder: (context, index) {
                                                final coupon = couponController.couponList![index];
                                                return InkWell(
                                                  onTap: () {
                                                    Clipboard.setData(
                                                        ClipboardData(text: coupon.code ?? ''));
                                                    showCustomSnackBar(
                                                        'coupon_code_copied'.tr,
                                                        isError: false);
                                                  },
                                                  borderRadius: BorderRadius.circular(
                                                      Dimensions.radiusLarge),
                                                  child: CouponCardWidget(
                                                    coupon: coupon,
                                                    index: index,
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : NoDataScreen(
                          text: 'no_coupon_found'.tr, showFooter: true)
                  : const Center(child: CircularProgressIndicator());
            })
          : NotLoggedInScreen(callBack: (bool value) {
              initCall();
              setState(() {});
            }),
    );
  }
}
