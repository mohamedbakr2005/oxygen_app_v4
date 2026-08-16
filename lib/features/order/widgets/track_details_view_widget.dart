import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_model.dart';
import 'package:Oxygen_Mart/features/order/widgets/tracking_stepper_widget.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class TrackDetailsViewWidget extends StatefulWidget {
  final String? status;
  final OrderModel track;
  final Function? callback;
  final bool showChatPermission;
  final double? liveDistanceKm;
  final int? liveEtaMinutes;
  final ScrollController? scrollController;

  const TrackDetailsViewWidget({
    super.key,
    required this.track,
    required this.status,
    this.callback,
    required this.showChatPermission,
    this.liveDistanceKm,
    this.liveEtaMinutes,
    this.scrollController,
  });

  @override
  State<TrackDetailsViewWidget> createState() => _TrackDetailsViewWidgetState();
}

class _TrackDetailsViewWidgetState extends State<TrackDetailsViewWidget> {
  String _statusTitle(String? status) {
    final int state = TrackingStepperWidget.getState(status);
    if (state <= 1) return 'order_accepted'.tr;
    if (state == 2) return 'picking_up_your_order'.tr;
    return 'heading_your_way'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDelivered = widget.status == 'delivered';
    final bool takeAway = widget.track.orderType == 'take_away';
    final bool noDeliveryMan =
        !takeAway && widget.track.deliveryMan == null;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusExtraLarge),
          topRight: Radius.circular(Dimensions.radiusExtraLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Status title + ETA
                Text(
                  _statusTitle(widget.status),
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge),
                ),
                const SizedBox(height: 4),
                widget.track.store?.deliveryTime != null
                    ? RichText(
                        text: TextSpan(
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                          children: [
                            TextSpan(
                                text: '${'estimated_delivery_time'.tr} '),
                            TextSpan(
                              text: widget.track.store!.deliveryTime!,
                              style: robotoBold.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(),

                // ── Live stats row (ETA + distance) ───────────────────
                if (widget.liveDistanceKm != null &&
                    widget.liveEtaMinutes != null &&
                    !isDelivered) ...
                  [
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    _LiveStatsRow(
                      distanceKm: widget.liveDistanceKm!,
                      etaMinutes: widget.liveEtaMinutes!,
                    ),
                  ],

                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Stepper
                TrackingStepperWidget(
                  status: widget.status,
                  takeAway: takeAway,
                ),

                const SizedBox(height: Dimensions.paddingSizeSmall),
                const Divider(),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // Courier / store section
                noDeliveryMan
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeSmall),
                        child: Text(
                          'delivery_man_not_assigned'.tr,
                          style: robotoMedium,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Row(children: [
                        ClipOval(
                          child: CustomImage(
                            image: takeAway
                                ? (widget.track.store?.logoFullUrl ?? '')
                                : (widget.track.deliveryMan!.imageFullUrl ??
                                    ''),
                            height: 48,
                            width: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                takeAway
                                    ? 'store'.tr
                                    : 'courier'.tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                              Text(
                                takeAway
                                    ? (widget.track.store?.name ?? '')
                                    : '${widget.track.deliveryMan!.fName ?? ''} ${widget.track.deliveryMan!.lName ?? ''}',
                                style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeDefault),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Call button
                        _ActionIconButton(
                          icon: Icons.phone_outlined,
                          onTap: () async {
                            final phone = takeAway
                                ? (widget.track.store?.phone ?? '')
                                : (widget.track.deliveryMan!.phone ?? '');
                            if (await canLaunchUrlString('tel:$phone')) {
                              launchUrlString('tel:$phone',
                                  mode: LaunchMode.externalApplication);
                            } else {
                              showCustomSnackBar(
                                  '${'can_not_launch'.tr} $phone');
                            }
                          },
                        ),
                        // Chat button
                        if (widget.showChatPermission) ...[
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          _ActionIconButton(
                            icon: Icons.chat_bubble_outline,
                            onTap: widget.callback as void Function()?,
                          ),
                        ],
                      ]),

                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Bottom action area
                isDelivered
                    ? Column(children: [
                        // Rate button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.toNamed(RouteHelper.getOrderDetailsRoute(
                                  widget.track.id));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeDefault),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusLarge),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'rate_and_review'.tr,
                              style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault),
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        // Close button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () =>
                                Get.offAllNamed(RouteHelper.getInitialRoute()),
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              side: BorderSide(
                                color: Theme.of(context)
                                    .disabledColor
                                  .withValues(alpha: 0.4),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeDefault),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusLarge),
                              ),
                            ),
                            child: Text(
                              'close'.tr,
                              style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault),
                            ),
                          ),
                        ),
                      ])
                    : GestureDetector(
                        onTap: widget.showChatPermission
                            ? widget.callback as void Function()?
                            : null,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeDefault,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .disabledColor
                              .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(
                                Dimensions.radiusExtraLarge),
                          ),
                          child: Text(
                            'send_a_message'.tr,
                            style: robotoRegular.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                        ),
                      ),

                  SizedBox(
                    height:
                        MediaQuery.of(context).padding.bottom + Dimensions.paddingSizeDefault,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        ),
        child: Icon(icon,
            size: 20, color: Theme.of(context).primaryColor),
      ),
    );
  }
}

// ── Live stats row: driver ETA + distance ─────────────────────────────────────
class _LiveStatsRow extends StatelessWidget {
  final double distanceKm;
  final int etaMinutes;

  const _LiveStatsRow({required this.distanceKm, required this.etaMinutes});

  @override
  Widget build(BuildContext context) {
    final distLabel = distanceKm < 1
        ? '${(distanceKm * 1000).round()} ${'m'.tr}'
        : '${distanceKm.toStringAsFixed(1)} ${'km'.tr}';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            Theme.of(context).primaryColor.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      child: Row(children: [
        Expanded(
          child: _StatChip(
            icon: Icons.timer_outlined,
            value: '$etaMinutes ${'min'.tr}',
            label: 'estimated_delivery_time'.tr,
          ),
        ),
        Container(
          width: 1,
          height: 28,
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
        Expanded(
          child: _StatChip(
            icon: Icons.straighten_rounded,
            value: distLabel,
            label: 'distance'.tr,
          ),
        ),
      ]),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatChip(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 16, color: Theme.of(context).primaryColor),
      const SizedBox(width: 6),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            )),
        Text(label,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: Theme.of(context).hintColor,
            )),
      ]),
    ]);
  }
}
