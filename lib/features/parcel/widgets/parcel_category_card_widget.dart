import 'package:flutter/material.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/custom_ink_well.dart';
import 'package:Oxygen_Mart/helper/image_cache_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class ParcelCategoryCardWidget extends StatelessWidget {
  final String image;
  final String itemName;
  final String description;
  final int colorIndex;
  final Function? onTap;

  const ParcelCategoryCardWidget({super.key, required this.image, required this.itemName, required this.description, required this.colorIndex, this.onTap});

  static const List<Color> _categoryColors = [
    Color(0xFFF3F7FF),
    Color(0xFFF0FDF4),
    Color(0xFFFFFBEB),
    Color(0xFFFEF2F2),
    Color(0xFFF5F3FF),
    Color(0xFFECFEFF),
  ];

  static const Color _extraColor = Color(0xFFF8FAFC);

  static Color _backgroundFor(int index) {
    if (index < _categoryColors.length) {
      return _categoryColors[index];
    }
    return _extraColor;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? Theme.of(context).cardColor : _backgroundFor(colorIndex);
    final Color borderColor = isDark
        ? Theme.of(context).disabledColor.withValues(alpha: 0.2)
        : Theme.of(context).primaryColor.withValues(alpha: 0.08);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CustomInkWell(
        onTap: onTap,
        radius: Dimensions.radiusLarge,
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              child: CustomImage(
                image: image,
                width: 46,
                height: 46,
                cacheWidth: ImageCacheHelper.pixels(context, 46),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
