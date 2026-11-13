import 'package:flutter/material.dart';

/// Converts logical (layout) sizes into the physical-pixel decode targets that
/// `CustomImage.cacheWidth` / `cacheHeight` expect, and that ultimately reach
/// `ResizeImage`.
class ImageCacheHelper {
  ImageCacheHelper._();

  /// Logical pixels -> physical. Returns null when [logical] cannot be used — null,
  /// `double.infinity` from an expanding parent, or <= 0 — so the caller simply
  /// omits the hint rather than crashing on `.round()`.
  static int? pixels(BuildContext context, double? logical) {
    if (logical == null || !logical.isFinite || logical <= 0) {
      return null;
    }
    return (logical * MediaQuery.devicePixelRatioOf(context)).round();
  }

  /// Like [pixels], but falls back to the screen width when [logical] is unusable.
  static int widthPixels(BuildContext context, double? logical) {
    return pixels(context, logical) ?? (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).round();
  }
}
