import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simply_calculator/global_variable.dart';

extension AssetsPathExt on String {
  Widget toSvg({
    bool? flipX,
    bool? flipY,
    double? size,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    if (size != null) {
      size = size * (useMobileLayout ? 1 : 1.2);
    }
    final needFlip =
        (contains('arrow') || contains('caret')) &&
            (flipX == null && isArabic) ||
        flipX == true;
    return Transform.flip(
      flipX: needFlip,
      flipY: flipY ?? false,
      child: SvgPicture.asset(
        this,
        width: width ?? size,
        height: height ?? size,
        fit: fit,
        colorFilter:
            color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      ),
    );
  }

  Widget toImage({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
  }) {
    return Image.asset(
      this,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
    );
  }

  ImageProvider toProviderHttpImage() {
    final isHttp = startsWith('http');
    final ImageProvider? httpImage =
        isHttp ? CachedNetworkImageProvider(this) : null;
    return httpImage ?? FileImage(File(this));
  }

  Widget toImageHttpWidget({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
  }) {
    return Image(
      image: toProviderHttpImage(),
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
    );
  }

  ImageProvider toImageProvider() {
    return AssetImage(this);
  }
}
