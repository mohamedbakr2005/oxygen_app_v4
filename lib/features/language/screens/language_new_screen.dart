import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_app_bar.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/features/language/domain/models/language_model.dart';
import 'package:Oxygen_Mart/features/language/screens/web_language_screen.dart';
import 'package:Oxygen_Mart/features/onboard/screens/onboarding_new_screen.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class ChooseLanguageNewScreen extends StatefulWidget {
  final bool fromMenu;
  const ChooseLanguageNewScreen({super.key, this.fromMenu = false});

  @override
  State<ChooseLanguageNewScreen> createState() => _ChooseLanguageNewScreenState();
}

class _ChooseLanguageNewScreenState extends State<ChooseLanguageNewScreen> {
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: (widget.fromMenu || ResponsiveHelper.isDesktop(context))
          ? CustomAppBar(title: 'language'.tr, backButton: true)
          : null,
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GetBuilder<LocalizationController>(
        builder: (localizationController) {
          if (ResponsiveHelper.isDesktop(context)) {
            return const WebLanguageScreen();
          }

          // Strictly filter for Arabic and English only
          final List<LanguageModel> availableLanguages = localizationController.languages
              .where((lang) => lang.languageCode == 'ar' || lang.languageCode == 'en')
              .toList();

          // Determine if current selection is Arabic
          final int selectedIndex = localizationController.selectedLanguageIndex;
          final bool isArabicSelected = selectedIndex >= 0 &&
              selectedIndex < localizationController.languages.length &&
              localizationController.languages[selectedIndex].languageCode == 'ar';

          return Stack(
            children: [
              // Subtle background ambient glows
              Positioned(
                top: -80,
                right: -60,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primaryColor.withValues(alpha: isDark ? 0.12 : 0.08),
                        primaryColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 220,
                left: -70,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF00A85A).withValues(alpha: isDark ? 0.10 : 0.05),
                        const Color(0xFF00A85A).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                        vertical: Dimensions.paddingSizeDefault,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight - 20),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 12),

                              // Top Header: Logo & Language Icon Badge
                              _buildHeaderBadge(context, primaryColor, isDark),

                              const SizedBox(height: 28),

                              // Titles
                              _buildTitles(context, isArabicSelected),

                              const SizedBox(height: 32),

                              // The Two Language Cards (Arabic & English)
                              ...availableLanguages.map((language) {
                                final int actualIndex = localizationController.languages.indexOf(language);
                                final bool isSelected = localizationController.selectedLanguageIndex == actualIndex;
                                final bool isArabic = language.languageCode == 'ar';

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: _LanguageCard(
                                    language: language,
                                    isSelected: isSelected,
                                    isArabic: isArabic,
                                    isDark: isDark,
                                    primaryColor: primaryColor,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      localizationController.setSelectLanguageIndex(actualIndex);
                                    },
                                  ),
                                );
                              }),

                              const Spacer(),

                              // Bottom CTA Button & Footnote
                              _buildBottomAction(
                                context,
                                localizationController,
                                isArabicSelected,
                                primaryColor,
                              ),

                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Top Brand Logo and Floating Language Icon
  Widget _buildHeaderBadge(BuildContext context, Color primaryColor, bool isDark) {
    return Column(
      children: [
        // App Logo
        Image.asset(
          Images.logo,
          height: 48,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const SizedBox(),
        ),
        const SizedBox(height: 20),

        // Glowing Language Globe Icon Container
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.16),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    const Color(0xFF00A85A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.translate_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Modern Bilingual Header Text
  Widget _buildTitles(BuildContext context, bool isArabicSelected) {
    return Column(
      children: [
        // Bilingual tag pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language_rounded,
                size: 15,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                'العربية • English',
                style: robotoMedium.copyWith(
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Headline
        Text(
          isArabicSelected ? 'اختر لغة التطبيق' : 'Choose Your Language',
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeOverLarge,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            letterSpacing: -0.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            isArabicSelected
                ? 'اختر لغتك المفضلة لبدء تجربة تسوق مميزة في أكسجين'
                : 'Select your preferred language to proceed with Oxygen Mart',
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall + 1,
              color: Theme.of(context).disabledColor,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Bottom CTA button and helper caption
  Widget _buildBottomAction(
    BuildContext context,
    LocalizationController localizationController,
    bool isArabicSelected,
    Color primaryColor,
  ) {
    return Column(
      children: [
        // Continue Button
        Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                primaryColor,
                const Color(0xFF00A85A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.38),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleContinue(context, localizationController),
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isArabicSelected ? 'متابعة' : 'Continue',
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isArabicSelected
                          ? Icons.arrow_back_rounded
                          : Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Footnote
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(width: 6),
            Text(
              isArabicSelected
                  ? 'يمكنك تغيير اللغة في أي وقت من الإعدادات'
                  : 'You can change the language anytime in settings',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleContinue(
    BuildContext context,
    LocalizationController localizationController,
  ) {
    if (localizationController.languages.isNotEmpty &&
        localizationController.selectedLanguageIndex != -1) {
      final selectedLang = localizationController.languages[localizationController.selectedLanguageIndex];
      localizationController.setLanguage(
        Locale(selectedLang.languageCode!, selectedLang.countryCode),
      );

      if (widget.fromMenu) {
        Navigator.pop(context);
      } else {
        Get.to(
          () => const OnBoardingNewScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 300),
        );
      }
    } else {
      showCustomSnackBar('select_a_language'.tr);
    }
  }
}

/// Premium Interactive Language Card
class _LanguageCard extends StatelessWidget {
  final LanguageModel language;
  final bool isSelected;
  final bool isArabic;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.isArabic,
    required this.isDark,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String title = isArabic ? 'العربية' : 'English';
    final String subtitle = isArabic ? 'اللغة العربية • Arabic' : 'English (US) • الإنجليزية';
    final String badge = isArabic ? 'عربي' : 'EN';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark
                ? primaryColor.withValues(alpha: 0.16)
                : primaryColor.withValues(alpha: 0.06))
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? primaryColor
              : Theme.of(context).disabledColor.withValues(alpha: 0.18),
          width: isSelected ? 2 : 1.2,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: primaryColor.withValues(alpha: isDark ? 0.30 : 0.16),
              blurRadius: 18,
              offset: const Offset(0, 6),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                // Flag / Emblem in container
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? primaryColor.withValues(alpha: 0.4)
                          : Theme.of(context).disabledColor.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Image.asset(
                        language.imageUrl ?? '',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Text(
                            isArabic ? '🇸🇦' : '🇺🇸',
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Language title & subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: robotoBold.copyWith(
                                fontSize: 18,
                                color: isSelected
                                    ? primaryColor
                                    : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Pill badge (AR / EN)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withValues(alpha: 0.15)
                                  : Theme.of(context).disabledColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badge,
                              style: robotoMedium.copyWith(
                                fontSize: 11,
                                color: isSelected
                                    ? primaryColor
                                    : Theme.of(context).disabledColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).disabledColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Custom Radio / Checkmark Icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? primaryColor : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : Theme.of(context).disabledColor.withValues(alpha: 0.4),
                      width: isSelected ? 0 : 1.8,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.45),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 17,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
