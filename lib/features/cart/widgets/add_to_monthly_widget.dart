import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class MonthlyReorderSection extends StatelessWidget {
  const MonthlyReorderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(builder: (controller) {
      final bool isChecked = controller.monthlySubscribe;
      final Color titleColor =
          Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

      return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeExtraSmall,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isChecked
                ? Theme.of(context).primaryColor.withOpacity(0.35)
                : Theme.of(context).dividerColor.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: isChecked
                  ? Theme.of(context).primaryColor.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: isChecked
                    ? Theme.of(context).primaryColor.withOpacity(0.12)
                    : const Color(0xFFFFA000).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_repeat_rounded,
                size: 20,
                color: isChecked
                    ? Theme.of(context).primaryColor
                    : const Color(0xFFFFA000),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: _MonthlyOrderTitle(
                titleColor: titleColor,
                onInfoTap: () => _showMonthlyPolicySheet(context, controller),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Transform.scale(
              scale: 0.82,
              child: CupertinoSwitch(
                value: isChecked,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (bool value) {
                  controller.toggleMonthlySubscribe();
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _MonthlyOrderTitle extends StatelessWidget {
  final Color titleColor;
  final VoidCallback onInfoTap;

  const _MonthlyOrderTitle({required this.titleColor, required this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = robotoBold.copyWith(
      fontSize: Dimensions.fontSizeDefault,
      color: titleColor,
    );
    return Row(
      children: [
        Flexible(
          child: Text(
            'add_to_monthly_order'.tr,
            style: baseStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        InkWell(
          onTap: onInfoTap,
          customBorder: const CircleBorder(),
          child: Container(
            height: 18,
            width: 18,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.info_outline,
              color: Theme.of(context).primaryColor,
              size: 12,
            ),
          ),
        ),
      ],
    );
  }
}

void _showMonthlyPolicySheet(BuildContext context, CheckoutController controller) {
  final List<String> policyKeys = controller.getMonthlyReorderPolicy();
  Get.bottomSheet(
    Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeLarge,
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeLarge,
        Dimensions.paddingSizeLarge,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 5,
                width: 42,
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.close_rounded,
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ),
            Text(
              'monthly_reorder_policy'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < policyKeys.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == policyKeys.length - 1
                            ? 0
                            : Dimensions.paddingSizeSmall,
                      ),
                      child: _PolicyStep(
                        stepNumber: i + 1,
                        text: policyKeys[i].tr,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Center(
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'got_it'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                    decorationColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
  );
}

class _PolicyStep extends StatelessWidget {
  final int stepNumber;
  final String text;

  const _PolicyStep({required this.stepNumber, required this.text});

  @override
  Widget build(BuildContext context) {
    final Color textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$stepNumber',
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: Text(
            text,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: textColor,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
