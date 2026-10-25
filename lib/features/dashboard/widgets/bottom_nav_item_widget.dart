import 'package:flutter/material.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class BottomNavItemWidget extends StatelessWidget {
  final String? selectedIcon;
  final String? unSelectedIcon;
  final IconData? iconData;
  final String title;
  final VoidCallback? onTap;
  final bool isSelected;

  const BottomNavItemWidget({
    super.key,
    this.onTap,
    this.isSelected = false,
    required this.title,
    this.selectedIcon,
    this.unSelectedIcon,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color inactiveColor = Theme.of(context).disabledColor;

    return Flexible(
      flex: isSelected ? 2 : 1,
      fit: FlexFit.tight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double selectedWidth =
              (constraints.maxWidth - 4).clamp(72.0, 155.0).toDouble();
          final double labelFontSize = constraints.maxWidth < 95 ? 11.0 : 13.0;

          return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: isSelected ? selectedWidth : 40,
                height: 48,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 12 : 0,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.28),
                            blurRadius: 12,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: isSelected
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          iconData != null
                              ? Icon(
                                  iconData,
                                  size: 20,
                                  color: Colors.white,
                                )
                              : Image.asset(
                                  selectedIcon!,
                                  height: 20,
                                  width: 20,
                                  color: Colors.white,
                                ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                title,
                                maxLines: 1,
                                textAlign: TextAlign.start,
                                style: robotoMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: labelFontSize,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: iconData != null
                            ? Icon(
                                iconData,
                                size: 22,
                                color: inactiveColor,
                              )
                            : Image.asset(
                                unSelectedIcon!,
                                height: 22,
                                width: 22,
                                color: inactiveColor,
                              ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
