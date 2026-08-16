import 'package:flutter/material.dart';
import 'package:Oxygen_Mart/helper/product_share_helper.dart';

class ProductShareButton extends StatelessWidget {
  final int? productId;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? iconColor;
  final String tooltip;

  const ProductShareButton({
    super.key,
    required this.productId,
    this.iconSize = 18,
    this.padding = const EdgeInsets.all(6),
    this.backgroundColor,
    this.iconColor,
    this.tooltip = 'Share product',
  });

  @override
  Widget build(BuildContext context) {
    if (productId == null || productId! <= 0) {
      return const SizedBox();
    }

    final Color resolvedBackgroundColor =
        backgroundColor ?? Theme.of(context).cardColor.withOpacity(0.92);
    final Color resolvedIconColor = iconColor ?? Theme.of(context).primaryColor;

    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: () => ProductShareHelper.shareProduct(productId),
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            padding: padding,
            decoration: BoxDecoration(
              color: resolvedBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.share_outlined,
              size: iconSize,
              color: resolvedIconColor,
            ),
          ),
        ),
      ),
    );
  }
}
