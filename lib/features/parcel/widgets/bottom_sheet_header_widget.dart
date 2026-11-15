import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class BottomSheetHeaderWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onClose;

  const BottomSheetHeaderWidget({super.key, required this.title, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
          child: Text(
            title,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        InkWell(
          onTap: onClose ?? () => Get.back(),
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.close, size: 18, color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ),
      ]),
    );
  }
}
