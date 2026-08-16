import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_asset_image_widget.dart';
import 'package:Oxygen_Mart/features/order/controllers/order_controller.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_model.dart';
import 'package:Oxygen_Mart/features/order/widgets/order_item_widget.dart';
import 'package:Oxygen_Mart/features/order/widgets/support_reason_bottom_sheet.dart';
import 'package:Oxygen_Mart/features/parcel/widgets/details_widget.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class OrderCalculationWidget extends StatelessWidget {
  final OrderController orderController;
  final OrderModel order;
  final bool ongoing;
  final bool parcel;
  final bool prescriptionOrder;
  final double deliveryCharge;
  final double itemsPrice;
  final double discount;
  final double couponDiscount;
  final double tax;
  final double addOns;
  final double dmTips;
  final bool taxIncluded;
  final double subTotal;
  final double total;
  final Widget bottomView;
  final double extraPackagingAmount;
  final double referrerBonusAmount;
  final Function timerCancel;
  final Function startApiCall;
  const OrderCalculationWidget({
    super.key,
    required this.orderController,
    required this.order,
    required this.ongoing,
    required this.parcel,
    required this.prescriptionOrder,
    required this.deliveryCharge,
    required this.itemsPrice,
    required this.discount,
    required this.couponDiscount,
    required this.tax,
    required this.addOns,
    required this.dmTips,
    required this.taxIncluded,
    required this.subTotal,
    required this.total,
    required this.bottomView,
    required this.extraPackagingAmount,
    required this.referrerBonusAmount,
    required this.timerCancel,
    required this.startApiCall,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final double summaryFontSize =
        isDesktop ? Dimensions.fontSizeSmall : Dimensions.fontSizeDefault;
    final Color cardBorderColor = Theme.of(context).hintColor.withOpacity(0.12);
    final TextStyle summaryLabelStyle = robotoRegular.copyWith(
      fontSize: summaryFontSize,
      color: Theme.of(context).textTheme.bodyMedium!.color?.withOpacity(0.72),
    );
    final TextStyle summaryValueStyle = robotoBold.copyWith(
      fontSize: summaryFontSize,
      color: Theme.of(context).textTheme.bodyLarge!.color,
    );

    return Padding(
      padding: EdgeInsets.only(
          top: isDesktop
              ? Dimensions.paddingSizeExtraLarge
              : Dimensions.paddingSizeSmall),
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: isDesktop ? 0 : Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: isDesktop ? Theme.of(context).cardColor : Colors.transparent,
          borderRadius:
              BorderRadius.circular(isDesktop ? Dimensions.radiusDefault : 0),
          boxShadow: isDesktop
              ? const [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 5, spreadRadius: 1)
                ]
              : [],
        ),
        child: Column(
          children: [
            (ResponsiveHelper.isDesktop(context) &&
                    orderController.orderDetails!.isNotEmpty)
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(Dimensions.radiusDefault)),
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.05),
                            blurRadius: 10)
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                        vertical: Dimensions.paddingSizeSmall),
                    child: parcel
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                                DetailsWidget(
                                    title: 'sender_details'.tr,
                                    address: order.deliveryAddress),
                                const SizedBox(
                                    height: Dimensions.paddingSizeLarge),
                                DetailsWidget(
                                    title: 'receiver_details'.tr,
                                    address: order.receiverDetails),
                              ])
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      orderController.orderDetails!.length,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: Dimensions.paddingSizeSmall),
                                  itemBuilder: (context, index) {
                                    return OrderItemWidget(
                                        order: order,
                                        orderDetails: orderController
                                            .orderDetails![index]);
                                  },
                                ),
                              ]),
                  )
                : const SizedBox(),
            SizedBox(
                height: parcel && orderController.orderDetails!.isNotEmpty
                    ? Dimensions.paddingSizeLarge
                    : 0),
            SizedBox(
                height: (order.orderAttachmentFullUrl != null &&
                        order.orderAttachmentFullUrl!.isNotEmpty)
                    ? Dimensions.paddingSizeLarge
                    : 0),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall,
                ),
                child: Text(
                  'order_summary'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(isDesktop ? 22 : 28),
                  border: Border.all(color: cardBorderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(
                    isDesktop ? Dimensions.paddingSizeLarge : 24),
                child: Column(
                  children: [
                    parcel
                        ? Column(children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('delivery_fee'.tr,
                                      style: summaryLabelStyle),
                                  Text(
                                    '(+) ${order.deliveryCharge}',
                                    style: summaryValueStyle,
                                    textDirection: TextDirection.ltr,
                                  ),
                                ]),
                            const SizedBox(height: 12),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('delivery_man_tips'.tr,
                                      style: summaryLabelStyle),
                                  Text('(+) ${order.dmTips}',
                                      style: summaryValueStyle,
                                      textDirection: TextDirection.ltr),
                                ]),
                            (order.additionalCharge != null &&
                                    order.additionalCharge! > 0)
                                ? const SizedBox(height: 12)
                                : const SizedBox(),
                            (order.additionalCharge != null &&
                                    order.additionalCharge! > 0)
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                        Text(
                                            Get.find<SplashController>()
                                                .configModel!
                                                .additionalChargeName!,
                                            style: summaryLabelStyle),
                                        Text(
                                            '(+) ${PriceConverter.convertPrice(order.additionalCharge)}',
                                            style: summaryValueStyle),
                                      ])
                                : const SizedBox(),
                          ])
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('item_price'.tr,
                                        style: summaryLabelStyle),
                                    Text(
                                        PriceConverter.convertPrice(itemsPrice),
                                        style: summaryValueStyle),
                                  ]),
                              const SizedBox(height: 12),
                              Get.find<SplashController>()
                                      .getModuleConfig(order.moduleType)
                                      .addOn!
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('addons'.tr,
                                            style: summaryLabelStyle),
                                        Text(
                                            '(+) ${PriceConverter.convertPrice(addOns)}',
                                            style: summaryValueStyle),
                                      ],
                                    )
                                  : const SizedBox(),
                              Get.find<SplashController>()
                                      .getModuleConfig(order.moduleType)
                                      .addOn!
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical:
                                              Dimensions.paddingSizeSmall),
                                      child: Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Theme.of(context)
                                            .hintColor
                                            .withOpacity(0.25),
                                      ),
                                    )
                                  : const SizedBox(),
                              Get.find<SplashController>()
                                      .getModuleConfig(order.moduleType)
                                      .addOn!
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            '${'subtotal'.tr} ${taxIncluded ? 'tax_included'.tr : ''}',
                                            style: summaryLabelStyle),
                                        Text(
                                            PriceConverter.convertPrice(
                                                subTotal),
                                            style: summaryValueStyle),
                                      ],
                                    )
                                  : const SizedBox(),
                              SizedBox(
                                  height: Get.find<SplashController>()
                                          .getModuleConfig(order.moduleType)
                                          .addOn!
                                      ? 12
                                      : 0),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('discount'.tr,
                                        style: summaryLabelStyle),
                                    Text(
                                        '(-) ${PriceConverter.convertPrice(discount)}',
                                        style: summaryValueStyle),
                                  ]),
                              const SizedBox(height: 12),
                              couponDiscount > 0
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                          Text('coupon_discount'.tr,
                                              style: summaryLabelStyle),
                                          Text(
                                            '(-) ${PriceConverter.convertPrice(couponDiscount)}',
                                            style: summaryValueStyle,
                                          ),
                                        ])
                                  : const SizedBox(),
                              SizedBox(height: couponDiscount > 0 ? 12 : 0),
                              (referrerBonusAmount > 0)
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('referral_discount'.tr,
                                            style: summaryLabelStyle),
                                        Text(
                                            '(+) ${PriceConverter.convertPrice(referrerBonusAmount)}',
                                            style: summaryValueStyle),
                                      ],
                                    )
                                  : const SizedBox(),
                              SizedBox(
                                  height: referrerBonusAmount > 0 ? 12 : 0),
                              (order.additionalCharge != null &&
                                      order.additionalCharge! > 0)
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                          Text(
                                              Get.find<SplashController>()
                                                  .configModel!
                                                  .additionalChargeName!,
                                              style: summaryLabelStyle),
                                          Text(
                                              '(+) ${PriceConverter.convertPrice(order.additionalCharge)}',
                                              style: summaryValueStyle),
                                        ])
                                  : const SizedBox(),
                              (order.additionalCharge != null &&
                                      order.additionalCharge! > 0)
                                  ? const SizedBox(height: 12)
                                  : const SizedBox(),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '${'vat_tax'.tr} ${taxIncluded ? 'tax_included'.tr : ''} (${order.taxPercentage ?? 0}%)',
                                        style: summaryLabelStyle),
                                    Text(
                                        '(+) ${PriceConverter.convertPrice(tax)}',
                                        style: summaryValueStyle),
                                  ]),
                              const SizedBox(height: 12),
                              (dmTips > 0)
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('delivery_man_tips'.tr,
                                            style: summaryLabelStyle),
                                        Text(
                                            '(+) ${PriceConverter.convertPrice(dmTips)}',
                                            style: summaryValueStyle),
                                      ],
                                    )
                                  : const SizedBox(),
                              SizedBox(height: dmTips > 0 ? 12 : 0),
                              (extraPackagingAmount > 0)
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('extra_packaging'.tr,
                                            style: summaryLabelStyle),
                                        Text(
                                            '(+) ${PriceConverter.convertPrice(extraPackagingAmount)}',
                                            style: summaryValueStyle),
                                      ],
                                    )
                                  : const SizedBox(),
                              SizedBox(
                                  height: extraPackagingAmount > 0 ? 12 : 0),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('delivery_fee'.tr,
                                        style: summaryLabelStyle),
                                    deliveryCharge > 0
                                        ? Text(
                                            '(+) ${PriceConverter.convertPrice(deliveryCharge)}',
                                            style: summaryValueStyle,
                                          )
                                        : Text('free'.tr,
                                            style: summaryValueStyle.copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor)),
                                  ]),
                            ],
                          ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeLarge),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: Theme.of(context).hintColor.withOpacity(0.25),
                      ),
                    ),
                    order.paymentMethod == 'partial_payment'
                        ? Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.05),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: DottedBorder(
                              color: Theme.of(context).primaryColor,
                              strokeWidth: 1,
                              strokeCap: StrokeCap.butt,
                              dashPattern: const [8, 5],
                              padding: const EdgeInsets.all(14),
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(18),
                              child: Column(children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('total_amount'.tr,
                                          style: robotoBold.copyWith(
                                            fontSize: isDesktop
                                                ? Dimensions.fontSizeLarge
                                                : Dimensions.fontSizeOverLarge,
                                            color:
                                                Theme.of(context).primaryColor,
                                          )),
                                      Text(
                                        PriceConverter.convertPrice(total),
                                        style: robotoBold.copyWith(
                                          fontSize: isDesktop
                                              ? Dimensions.fontSizeLarge
                                              : Dimensions.fontSizeOverLarge,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ]),
                                const SizedBox(height: 12),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('paid_by_wallet'.tr,
                                          style: summaryLabelStyle),
                                      Text(
                                        PriceConverter.convertPrice(
                                            order.payments?[0].amount ?? 0),
                                        style: summaryValueStyle,
                                      ),
                                    ]),
                                const SizedBox(height: 12),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${order.payments?[1].paymentStatus == 'paid' ? 'paid_by'.tr : 'due_amount'.tr} (${order.payments?[1].paymentMethod?.tr})',
                                          style: summaryLabelStyle,
                                        ),
                                      ),
                                      const SizedBox(
                                          width: Dimensions.paddingSizeSmall),
                                      Text(
                                        PriceConverter.convertPrice(
                                            order.payments?[1].amount ?? 0),
                                        style: summaryValueStyle,
                                      ),
                                    ]),
                              ]),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('total_amount'.tr,
                                  style: robotoBold.copyWith(
                                    fontSize: isDesktop
                                        ? Dimensions.fontSizeLarge
                                        : Dimensions.fontSizeOverLarge,
                                    color: Theme.of(context).primaryColor,
                                  )),
                              Text(
                                PriceConverter.convertPrice(total),
                                style: robotoBold.copyWith(
                                  fontSize: isDesktop
                                      ? Dimensions.fontSizeLarge
                                      : Dimensions.fontSizeOverLarge,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            AuthHelper.isLoggedIn()
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeLarge,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () async {
                          if (isDesktop) {
                            await Get.dialog(Dialog(
                                child: SupportReasonBottomSheet(
                              orderId: order.id!,
                              timerCancel: timerCancel,
                              startApiCall: startApiCall,
                            )));
                          } else {
                            await Get.bottomSheet(
                              SupportReasonBottomSheet(
                                orderId: order.id!,
                                timerCancel: timerCancel,
                                startApiCall: startApiCall,
                              ),
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                            );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.headset_mic_rounded, size: 24),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Flexible(
                              child: Text(
                                '${'message_to'.tr} ${Get.find<SplashController>().configModel!.businessName}',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: robotoBold.copyWith(
                                  color: Colors.white,
                                  fontSize: isDesktop
                                      ? Dimensions.fontSizeDefault
                                      : Dimensions.fontSizeLarge,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            SizedBox(height: isDesktop ? Dimensions.paddingSizeLarge : 0),
            isDesktop
                ? Padding(
                    padding:
                        const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: bottomView)
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
