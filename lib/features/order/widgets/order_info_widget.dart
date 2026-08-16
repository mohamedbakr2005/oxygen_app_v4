import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/rating_bar.dart';
import 'package:Oxygen_Mart/features/chat/domain/models/conversation_model.dart';
import 'package:Oxygen_Mart/features/chat/widgets/image_dialog_widget.dart';
import 'package:Oxygen_Mart/features/notification/domain/models/notification_body_model.dart';
import 'package:Oxygen_Mart/features/order/controllers/order_controller.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_model.dart';
import 'package:Oxygen_Mart/features/order/widgets/delivery_details_widget.dart';
import 'package:Oxygen_Mart/features/order/widgets/order_banner_view_widget.dart';
import 'package:Oxygen_Mart/features/order/widgets/order_item_widget.dart';
import 'package:Oxygen_Mart/features/parcel/widgets/details_widget.dart';
import 'package:Oxygen_Mart/features/payment/widgets/offline_info_edit_dialog_widget.dart';
import 'package:Oxygen_Mart/features/review/domain/models/review_model.dart';
import 'package:Oxygen_Mart/features/review/widgets/review_dialog_widget.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/date_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class OrderInfoWidget extends StatelessWidget {
  final OrderModel order;
  final bool ongoing;
  final bool parcel;
  final bool prescriptionOrder;
  final OrderController orderController;
  final Function timerCancel;
  final Function startApiCall;
  final bool showChatPermission;
  const OrderInfoWidget(
      {super.key,
      required this.order,
      required this.ongoing,
      required this.parcel,
      required this.prescriptionOrder,
      required this.orderController,
      required this.timerCancel,
      required this.startApiCall,
      required this.showChatPermission});

  int _statusStep(String? status) {
    if (status == 'accepted' || status == 'confirmed') {
      return 1;
    }
    if (status == 'processing' || status == 'handover') {
      return 2;
    }
    if (status == 'picked_up') {
      return 3;
    }
    if (status == 'delivered') {
      return 4;
    }
    return 0;
  }

  List<_OrderStatusStepData> _statusSteps() {
    return [
      _OrderStatusStepData(
        label: order.orderStatus == 'canceled'
            ? 'canceled'.tr
            : order.orderStatus == 'failed'
                ? 'failed'.tr
                : 'pending'.tr,
        icon: order.orderStatus == 'canceled'
            ? Icons.cancel_outlined
            : order.orderStatus == 'failed'
                ? Icons.error_outline_rounded
                : Icons.timelapse_rounded,
        isCanceled:
            order.orderStatus == 'canceled', // هنا بنحدد هي ملغية ولا لأ
      ),
      _OrderStatusStepData(
        label: 'accepted'.tr,
        icon: Icons.check_circle_outline_rounded,
      ),
      _OrderStatusStepData(
        label: 'processing'.tr,
        icon: Icons.inventory_2_outlined,
      ),
      _OrderStatusStepData(
        label: 'picked_up'.tr,
        icon: Icons.local_shipping_outlined,
      ),
      _OrderStatusStepData(
        label: 'delivered'.tr,
        icon: Icons.home_outlined,
      ),
    ];
  }

  List<_GeneralInfoCardData> _generalInfoCards() {
    return [
      _GeneralInfoCardData(
        title: parcel ? 'charge_pay_by'.tr : 'item'.tr,
        value: parcel
            ? (order.chargePayer?.tr ?? '-')
            : orderController.orderDetails!.length.toString(),
        icon: Icons.shopping_bag_outlined,
        valueDirection: TextDirection.ltr,
      ),
      _GeneralInfoCardData(
        title: 'payment_method'.tr,
        value: _paymentMethodLabel(),
        icon: Icons.payments_outlined,
      ),
      _GeneralInfoCardData(
        title: 'order_date'.tr,
        value: order.createdAt != null
            ? '${DateConverter.dateToReadableDate(DateConverter.dateTimeStringToDate(order.createdAt!))}\n${DateConverter.dateToTimeOnly(DateConverter.dateTimeStringToDate(order.createdAt!))}'
            : '-',
        icon: Icons.calendar_month_outlined,
        valueDirection: TextDirection.ltr,
      ),
      _GeneralInfoCardData(
        title: parcel ? 'delivery_id'.tr : 'order_id'.tr,
        value: '#${order.id ?? ''}',
        icon: Icons.receipt_long_outlined,
        valueDirection: TextDirection.ltr,
      ),
    ];
  }

  String _paymentMethodLabel() {
    switch (order.paymentMethod) {
      case 'cash_on_delivery':
        return 'cash'.tr;
      case 'wallet':
        return 'wallet'.tr;
      case 'partial_payment':
        return 'partial_payment'.tr;
      case 'offline_payment':
        return 'offline_payment'.tr;
      default:
        return order.paymentMethod?.tr ?? '-';
    }
  }

  String _generalInfoTitle() {
    return Get.locale?.languageCode == 'ar'
        ? 'معلومات عن الطلب'
        : 'general_info'.tr;
  }

  List<_GeneralInfoChipData> _optionalInfoChips() {
    final List<_GeneralInfoChipData> chips = [];

    if (order.scheduled == 1 && order.scheduleAt != null) {
      chips.add(_GeneralInfoChipData(
        icon: Icons.schedule_outlined,
        label: 'scheduled_at'.tr,
        value: DateConverter.dateTimeStringToDateTime(order.scheduleAt!),
        valueDirection: TextDirection.ltr,
      ));
    }

    if (Get.find<SplashController>().configModel!.orderDeliveryVerification! &&
        order.otp != null &&
        order.otp!.isNotEmpty) {
      chips.add(_GeneralInfoChipData(
        icon: Icons.verified_outlined,
        label: 'delivery_verification_code'.tr,
        value: order.otp!,
        valueDirection: TextDirection.ltr,
      ));
    }

    return chips;
  }

  @override
  Widget build(BuildContext context) {
    ExpansionTileController controller = ExpansionTileController();
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();
    return Stack(children: [
      !isDesktop
          ? OrderBannerViewWidget(
              order: order,
              orderController: orderController,
              ongoing: ongoing,
              parcel: parcel,
              prescriptionOrder: prescriptionOrder,
            )
          : const SizedBox(),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // isDesktop ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),
          // isDesktop ? Text('general_info'.tr, style: robotoMedium) : const SizedBox(),
          isDesktop
              ? const SizedBox(height: Dimensions.paddingSizeExtraLarge)
              : const SizedBox(),

          !isDesktop
              ? SizedBox(
                  height: DateConverter.isBeforeTime(order.scheduleAt) &&
                          Get.find<SplashController>()
                              .getModuleConfig(order.moduleType)
                              .newVariation!
                      ? (order.orderStatus != 'delivered' &&
                              order.orderStatus != 'failed' &&
                              order.orderStatus != 'canceled' &&
                              order.orderStatus != 'refund_requested' &&
                              order.orderStatus != 'refunded' &&
                              order.orderStatus != 'refund_request_canceled')
                          ? 280
                          : 140
                      : parcel ||
                              prescriptionOrder ||
                              (orderController.orderDetails!.isNotEmpty &&
                                  orderController.orderDetails![0].itemDetails!
                                          .moduleType ==
                                      'grocery') ||
                              (orderController.orderDetails!.isNotEmpty &&
                                  orderController.orderDetails![0].itemDetails!
                                          .moduleType ==
                                      'ecommerce') ||
                              (orderController.orderDetails!.isNotEmpty &&
                                  orderController.orderDetails![0].itemDetails!
                                          .moduleType ==
                                      'pharmacy')
                          ? 140
                          : 0)
              : const SizedBox(),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: ResponsiveHelper.isMobile(context)
                  ? const BorderRadius.vertical(
                      top: Radius.circular(Dimensions.radiusExtraLarge))
                  : BorderRadius.circular(
                      isDesktop ? Dimensions.radiusDefault : 0),
              boxShadow: [
                isDesktop
                    ? const BoxShadow(
                        color: Colors.black12, blurRadius: 5, spreadRadius: 1)
                    : const BoxShadow()
              ],
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
                vertical: Dimensions.paddingSizeLarge),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  isDesktop
                      ? OrderBannerViewWidget(
                          order: order,
                          orderController: orderController,
                          ongoing: ongoing,
                          parcel: parcel,
                          prescriptionOrder: prescriptionOrder,
                        )
                      : const SizedBox(),
                  isDesktop
                      ? const SizedBox(height: Dimensions.paddingSizeSmall)
                      : const SizedBox(),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeSmall),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.82),
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusExtraLarge),
                      border: Border.all(
                        color: Theme.of(context).hintColor.withOpacity(0.10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _OrderStatusOverviewCard(
                          currentStep: _statusStep(order.orderStatus),
                          steps: _statusSteps(),
                        ),
                        const SizedBox(
                            height: Dimensions.paddingSizeExtraLarge),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            _generalInfoTitle(),
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeExtraLarge,
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        LayoutBuilder(builder: (context, constraints) {
                          final List<_GeneralInfoCardData> cards =
                              _generalInfoCards();
                          final int crossAxisCount =
                              constraints.maxWidth < 320 ? 2 : 4;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cards.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: Dimensions.paddingSizeSmall,
                              crossAxisSpacing: Dimensions.paddingSizeSmall,
                              mainAxisExtent: crossAxisCount == 4 ? 148 : 132,
                            ),
                            itemBuilder: (context, index) {
                              return _GeneralInfoCard(data: cards[index]);
                            },
                          );
                        }),
                        _optionalInfoChips().isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    top: Dimensions.paddingSizeDefault),
                                child: Wrap(
                                  spacing: Dimensions.paddingSizeSmall,
                                  runSpacing: Dimensions.paddingSizeSmall,
                                  children: _optionalInfoChips()
                                      .map((chip) =>
                                          _GeneralInfoChip(data: chip))
                                      .toList(),
                                ),
                              )
                            : const SizedBox(),
                        Get.find<SplashController>()
                                .getModuleConfig(order.moduleType)
                                .newVariation!
                            ? Column(children: [
                                Divider(
                                    height: Dimensions.paddingSizeLarge,
                                    color: Theme.of(context)
                                        .disabledColor
                                        .withOpacity(0.30)),
                                Row(children: [
                                  Text('${'cutlery'.tr}: ',
                                      style: robotoRegular),
                                  const Expanded(child: SizedBox()),
                                  Text(
                                    order.cutlery! ? 'yes'.tr : 'no'.tr,
                                    style: robotoRegular,
                                  ),
                                ]),
                              ])
                            : const SizedBox(),
                        order.unavailableItemNote != null
                            ? Column(
                                children: [
                                  Divider(
                                      height: Dimensions.paddingSizeLarge,
                                      color: Theme.of(context)
                                          .disabledColor
                                          .withOpacity(0.30)),
                                  Row(children: [
                                    Text('${'unavailable_item_note'.tr}: ',
                                        style: robotoMedium),
                                    Text(
                                      order.unavailableItemNote!,
                                      style: robotoRegular,
                                    ),
                                  ]),
                                ],
                              )
                            : const SizedBox(),
                        order.deliveryInstruction != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Divider(
                                        height: Dimensions.paddingSizeLarge,
                                        color: Theme.of(context)
                                            .disabledColor
                                            .withOpacity(0.30)),
                                    RichText(
                                      text: TextSpan(
                                          text:
                                              '${'delivery_instruction'.tr}: ',
                                          style: robotoMedium.copyWith(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .color),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text:
                                                    order.deliveryInstruction!,
                                                style: robotoRegular)
                                          ]),
                                    ),
                                  ])
                            : const SizedBox(),
                        SizedBox(
                            height: order.deliveryInstruction != null
                                ? Dimensions.paddingSizeSmall
                                : 0),
                        order.orderStatus == 'canceled'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Divider(
                                        height: Dimensions.paddingSizeLarge,
                                        color: Theme.of(context)
                                            .disabledColor
                                            .withOpacity(0.30)),
                                    Text('${'cancellation_note'.tr}:',
                                        style: robotoMedium),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    InkWell(
                                      onTap: () => Get.dialog(
                                          ReviewDialogWidget(
                                              review: ReviewModel(
                                                  comment:
                                                      order.cancellationReason),
                                              fromOrderDetails: true)),
                                      child: Text(
                                        order.cancellationReason ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: robotoRegular.copyWith(
                                            color: Theme.of(context)
                                                .disabledColor),
                                      ),
                                    ),
                                  ])
                            : const SizedBox(),
                        (order.orderStatus == 'refund_requested' ||
                                order.orderStatus == 'refund_request_canceled')
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Divider(
                                        height: Dimensions.paddingSizeLarge,
                                        color: Theme.of(context)
                                            .disabledColor
                                            .withOpacity(0.30)),
                                    order.orderStatus == 'refund_requested'
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                                RichText(
                                                    text: TextSpan(children: [
                                                  TextSpan(
                                                      text:
                                                          '${'refund_note'.tr}:',
                                                      style:
                                                          robotoMedium.copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .color)),
                                                  TextSpan(
                                                      text:
                                                          '(${(order.refund != null) ? order.refund!.customerReason : ''})',
                                                      style: robotoRegular
                                                          .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .color)),
                                                ])),
                                                const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeSmall),
                                                (order.refund != null &&
                                                        order.refund!
                                                                .customerNote !=
                                                            null)
                                                    ? InkWell(
                                                        onTap: () => Get.dialog(
                                                            ReviewDialogWidget(
                                                                review: ReviewModel(
                                                                    comment: order
                                                                        .refund!
                                                                        .customerNote),
                                                                fromOrderDetails:
                                                                    true)),
                                                        child: Text(
                                                          '${order.refund!.customerNote}',
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: robotoRegular.copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .disabledColor),
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                                SizedBox(
                                                    height: (order.refund !=
                                                                null &&
                                                            order.refund!
                                                                    .imageFullUrl !=
                                                                null)
                                                        ? Dimensions
                                                            .paddingSizeSmall
                                                        : 0),
                                                (order.refund != null &&
                                                        order.refund!
                                                                .imageFullUrl !=
                                                            null &&
                                                        order
                                                            .refund!
                                                            .imageFullUrl!
                                                            .isNotEmpty)
                                                    ? InkWell(
                                                        onTap: () => showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return ImageDialogWidget(
                                                                  imageUrl: order
                                                                          .refund!
                                                                          .imageFullUrl!
                                                                          .isNotEmpty
                                                                      ? order
                                                                          .refund!
                                                                          .imageFullUrl![0]
                                                                      : '');
                                                            }),
                                                        child: CustomImage(
                                                          height: 40,
                                                          width: 40,
                                                          fit: BoxFit.cover,
                                                          image: order.refund !=
                                                                  null
                                                              ? order
                                                                      .refund!
                                                                      .imageFullUrl!
                                                                      .isNotEmpty
                                                                  ? order
                                                                      .refund!
                                                                      .imageFullUrl![0]
                                                                  : ''
                                                              : '',
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                              ])
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                                Text(
                                                    '${'refund_cancellation_note'.tr}:',
                                                    style: robotoMedium),
                                                const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeSmall),
                                                InkWell(
                                                  onTap: () => Get.dialog(
                                                      ReviewDialogWidget(
                                                          review: ReviewModel(
                                                              comment: order
                                                                  .refund!
                                                                  .adminNote),
                                                          fromOrderDetails:
                                                              true)),
                                                  child: Text(
                                                    '${order.refund != null ? order.refund!.adminNote : ''}',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        robotoRegular.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .disabledColor),
                                                  ),
                                                ),
                                              ]),
                                  ])
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ]),
          ),

          isDesktop
              ? const SizedBox()
              : const SizedBox(height: Dimensions.paddingSizeSmall),
          !isDesktop
              ? (parcel || orderController.orderDetails!.isNotEmpty)
                  ? Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                        vertical: Dimensions.paddingSizeExtraSmall,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusExtraLarge),
                        border: Border.all(
                          color: Theme.of(context).hintColor.withOpacity(0.12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeLarge,
                          vertical: Dimensions.paddingSizeDefault),
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
                                  Row(children: [
                                    Container(
                                      width: 4,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(
                                        width: Dimensions.paddingSizeSmall),
                                    Text('item_info'.tr,
                                        style: robotoBold.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeLarge)),
                                  ]),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeDefault),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        orderController.orderDetails!.length,
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context, index) {
                                      return OrderItemWidget(
                                          order: order,
                                          orderDetails: orderController
                                              .orderDetails![index]);
                                    },
                                  ),
                                ]),
                    )
                  : const SizedBox()
              : const SizedBox(),

          (isDesktop &&
                  Get.find<SplashController>()
                      .getModuleConfig(order.moduleType)
                      .orderAttachment! &&
                  order.orderAttachmentFullUrl != null &&
                  order.orderAttachmentFullUrl!.isNotEmpty)
              ? const SizedBox(height: Dimensions.paddingSizeSmall)
              : const SizedBox(),

          (isDesktop &&
                  Get.find<SplashController>()
                      .getModuleConfig(order.moduleType)
                      .orderAttachment! &&
                  order.orderAttachmentFullUrl != null &&
                  order.orderAttachmentFullUrl!.isNotEmpty)
              ? Text('prescription'.tr, style: robotoMedium)
              : const SizedBox(),

          (isDesktop &&
                  Get.find<SplashController>()
                      .getModuleConfig(order.moduleType)
                      .orderAttachment! &&
                  order.orderAttachmentFullUrl != null &&
                  order.orderAttachmentFullUrl!.isNotEmpty)
              ? const SizedBox(height: Dimensions.paddingSizeLarge)
              : const SizedBox(),

          (Get.find<SplashController>()
                      .getModuleConfig(order.moduleType)
                      .orderAttachment! &&
                  order.orderAttachmentFullUrl != null &&
                  order.orderAttachmentFullUrl!.isNotEmpty)
              ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(
                        isDesktop ? Dimensions.radiusDefault : 0),
                    boxShadow: [
                      isDesktop
                          ? const BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              spreadRadius: 1)
                          : const BoxShadow()
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                      vertical: Dimensions.paddingSizeSmall),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        !isDesktop
                            ? Text('prescription'.tr, style: robotoRegular)
                            : const SizedBox(),
                        !isDesktop
                            ? const SizedBox(
                                height: Dimensions.paddingSizeSmall)
                            : const SizedBox(),
                        SizedBox(
                          child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 1,
                                crossAxisCount: isDesktop ? 8 : 3,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 5,
                              ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: order.orderAttachmentFullUrl!.length,
                              itemBuilder: (BuildContext context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: InkWell(
                                    onTap: () => openDialog(context,
                                        '${order.orderAttachmentFullUrl![index]}'),
                                    child: Center(
                                        child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall),
                                      child: CustomImage(
                                        image:
                                            '${order.orderAttachmentFullUrl![index]}',
                                        width: 100,
                                        height: 100,
                                      ),
                                    )),
                                  ),
                                );
                              }),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        SizedBox(
                            width: (Get.find<SplashController>()
                                        .getModuleConfig(order.moduleType)
                                        .orderAttachment! &&
                                    order.orderAttachmentFullUrl != null &&
                                    order.orderAttachmentFullUrl!.isNotEmpty)
                                ? Dimensions.paddingSizeSmall
                                : 0),
                        (order.orderNote != null && order.orderNote!.isNotEmpty)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text('additional_note'.tr,
                                        style: robotoRegular),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    InkWell(
                                      onTap: () => Get.dialog(
                                          ReviewDialogWidget(
                                              review: ReviewModel(
                                                  comment: order.orderNote),
                                              fromOrderDetails: true)),
                                      child: Text(
                                        order.orderNote!,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                        style: robotoRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(context)
                                                .disabledColor),
                                      ),
                                    ),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeLarge),
                                  ])
                            : const SizedBox(),
                      ]),
                )
              : const SizedBox(),
          SizedBox(
              height: Get.find<SplashController>()
                          .getModuleConfig(order.moduleType)
                          .orderAttachment! &&
                      order.orderAttachmentFullUrl != null &&
                      order.orderAttachmentFullUrl!.isNotEmpty
                  ? Dimensions.paddingSizeSmall
                  : 0),

          (order.orderStatus == 'delivered' &&
                  order.orderProofFullUrl != null &&
                  order.orderProofFullUrl!.isNotEmpty)
              ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.05),
                          blurRadius: 10)
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall),
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                      vertical: Dimensions.paddingSizeSmall),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('order_proof'.tr, style: robotoRegular),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 1.5,
                            crossAxisCount:
                                ResponsiveHelper.isTab(context) ? 5 : 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 5,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: order.orderProofFullUrl!.length,
                          itemBuilder: (BuildContext context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () => openDialog(
                                    context, order.orderProofFullUrl![index]),
                                child: Center(
                                    child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                  child: CustomImage(
                                    image: order.orderProofFullUrl![index],
                                    width: 100,
                                    height: 100,
                                  ),
                                )),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                      ]),
                )
              : const SizedBox(),

          (order.deliveryMan != null && isDesktop)
              ? const SizedBox(height: Dimensions.paddingSizeSmall)
              : const SizedBox(),
          (order.deliveryMan != null && isDesktop)
              ? Text('delivery_man_details'.tr, style: robotoMedium)
              : const SizedBox(),
          (order.deliveryMan != null && isDesktop)
              ? const SizedBox(height: Dimensions.paddingSizeLarge)
              : const SizedBox(),
          order.deliveryMan != null
              ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(
                        isDesktop ? Dimensions.radiusDefault : 0),
                    boxShadow: [
                      isDesktop
                          ? const BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              spreadRadius: 1)
                          : const BoxShadow()
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                      vertical: Dimensions.paddingSizeSmall),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('delivery_man_details'.tr, style: robotoMedium),
                        const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall),
                        Row(children: [
                          ClipOval(
                              child: CustomImage(
                            image: '${order.deliveryMan!.imageFullUrl}',
                            height: 35,
                            width: 35,
                            fit: BoxFit.cover,
                          )),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(
                                  '${order.deliveryMan!.fName} ${order.deliveryMan!.lName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall),
                                ),
                                RatingBar(
                                  rating: order.deliveryMan!.avgRating,
                                  size: 10,
                                  ratingCount: order.deliveryMan!.ratingCount,
                                ),
                              ])),
                          (order.orderStatus != 'delivered' &&
                                  order.orderStatus != 'failed' &&
                                  order.orderStatus != 'canceled' &&
                                  order.orderStatus != 'refunded')
                              ? Row(children: [
                                  showChatPermission
                                      ? InkWell(
                                          onTap: () async {
                                            timerCancel();
                                            await Get.toNamed(
                                                RouteHelper.getChatRoute(
                                              notificationBody:
                                                  NotificationBodyModel(
                                                      deliverymanId:
                                                          order.deliveryMan!.id,
                                                      orderId: int.parse(
                                                          order.id.toString())),
                                              user: User(
                                                  id: order.deliveryMan!.id,
                                                  fName:
                                                      order.deliveryMan!.fName,
                                                  lName:
                                                      order.deliveryMan!.lName,
                                                  imageFullUrl: order
                                                      .deliveryMan!
                                                      .imageFullUrl),
                                            ));
                                            startApiCall();
                                          },
                                          child: Image.asset(
                                              Images.chatOrderDetails,
                                              height: 20,
                                              width: 20),
                                        )
                                      : const SizedBox(),
                                  SizedBox(
                                      width: showChatPermission
                                          ? Dimensions.paddingSizeSmall
                                          : 0),
                                  InkWell(
                                    onTap: () async {
                                      if (await canLaunchUrlString(
                                          'tel:${order.deliveryMan!.phone}')) {
                                        launchUrlString(
                                            'tel:${order.deliveryMan!.phone}',
                                            mode:
                                                LaunchMode.externalApplication);
                                      } else {
                                        showCustomSnackBar(
                                            '${'can_not_launch'.tr} ${order.deliveryMan!.phone}');
                                      }
                                    },
                                    child: Image.asset(Images.phoneOrderDetails,
                                        height: 20, width: 20),
                                  ),
                                ])
                              : const SizedBox(),
                        ]),
                      ]),
                )
              : const SizedBox(),
          SizedBox(
              height:
                  order.deliveryMan != null ? Dimensions.paddingSizeLarge : 0),

          isDesktop
              ? const SizedBox(height: Dimensions.paddingSizeSmall)
              : const SizedBox(),
          (parcel && isDesktop)
              ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(
                        isDesktop ? Dimensions.radiusDefault : 0),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12, blurRadius: 5, spreadRadius: 1)
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                      vertical: Dimensions.paddingSizeSmall),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DetailsWidget(
                            title: 'sender_details'.tr,
                            address: order.deliveryAddress),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        DetailsWidget(
                            title: 'receiver_details'.tr,
                            address: order.receiverDetails),
                      ]),
                )
              : const SizedBox(),

          (!parcel && isDesktop)
              ? const SizedBox(height: Dimensions.paddingSizeSmall)
              : const SizedBox(),
          (!parcel && isDesktop)
              ? Text('delivery_details'.tr,
                  style:
                      robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge))
              : const SizedBox(),
          (!parcel && isDesktop)
              ? const SizedBox(height: Dimensions.paddingSizeLarge)
              : const SizedBox(),

          (!parcel && order.store != null)
              ? Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 0 : Dimensions.paddingSizeSmall,
                    vertical: isDesktop ? 0 : Dimensions.paddingSizeExtraSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(
                        isDesktop ? Dimensions.radiusLarge : 24),
                    border: Border.all(
                        color: Theme.of(context).hintColor.withOpacity(0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                      vertical: Dimensions.paddingSizeDefault),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        !isDesktop
                            ? Text('delivery_details'.tr,
                                style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeLarge))
                            : const SizedBox(),
                        !isDesktop
                            ? const SizedBox(
                                height: Dimensions.paddingSizeDefault)
                            : const SizedBox(),
                        const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall),
                        DeliveryDetailsWidget(
                            from: true, address: order.store!.address),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeDefault),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color:
                                Theme.of(context).hintColor.withOpacity(0.18),
                          ),
                        ),
                        DeliveryDetailsWidget(
                            from: false,
                            address: order.deliveryAddress?.address),
                      ]),
                )
              : const SizedBox(),
          SizedBox(height: !parcel ? Dimensions.paddingSizeExtraSmall : 0),

          isDesktop
              ? const SizedBox(height: Dimensions.paddingSizeDefault)
              : const SizedBox(),
          isDesktop
              ? Text(
                  parcel
                      ? 'parcel_category'.tr
                      : Get.find<SplashController>()
                              .getModuleConfig(order.moduleType)
                              .showRestaurantText!
                          ? 'restaurant_details'.tr
                          : 'store_details'.tr,
                  style:
                      robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge))
              : const SizedBox(),
          isDesktop
              ? const SizedBox(height: Dimensions.paddingSizeDefault)
              : const SizedBox(),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: isDesktop ? 0 : Dimensions.paddingSizeSmall,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(
                  isDesktop ? Dimensions.radiusLarge : 24),
              border: Border.all(
                  color: Theme.of(context).hintColor.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
                vertical: Dimensions.paddingSizeDefault),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              !isDesktop
                  ? Text(
                      parcel
                          ? 'parcel_category'.tr
                          : Get.find<SplashController>()
                                  .getModuleConfig(order.moduleType)
                                  .showRestaurantText!
                              ? 'restaurant_details'.tr
                              : 'store_details'.tr,
                      style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge))
                  : const SizedBox(),
              !isDesktop
                  ? const SizedBox(height: Dimensions.paddingSizeDefault)
                  : const SizedBox(),
              (parcel && order.parcelCategory == null)
                  ? Text('no_parcel_category_data_found'.tr,
                      style: robotoMedium)
                  : (!parcel && order.store == null)
                      ? Center(
                          child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeSmall),
                          child: Text('no_restaurant_data_found'.tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall)),
                        ))
                      : Row(children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: CustomImage(
                                image: parcel
                                    ? '${order.parcelCategory!.imageFullUrl}'
                                    : '${order.store!.logoFullUrl}',
                                height: 56,
                                width: 56,
                                fit: BoxFit.cover,
                              )),
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(
                                  parcel
                                      ? order.parcelCategory!.name!
                                      : order.store!.name!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeLarge),
                                ),
                                const SizedBox(
                                    height: Dimensions.paddingSizeExtraSmall),
                                Text(
                                  parcel
                                      ? order.parcelCategory!.description!
                                      : order.store?.address ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Theme.of(context).disabledColor),
                                ),
                              ])),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Wrap(spacing: Dimensions.paddingSizeSmall, children: [
                            (!parcel &&
                                    order.orderType == 'take_away' &&
                                    (order.orderStatus == 'pending' ||
                                        order.orderStatus == 'accepted' ||
                                        order.orderStatus == 'confirmed' ||
                                        order.orderStatus == 'processing' ||
                                        order.orderStatus == 'handover' ||
                                        order.orderStatus == 'picked_up'))
                                ? InkWell(
                                    onTap: () async {
                                      if (!parcel) {
                                        String url =
                                            'https://www.google.com/maps/dir/?api=1&destination=${order.store!.latitude}'
                                            ',${order.store!.longitude}&mode=d';
                                        if (await canLaunchUrlString(url)) {
                                          await launchUrlString(url);
                                        } else {
                                          showCustomSnackBar(
                                              'unable_to_launch_google_map'.tr);
                                        }
                                      }
                                    },
                                    child: Container(
                                      height: 44,
                                      width: 44,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.10),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.navigation_rounded,
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  )
                                : const SizedBox(),
                            (showChatPermission &&
                                    !parcel &&
                                    order.orderStatus != 'delivered' &&
                                    order.orderStatus != 'failed' &&
                                    order.orderStatus != 'canceled' &&
                                    order.orderStatus != 'refunded')
                                ? InkWell(
                                    onTap: () async {
                                      await Get.toNamed(
                                          RouteHelper.getChatRoute(
                                        notificationBody: NotificationBodyModel(
                                            orderId: order.id,
                                            restaurantId:
                                                order.store!.vendorId),
                                        user: User(
                                            id: order.store!.vendorId,
                                            fName: order.store!.name,
                                            lName: '',
                                            imageFullUrl:
                                                order.store!.logoFullUrl),
                                      ));
                                    },
                                    child: Container(
                                      height: 44,
                                      width: 44,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFF1E8),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        color: Color(0xFFFF8A00),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          ]),
                          !isGuestLoggedIn &&
                                  (Get.find<SplashController>()
                                          .configModel!
                                          .refundActiveStatus! &&
                                      order.orderStatus == 'delivered' &&
                                      !parcel &&
                                      (parcel ||
                                          (orderController
                                                  .orderDetails!.isNotEmpty &&
                                              orderController.orderDetails![0]
                                                      .itemCampaignId ==
                                                  null)))
                              ? InkWell(
                                  onTap: () => Get.toNamed(
                                      RouteHelper.getRefundRequestRoute(
                                          order.id.toString())),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 1),
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.paddingSizeExtraSmall,
                                        vertical: Dimensions.paddingSizeSmall),
                                    child: Text('refund_this_order'.tr,
                                        style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(context)
                                                .primaryColor)),
                                  ),
                                )
                              : const SizedBox(),
                        ]),
            ]),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          isDesktop
              ? const SizedBox(height: Dimensions.paddingSizeSmall)
              : const SizedBox(),
          isDesktop
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('payment_method'.tr,
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge)),
                    order.paymentMethod == 'offline_payment'
                        ? Text(
                            orderController.trackModel!.offlinePayment != null
                                ? orderController.trackModel!.offlinePayment!
                                    .data!.status!.tr
                                : '',
                            style: robotoMedium.copyWith(
                                color: Theme.of(context).primaryColor),
                          )
                        : const SizedBox(),
                  ],
                )
              : const SizedBox(),
          isDesktop
              ? const SizedBox(height: Dimensions.paddingSizeLarge)
              : const SizedBox(),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: isDesktop ? 0 : Dimensions.paddingSizeSmall,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(
                  isDesktop ? Dimensions.radiusLarge : 24),
              border: Border.all(
                  color: Theme.of(context).hintColor.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
                vertical: Dimensions.paddingSizeDefault),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              !isDesktop
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          Text('payment_method'.tr,
                              style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge)),
                          order.paymentMethod == 'offline_payment' ||
                                  (order.paymentMethod == 'partial_payment' &&
                                      orderController
                                              .trackModel!.offlinePayment !=
                                          null)
                              ? Text(
                                  orderController.trackModel!.offlinePayment !=
                                          null
                                      ? orderController.trackModel!
                                          .offlinePayment!.data!.status!.tr
                                      : '',
                                  style: robotoMedium.copyWith(
                                      color: (orderController.trackModel!
                                                      .offlinePayment !=
                                                  null
                                              ? orderController
                                                      .trackModel!
                                                      .offlinePayment!
                                                      .data!
                                                      .status
                                                      .toString() ==
                                                  'denied'
                                              : false)
                                          ? Colors.red
                                          : Theme.of(context).primaryColor),
                                )
                              : const SizedBox(),
                        ])
                  : const SizedBox(),
              (!isDesktop && order.paymentMethod != 'offline_payment')
                  ? const SizedBox(height: Dimensions.paddingSizeDefault)
                  : const SizedBox(),
              order.paymentMethod == 'offline_payment' ||
                      (order.paymentMethod == 'partial_payment' &&
                          orderController.trackModel!.offlinePayment != null)
                  ? offlineView(context, orderController, controller, ongoing)
                  : Row(children: [
                      Expanded(
                        child: Text(
                          order.paymentMethod == 'cash_on_delivery'
                              ? 'cash'.tr
                              : order.paymentMethod == 'wallet'
                                  ? 'wallet'.tr
                                  : order.paymentMethod == 'partial_payment'
                                      ? 'partial_payment'.tr
                                      : 'digital'.tr,
                          style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      Container(
                        width: 48,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.8),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Theme.of(context)
                                  .hintColor
                                  .withOpacity(0.14)),
                        ),
                        child: Center(
                          child: Image.asset(
                            order.paymentMethod == 'cash_on_delivery'
                                ? Images.cash
                                : order.paymentMethod == 'wallet'
                                    ? Images.wallet
                                    : order.paymentMethod == 'partial_payment'
                                        ? Images.partialWallet
                                        : Images.digitalPayment,
                            width: 22,
                            height: 22,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                        ),
                      ),
                    ]),
            ]),
          ),
          SizedBox(height: isDesktop ? Dimensions.paddingSizeLarge : 0),
        ],
      ),
    ]);
  }
}

class _OrderStatusStepData {
  final String label;
  final IconData icon;
  final bool isCanceled; // المتغير الجديد

  const _OrderStatusStepData({
    required this.label,
    required this.icon,
    this.isCanceled = false, // القيمة الافتراضية
  });
}

class _GeneralInfoCardData {
  final String title;
  final String value;
  final IconData icon;
  final TextDirection? valueDirection;

  const _GeneralInfoCardData({
    required this.title,
    required this.value,
    required this.icon,
    this.valueDirection,
  });
}

class _GeneralInfoChipData {
  final IconData icon;
  final String label;
  final String value;
  final TextDirection? valueDirection;

  const _GeneralInfoChipData({
    required this.icon,
    required this.label,
    required this.value,
    this.valueDirection,
  });
}

class _OrderStatusOverviewCard extends StatelessWidget {
  final int currentStep;
  final List<_OrderStatusStepData> steps;

  const _OrderStatusOverviewCard({
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color lineColor = Theme.of(context).hintColor.withOpacity(0.20);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Theme.of(context).hintColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: Dimensions.paddingSizeDefault,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int index = 0; index < steps.length; index++) ...[
            Flexible(
              flex: currentStep == index ? 2 : 1,
              child: currentStep == index
                  ? _CurrentStatusStepCard(data: steps[index])
                  : _CompactStatusStep(
                      data: steps[index],
                      isCompleted: index < currentStep,
                    ),
            ),
            if (index != steps.length - 1)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 24),
                  height: 2,
                  decoration: BoxDecoration(
                    color: index < currentStep
                        ? primaryColor.withOpacity(0.30)
                        : lineColor,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _CurrentStatusStepCard extends StatelessWidget {
  final _OrderStatusStepData data;

  const _CurrentStatusStepCard({required this.data});

  @override
  Widget build(BuildContext context) {
    // تحديد الألوان بناءً على حالة الإلغاء
    final Color baseColor =
        data.isCanceled ? Colors.red : Theme.of(context).primaryColor;
    final Color gradientEnd = data.isCanceled
        ? Colors.red.withOpacity(0.82)
        : Theme.of(context).primaryColor.withOpacity(0.82);
    final Color shadowColor = data.isCanceled
        ? Colors.red.withOpacity(0.28)
        : Theme.of(context).primaryColor.withOpacity(0.28);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [baseColor, gradientEnd], // استخدام الألوان الديناميكية
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor, // لون الشادو الديناميكي
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, color: Colors.white, size: 24),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
            data.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: robotoBold.copyWith(
              color: Colors.white,
              fontSize: Dimensions.fontSizeSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactStatusStep extends StatelessWidget {
  final _OrderStatusStepData data;
  final bool isCompleted;

  const _CompactStatusStep({
    required this.data,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color mutedColor = Theme.of(context).hintColor.withOpacity(0.55);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isCompleted
                ? primaryColor.withOpacity(0.12)
                : Theme.of(context).colorScheme.surface.withOpacity(0.75),
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? primaryColor : mutedColor.withOpacity(0.45),
            ),
          ),
          child: Icon(
            isCompleted ? Icons.check_rounded : data.icon,
            color: isCompleted ? primaryColor : mutedColor,
            size: 18,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text(
          data.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall,
            color: isCompleted
                ? Theme.of(context).textTheme.bodyLarge!.color
                : mutedColor,
          ),
        ),
      ],
    );
  }
}

class _GeneralInfoCard extends StatelessWidget {
  final _GeneralInfoCardData data;

  const _GeneralInfoCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).hintColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeExtraSmall,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.72),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(data.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            data.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.value,
            textDirection: data.valueDirection,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneralInfoChip extends StatelessWidget {
  final _GeneralInfoChipData data;

  const _GeneralInfoChip({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(data.icon, size: 16, color: Theme.of(context).primaryColor),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        Text(
          '${data.label}: ',
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          data.value,
          textDirection: data.valueDirection,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
      ]),
    );
  }
}

Widget offlineView(BuildContext context, OrderController orderController,
    ExpansionTileController controller, bool ongoing) {
  return ListTileTheme(
    contentPadding: const EdgeInsets.all(0),
    dense: true,
    horizontalTitleGap: 5.0,
    minLeadingWidth: 0,
    child: Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        controller: controller,
        leading: Image.asset(
          Images.cash,
          width: 20,
          height: 20,
          color: Theme.of(context).textTheme.bodyMedium!.color,
        ),
        title: Text(
          'offline_payment'.tr,
          style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).disabledColor),
        ),
        trailing: Icon(
            !orderController.isExpanded ? Icons.expand_more : Icons.expand_less,
            size: 18),
        tilePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        onExpansionChanged: (value) => orderController.expandedUpdate(value),
        children: [
          const Divider(),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('seller_payment_info'.tr,
                style: robotoMedium.copyWith(
                    color: Theme.of(context).primaryColor)),
            const SizedBox(),
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          orderController.trackModel!.offlinePayment != null
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orderController
                      .trackModel!.offlinePayment!.methodFields!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeExtraSmall),
                      child: Row(children: [
                        Text(
                            '${orderController.trackModel!.offlinePayment!.methodFields![index].inputName.toString().replaceAll('_', ' ')} : ',
                            style: robotoRegular),
                        Text(
                            '${orderController.trackModel!.offlinePayment!.methodFields![index].inputData}',
                            style: robotoRegular),
                      ]),
                    );
                  },
                )
              : Text('no_data_found'.tr),
          const Divider(),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('my_payment_info'.tr,
                style: robotoMedium.copyWith(
                    color: Theme.of(context).primaryColor)),
            (ongoing &&
                    orderController.trackModel!.offlinePayment != null &&
                    orderController.trackModel!.offlinePayment!.data!.status !=
                        'verified')
                ? InkWell(
                    onTap: () {
                      Get.dialog(
                          OfflineInfoEditDialogWidget(
                              offlinePayment:
                                  orderController.trackModel!.offlinePayment!,
                              orderId: orderController.trackModel!.id!),
                          barrierDismissible: true);
                    },
                    child: Text('edit_details'.tr,
                        style: robotoBold.copyWith(
                            color: Theme.of(context).primaryColor)),
                  )
                : const SizedBox(),
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          orderController.trackModel!.offlinePayment != null
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      orderController.trackModel!.offlinePayment!.input!.length,
                  itemBuilder: (context, index) {
                    Input data = orderController
                        .trackModel!.offlinePayment!.input![index];
                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeExtraSmall),
                      child: Row(children: [
                        Text(
                            '${data.userInput.toString().replaceAll('_', ' ')}: ',
                            style: robotoRegular),
                        Text(data.userData.toString(), style: robotoRegular),
                      ]),
                    );
                  },
                )
              : const SizedBox(),
          // const SizedBox(height: Dimensions.paddingSizeSmall),
        ],
      ),
    ),
  );
}

void openDialog(BuildContext context, String imageUrl) => showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
          child: Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              child: PhotoView(
                tightMode: true,
                imageProvider: NetworkImage(imageUrl),
                heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
              ),
            ),
            Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  splashRadius: 5,
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.cancel, color: Colors.red),
                )),
          ]),
        );
      },
    );
