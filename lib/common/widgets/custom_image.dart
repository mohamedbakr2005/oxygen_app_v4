import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/images.dart';

class CustomImage extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final bool isNotification;
  final String placeholder;
  final bool isHovered;
  final Color? color;
  final int? cacheWidth;
  final int? cacheHeight;

  const CustomImage({super.key,
    required this.image, this.height, this.width, this.fit = BoxFit.cover, this.isNotification = false,
    this.placeholder = '', this.isHovered = false, this.color, this.cacheWidth, this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    int? effectiveCacheWidth = cacheWidth;
    int? effectiveCacheHeight = cacheHeight;

    if (effectiveCacheWidth == null && width != null && width!.isFinite && width! > 0) {
      effectiveCacheWidth = (width! * 2.5).round().clamp(48, 1200);
    }
    if (effectiveCacheHeight == null && height != null && height!.isFinite && height! > 0) {
      effectiveCacheHeight = (height! * 2.5).round().clamp(48, 1200);
    }

    return AnimatedScale(
      scale: isHovered ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: CachedNetworkImage(
        color: color,
        imageUrl: kIsWeb ? '${AppConstants.baseUrl}/image-proxy?url=$image' : image,
        height: height,
        width: width,
        fit: fit,
        memCacheWidth: effectiveCacheWidth,
        memCacheHeight: effectiveCacheHeight,
        filterQuality: FilterQuality.medium,
        placeholder: (context, url) => Image.asset(
          placeholder.isNotEmpty
              ? placeholder
              : (isNotification ? Images.notificationPlaceholder : Images.placeholder),
          height: height,
          width: width,
          fit: fit,
          color: color,
        ),
        errorWidget: (context, url, error) => Image.asset(
          placeholder.isNotEmpty
              ? placeholder
              : (isNotification ? Images.notificationPlaceholder : Images.placeholder),
          height: height,
          width: width,
          fit: fit,
          color: color,
        ),
      ),
    );
  }
}
