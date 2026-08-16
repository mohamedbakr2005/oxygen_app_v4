import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/order/controllers/order_controller.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_model.dart';
import 'package:Oxygen_Mart/features/order/screens/order_details_screen.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class RunningOrderViewWidget extends StatelessWidget {
  final List<OrderModel> reversOrder;
  final Function onOrderTap;
  const RunningOrderViewWidget(
      {super.key, required this.reversOrder, required this.onOrderTap});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      if (reversOrder.isEmpty) {
        return const SizedBox();
      }

      return orderController.showOneOrder
          ? _CompactRunningOrderCard(
              order: reversOrder.first,
              extraOrderCount: reversOrder.length - 1,
              onClose: () {
                if (orderController.showBottomSheet) {
                  orderController.showRunningOrders();
                }
              },
              onExpand: reversOrder.length > 1
                  ? () => orderController.showOrders()
                  : null,
            )
          : Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(
                    Dimensions.paddingSizeExtraLarge),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 8, spreadRadius: 1)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(
                          top: Dimensions.paddingSizeDefault),
                      height: 4,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Theme.of(context).highlightColor,
                        borderRadius: BorderRadius.circular(
                            Dimensions.paddingSizeExtraSmall),
                      ),
                    ),
                  ),
                  ListView.separated(
                    itemCount: reversOrder.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      Dimensions.paddingSizeDefault,
                      Dimensions.paddingSizeSmall,
                      Dimensions.paddingSizeDefault,
                      Dimensions.paddingSizeDefault,
                    ),
                    separatorBuilder: (context, index) => const SizedBox(
                        height: Dimensions.paddingSizeSmall),
                    itemBuilder: (context, index) {
                      return _ExpandedRunningOrderTile(
                        order: reversOrder[index],
                        isFirstOrder: index == 0,
                        onTap: () async {
                          await Get.toNamed(
                            RouteHelper.getOrderDetailsRoute(
                                reversOrder[index].id),
                            arguments: OrderDetailsScreen(
                              orderId: reversOrder[index].id,
                              orderModel: reversOrder[index],
                            ),
                          );
                          if (orderController.showBottomSheet) {
                            orderController.showRunningOrders();
                          }
                        },
                        onCollapse: () => orderController.showOrders(),
                        onOrderTap: () => onOrderTap(),
                        extraOrderCount: reversOrder.length - 1,
                      );
                    },
                  ),
                ],
              ),
            );
    });
  }

  Widget trackView(BuildContext context, {required bool status}) {
    return Container(
        height: 5,
        decoration: BoxDecoration(
            color: status
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault)));
  }
}

class _CompactRunningOrderCard extends StatelessWidget {
  final OrderModel order;
  final int extraOrderCount;
  final VoidCallback onClose;
  final VoidCallback? onExpand;

  const _CompactRunningOrderCard({
    required this.order,
    required this.extraOrderCount,
    required this.onClose,
    this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    final int status = _orderProgressStatus(order.orderStatus);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraLarge),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius:
              BorderRadius.circular(Dimensions.paddingSizeExtraLarge),
          onTap: () async {
            await Get.toNamed(
              RouteHelper.getOrderDetailsRoute(order.id),
              arguments: OrderDetailsScreen(orderId: order.id, orderModel: order),
            );
            if (Get.find<OrderController>().showBottomSheet) {
              Get.find<OrderController>().showRunningOrders();
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.paddingSizeDefault,
              Dimensions.paddingSizeDefault,
              Dimensions.paddingSizeDefault,
              Dimensions.paddingSizeSmall,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            _statusAsset(order.orderStatus),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color:
                                    Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                              children: [
                                TextSpan(text: '${'your_order_is'.tr} '),
                                TextSpan(
                                  text: order.orderStatus?.tr ?? '',
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${'order'.tr} #${order.id}',
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (extraOrderCount > 0)
                      InkWell(
                        onTap: onExpand,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            '+$extraOrderCount',
                            style: robotoBold.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        ),
                      ),
                    InkWell(
                      onTap: onClose,
                      borderRadius: BorderRadius.circular(30),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Row(
                  children: List.generate(4, (index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: index == 3
                                ? 0
                                : Dimensions.paddingSizeExtraSmall),
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: status > index
                                ? Theme.of(context).primaryColor
                                : Theme.of(context)
                                    .disabledColor
                                    .withValues(alpha: 0.32),
                            borderRadius: BorderRadius.circular(
                                Dimensions.radiusDefault),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandedRunningOrderTile extends StatelessWidget {
  final OrderModel order;
  final bool isFirstOrder;
  final VoidCallback onTap;
  final VoidCallback onCollapse;
  final VoidCallback onOrderTap;
  final int extraOrderCount;

  const _ExpandedRunningOrderTile({
    required this.order,
    required this.isFirstOrder,
    required this.onTap,
    required this.onCollapse,
    required this.onOrderTap,
    required this.extraOrderCount,
  });

  @override
  Widget build(BuildContext context) {
    final int status = _orderProgressStatus(order.orderStatus);

    return Material(
      color: Theme.of(context).primaryColor.withValues(alpha: isFirstOrder ? 0.05 : 0.03),
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      _statusAsset(order.orderStatus),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        children: [
                          TextSpan(text: '${'your_order_is'.tr} '),
                          TextSpan(
                            text: order.orderStatus?.tr ?? '',
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(
                      '${'order'.tr} #${order.id}',
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Row(
                      children: List.generate(4, (index) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index == 3
                                  ? 0
                                  : Dimensions.paddingSizeExtraSmall,
                            ),
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: status > index
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context)
                                        .disabledColor
                                        .withValues(alpha: 0.32),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              if (isFirstOrder && extraOrderCount > 0)
                InkWell(
                  onTap: onOrderTap,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '+$extraOrderCount',
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Text(
                          'more'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                InkWell(
                  onTap: isFirstOrder ? onCollapse : onTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      isFirstOrder
                          ? Icons.keyboard_arrow_down_rounded
                          : Icons.arrow_forward_rounded,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

int _orderProgressStatus(String? orderStatus) {
  if (orderStatus == AppConstants.pending) {
    return 1;
  } else if (orderStatus == AppConstants.accepted ||
      orderStatus == AppConstants.processing ||
      orderStatus == AppConstants.confirmed) {
    return 2;
  } else if (orderStatus == AppConstants.handover ||
      orderStatus == AppConstants.pickedUp) {
    return 3;
  } else if (orderStatus == AppConstants.delivered) {
    return 4;
  }
  return 0;
}

String _statusAsset(String? orderStatus) {
  if (orderStatus == AppConstants.pending) {
    return Images.packagingInProgressGif;
  } else if (orderStatus == AppConstants.accepted ||
      orderStatus == AppConstants.processing ||
      orderStatus == AppConstants.confirmed) {
    return Images.orderPreparationGif;
  } else if (orderStatus == AppConstants.handover ||
      orderStatus == AppConstants.pickedUp) {
    return Images.groceryPickupDeliveryGif;
  } else if (orderStatus == AppConstants.delivered) {
    return Images.groceryPickupDeliveryGif;
  }
  return Images.packagingInProgressGif;
}
