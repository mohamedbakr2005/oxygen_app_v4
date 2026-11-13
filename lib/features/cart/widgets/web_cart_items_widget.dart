import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/web_constrained_box.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/cart/domain/models/cart_model.dart';
import 'package:Oxygen_Mart/features/cart/widgets/cart_item_widget.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/features/store/screens/store_screen.dart';
import 'package:Oxygen_Mart/features/cart/widgets/add_to_monthly_widget.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class WebCardItemsWidget extends StatelessWidget {
  final List<CartModel> cartList;
  const WebCardItemsWidget({super.key, required this.cartList});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      return Expanded(
        flex: 6,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
                Radius.circular(Dimensions.radiusDefault)),
            color: Theme.of(context).cardColor,
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)
            ],
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Product
            WebConstrainedBox(
              dataLength: cartList.length,
              minLength: 5,
              minHeight: 0.6,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: cartList.length,
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      itemBuilder: (context, index) {
                        return CartItemWidget(
                            cart: cartList[index],
                            cartIndex: index,
                            addOns: cartController.addOnsList[index],
                            isAvailable: cartController.availableList[index]);
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                    ),
                    const Divider(thickness: 0.5, height: 5),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: Dimensions.paddingSizeExtraSmall),
                      child: TextButton.icon(
                        onPressed: () {
                          final int? targetModuleId = cartController.cartList[0].item?.moduleId ?? cartController.cartModuleId;
                          final int? targetStoreId = cartController.cartList[0].item?.storeId ?? cartController.cartStoreId;
                          if (targetModuleId != null) {
                            cartController.forcefullySetModule(targetModuleId);
                          }
                          if (targetStoreId != null) {
                            Get.toNamed(
                              RouteHelper.getStoreRoute(
                                  id: targetStoreId,
                                  page: 'item'),
                              arguments: StoreScreen(
                                  store: Store(id: targetStoreId),
                                  fromModule: false),
                            );
                          }
                        },
                        icon: Icon(Icons.add_circle_outline_sharp,
                            color: Theme.of(context).primaryColor),
                        label: Text('add_more_items'.tr,
                            style: robotoMedium.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontSize: Dimensions.fontSizeDefault)),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    if (cartController.cartList.isNotEmpty &&
                        (cartController.cartList[0].item?.moduleType == 'grocery' ||
                            cartController.cartList[0].item?.moduleType == 'pharmacy' ||
                            Get.find<SplashController>().module?.moduleType == 'grocery' ||
                            Get.find<SplashController>().module?.moduleType == 'pharmacy') &&
                        !cartController.cartList.any((cart) => (cart.isCampaign ?? false) || (cart.item?.flashSale ?? 0) > 0) &&
                        AuthHelper.isLoggedIn() &&
                        Get.find<SplashController>().configModel?.monthlyOrderRemainder == 1) ...[
                      const MonthlyReorderSection(),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                    ],
                  ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ]),
        ),
      );
    });
  }
}
