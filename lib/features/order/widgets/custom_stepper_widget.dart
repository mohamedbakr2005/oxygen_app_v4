import 'package:flutter/material.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class CustomStepperWidget extends StatelessWidget {
  final bool isCompleted;
  final bool isCurrent;
  final bool haveLeftBar;
  final bool haveRightBar;
  final bool leftBarActive;
  final bool rightBarActive;
  final String title;

  const CustomStepperWidget({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.isCurrent,
    required this.haveLeftBar,
    required this.haveRightBar,
    required this.leftBarActive,
    required this.rightBarActive,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color disabledColor = Theme.of(context).disabledColor.withOpacity(0.4);
    final bool isActive = isCompleted || isCurrent;

    return Expanded(
      child: Column(children: [
        Row(children: [
          Expanded(
            child: haveLeftBar
                ? Container(
                    height: 2,
                    color: leftBarActive ? primaryColor : disabledColor,
                  )
                : const SizedBox(),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? primaryColor : Colors.transparent,
              border: Border.all(
                color: isActive ? primaryColor : disabledColor,
                width: 2,
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : isCurrent
                    ? const Padding(
                        padding: EdgeInsets.all(5),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const SizedBox(),
          ),
          Expanded(
            child: haveRightBar
                ? Container(
                    height: 2,
                    color: rightBarActive ? primaryColor : disabledColor,
                  )
                : const SizedBox(),
          ),
        ]),
        const SizedBox(height: 6),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: robotoMedium.copyWith(
            color: isActive ? primaryColor : disabledColor,
            fontSize: Dimensions.fontSizeExtraSmall,
          ),
        ),
      ]),
    );
  }
}
