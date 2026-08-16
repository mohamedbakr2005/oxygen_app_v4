import 'package:flutter/material.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';

class QuantityButton extends StatelessWidget {
  final bool isIncrement;
  final Function? onTap;
  final bool fromSheet;
  final bool showRemoveIcon;
  final Color? color;
  const QuantityButton(
      {super.key,
      required this.isIncrement,
      required this.onTap,
      this.fromSheet = false,
      this.showRemoveIcon = false,
      this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        height: fromSheet ? 40 : 32,
        width: fromSheet ? 40 : 32,
        margin:
            const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              width: 1,
              color: isIncrement
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor),
          color: isIncrement
                  ? color ?? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor.withOpacity(0.2),
        ),
        alignment: Alignment.center,
        child: Icon(
          isIncrement
                  ? Icons.add
                  : Icons.remove,
          size: 20,
          color:  isIncrement
                  ? Theme.of(context).cardColor
                  : Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
