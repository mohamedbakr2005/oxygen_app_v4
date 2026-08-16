import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:Oxygen_Mart/util/images.dart';

class CustomImage extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final bool isNotification;
  final String placeholder;
  final bool isHovered;
  final bool isHighQuality;
  const CustomImage(
      {super.key,
      required this.image,
      this.height,
      this.width,
      this.fit = BoxFit.cover,
      this.isNotification = false,
      this.placeholder = '',
      this.isHovered = false,
      this.isHighQuality = false});

  @override
  Widget build(BuildContext context) {
    final imageWidget = CachedNetworkImage(
      imageUrl: image,
      height: height,
      width: width,
      fit: fit,
      memCacheWidth: isHighQuality ? null : 250, // Optimize RAM footprint for products
      maxWidthDiskCache: isHighQuality ? null : 400, // Limit decoded image size on disk for products
      filterQuality: isHighQuality ? FilterQuality.high : FilterQuality.low, // Optimize decoding speed for products
      fadeInDuration: isHighQuality ? const Duration(milliseconds: 500) : Duration.zero, // Disable fade-in for faster scroll on products
      fadeOutDuration: isHighQuality ? const Duration(milliseconds: 500) : Duration.zero, // Disable fade-out for faster scroll on products
      placeholder: (context, url) => Image.asset(
          placeholder.isNotEmpty
              ? placeholder
              : isNotification
                  ? Images.notificationPlaceholder
                  : Images.placeholder,
          height: height,
          width: width,
          fit: fit),
      errorWidget: (context, url, error) => Image.asset(
          placeholder.isNotEmpty
              ? placeholder
              : isNotification
                  ? Images.notificationPlaceholder
                  : Images.placeholder,
          height: height,
          width: width,
          fit: fit),
    );

    // Skip AnimatedScale on mobile — hover never fires there,
    // so the animation is pure overhead × every product card.
    if (kIsWeb) {
      return AnimatedScale(
        scale: isHovered ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

