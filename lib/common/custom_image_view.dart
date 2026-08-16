// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/util/images.dart';

class CustomImageView extends StatelessWidget {
  ///[url] is required parameter for fetching network image
  String? url;

  ///[imagePath] is required parameter for showing png,jpg,etc image
  String? imagePath;

  ///[svgPath] is required parameter for showing svg image
  String? svgPath;

  ///[file] is required parameter for fetching image file
  File? file;

  double? height;
  double? width;
  Color? color;
  BoxFit? fit;
  BuildContext context;
  Alignment? alignment;
  VoidCallback? onTap;
  EdgeInsetsGeometry? margin;
  BorderRadius? radius;
  BoxBorder? border;

  ///a [CustomImageView] it can be used for showing any type of images
  /// it will shows the placeholder image if image is not found on network image
  CustomImageView(
      {super.key,
      this.url,
      this.imagePath,
      this.svgPath,
      this.file,
      this.height,
      this.width,
      this.color,
      this.fit,
      this.alignment,
      this.onTap,
      this.radius,
      this.margin,
      this.border,
      required this.context});

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment!,
            child: _buildWidget(context),
          )
        : _buildWidget(context);
  }

  Widget _buildWidget(context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: _buildCircleImage(),
      ),
    );
  }

  ///build the image with border radius
  _buildCircleImage() {
    if (radius != null) {
      return ClipRRect(
        borderRadius: radius!,
        child: _buildImageWithBorder(),
      );
    } else {
      return _buildImageWithBorder();
    }
  }

  ///build the image with border and border radius style
  _buildImageWithBorder() {
    if (border != null) {
      return Container(
        decoration: BoxDecoration(
          border: border,
          borderRadius: radius,
        ),
        child: _buildImageView(),
      );
    } else {
      return _buildImageView();
    }
  }

  Widget _buildePlaceHolder() {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFFEEEEEE),
      ),
      child: Center(
        child: SizedBox(
          width: context.width * 0.3,
          height: context.height * 0.3,
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).primaryColor.withAlpha(55),
            // value: .1,

            strokeCap: StrokeCap.round,
          ),
        ),
      ),
    );
  }

  Widget _buildImageView() {
    if (svgPath != null && svgPath!.isNotEmpty) {
      return SizedBox(
        height: height,
        width: width,
        child: SvgPicture.asset(
          svgPath!,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
          colorFilter:
              color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
        ),
      );
    } else if (file != null && file!.path.isNotEmpty) {
      return Image.file(
        file!,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        color: color,
      );
    } else if (url != null && url!.isNotEmpty) {
      if (url!.toLowerCase().endsWith(".svg")) {
        // If the URL contains '.svg', load it as an SVG
        return SvgPicture.network(
          url!,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
          colorFilter:
              color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
          placeholderBuilder: (context) => _buildePlaceHolder(),
        );
      } else {
        // Otherwise, load it as a normal image
        return CachedNetworkImage(
          height: height,
          width: width,
          fit: fit,
          imageUrl: url!,
          color: color,
          placeholder: (context, url) => _buildePlaceHolder(),
          errorWidget: (context, url, error) => SizedBox(
            height: height,
            width: width,
            child: Image.asset(
              Images.placeHolder,
              fit: BoxFit.fill,
              height: height,
              width: width,
            ),
          ),
        );
      }
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      return Image.asset(
        imagePath!,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        color: color,
      );
    }
    return const SizedBox();
  }
}
