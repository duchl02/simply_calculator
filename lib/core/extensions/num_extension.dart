import 'package:flutter/material.dart';

extension PaddingExtension on num {
  /// EdgeInsets.all(this)
  EdgeInsets get p => EdgeInsets.all(toDouble());

  /// EdgeInsets.symmetric(horizontal: this)
  EdgeInsets get ph => EdgeInsets.symmetric(horizontal: toDouble());

  /// EdgeInsets.symmetric(vertical: this)
  EdgeInsets get pv => EdgeInsets.symmetric(vertical: toDouble());

  /// EdgeInsets.only(top: this)
  EdgeInsets get pt => EdgeInsets.only(top: toDouble());

  /// EdgeInsets.only(bottom: this)
  EdgeInsets get pb => EdgeInsets.only(bottom: toDouble());

  /// EdgeInsets.only(left: this)
  EdgeInsets get pl => EdgeInsets.only(left: toDouble());

  /// EdgeInsets.only(right: this)
  EdgeInsets get pr => EdgeInsets.only(right: toDouble());
}