import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_ink_well.dart';
import 'package:Oxygen_Mart/features/address/domain/models/address_model.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class AddressWidget extends StatelessWidget {
  final AddressModel? address;
  final bool fromAddress;
  final bool fromCheckout;
  final Function? onRemovePressed;
  final Function? onEditPressed;
  final Function? onTap;
  final bool isSelected;
  final bool fromDashBoard;

  const AddressWidget({
    super.key,
    required this.address,
    required this.fromAddress,
    this.onRemovePressed,
    this.onEditPressed,
    this.onTap,
    this.fromCheckout = false,
    this.isSelected = false,
    this.fromDashBoard = false,
  });

  IconData _getAddressIcon(String? type) {
    final String t = (type ?? 'home').toLowerCase();
    if (t == 'home') {
      return Icons.home_rounded;
    } else if (t == 'office' || t == 'work') {
      return Icons.work_rounded;
    }
    return Icons.location_on_rounded;
  }

  Color _getIconColor(BuildContext context, String? type) {
    final String t = (type ?? 'home').toLowerCase();
    if (t == 'home') {
      return Theme.of(context).primaryColor;
    } else if (t == 'office' || t == 'work') {
      return const Color(0xFF1E88E5);
    }
    return const Color(0xFF8E24AA);
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = _getIconColor(context, address?.addressType);
    final Color iconBgColor = iconColor.withValues(alpha: 0.12);
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: fromCheckout ? 0 : Dimensions.paddingSizeSmall + 2,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor.withValues(alpha: 0.14),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.035),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: CustomInkWell(
          onTap: onTap as void Function()?,
          radius: Dimensions.radiusLarge,
          child: Padding(
            padding: EdgeInsets.all(
              fromCheckout
                  ? Dimensions.paddingSizeSmall
                  : isDesktop
                      ? Dimensions.paddingSizeDefault
                      : Dimensions.paddingSizeDefault - 2,
            ),
            child: Row(
              children: [
                // Modern Rounded Icon Badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    _getAddressIcon(address?.addressType),
                    color: iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                // Address Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              (address?.addressType != null &&
                                      address!.addressType!.isNotEmpty)
                                  ? address!.addressType!.tr
                                  : 'address'.tr,
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault + 0.5,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (address?.house != null && address!.house!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${'house'.tr} ${address!.house}',
                                style: robotoMedium.copyWith(
                                  fontSize: 10,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        address?.address ?? '',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).disabledColor,
                          height: 1.3,
                        ),
                        maxLines: fromCheckout ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (address?.contactPersonNumber != null &&
                          address!.contactPersonNumber!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 13,
                              color: Theme.of(context).disabledColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              address!.contactPersonNumber!,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Edit & Delete Action Buttons (fromAddress screen)
                if (fromAddress) ...[
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  InkWell(
                    onTap: onEditPressed as void Function()?,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.edit_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onRemovePressed as void Function()?,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFE53935),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ] else if (fromCheckout) ...[
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                    color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                    size: 22,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
