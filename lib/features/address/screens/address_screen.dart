import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/address_widget.dart';
import 'package:Oxygen_Mart/common/widgets/custom_app_bar.dart';
import 'package:Oxygen_Mart/common/widgets/custom_ink_well.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/footer_view.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/common/widgets/no_data_screen.dart';
import 'package:Oxygen_Mart/common/widgets/not_logged_in_screen.dart';
import 'package:Oxygen_Mart/common/widgets/web_page_title_widget.dart';
import 'package:Oxygen_Mart/features/address/controllers/address_controller.dart';
import 'package:Oxygen_Mart/features/address/widgets/address_confirmation_dialogue.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class AddressScreen extends StatefulWidget {
  final bool fromDashboard;
  const AddressScreen({super.key, this.fromDashboard = false});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initCall();
  }

  void initCall() {
    if (AuthHelper.isLoggedIn()) {
      Get.find<AddressController>().getAddressList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = AuthHelper.isLoggedIn();
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return GetBuilder<AddressController>(builder: (addressController) {
      final bool hasAddresses = addressController.addressList != null && addressController.addressList!.isNotEmpty;

      return Scaffold(
        appBar: CustomAppBar(
          title: 'my_address'.tr,
          backButton: widget.fromDashboard ? false : true,
        ),
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        floatingActionButton: isDesktop || !isLoggedIn
            ? null
            : (!hasAddresses && addressController.addressList != null)
                ? null
                : FloatingActionButton.extended(
                    backgroundColor: Theme.of(context).primaryColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onPressed: () => Get.toNamed(RouteHelper.getAddAddressRoute(
                      false, false, 0, isNavbar: true,
                    )),
                    icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white, size: 20),
                    label: Text(
                      'add_new_address'.tr,
                      style: robotoBold.copyWith(
                        color: Colors.white,
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ),
        floatingActionButtonLocation: isDesktop
            ? FloatingActionButtonLocation.centerFloat
            : FloatingActionButtonLocation.startFloat,
        body: Container(
          height: context.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(isDesktop ? Images.addressCity : Images.city),
              alignment: isDesktop ? Alignment.center : Alignment.bottomCenter,
              fit: BoxFit.fitWidth,
              opacity: 0.85,
            ),
          ),
          child: isLoggedIn
              ? RefreshIndicator(
                  onRefresh: () async {
                    await addressController.getAddressList();
                  },
                  color: Theme.of(context).primaryColor,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    child: Column(
                      children: [
                        WebScreenTitleWidget(title: 'address'.tr),
                        Center(
                          child: FooterView(
                            minHeight: 0.45,
                            child: SizedBox(
                              width: Dimensions.webMaxWidth,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                  vertical: Dimensions.paddingSizeSmall,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isDesktop) const SizedBox(height: Dimensions.paddingSizeSmall),

                                    // Top Summary Bar when addresses exist
                                    if (hasAddresses)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 3.5,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).primaryColor,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'saved_addresses'.tr.isNotEmpty ? 'saved_addresses'.tr : 'عناويني المحفوظة',
                                              style: robotoBold.copyWith(
                                                fontSize: Dimensions.fontSizeLarge,
                                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '${addressController.addressList!.length}',
                                                style: robotoBold.copyWith(
                                                  fontSize: 11,
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    // Address List / Grid or Loading / Empty
                                    if (addressController.addressList != null)
                                      if (addressController.addressList!.isNotEmpty)
                                        if (isDesktop)
                                          GridView.builder(
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisSpacing: Dimensions.paddingSizeLarge,
                                              mainAxisSpacing: Dimensions.paddingSizeLarge,
                                              childAspectRatio: 3.2,
                                              crossAxisCount: 3,
                                            ),
                                            physics: const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: addressController.addressList!.length + 1,
                                            itemBuilder: (context, index) {
                                              if (index == addressController.addressList!.length) {
                                                return Container(
                                                  margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).cardColor,
                                                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                                    border: Border.all(
                                                      color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                                      width: 1.2,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                                                        blurRadius: 10,
                                                        offset: const Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: CustomInkWell(
                                                    onTap: () => Get.toNamed(RouteHelper.getAddAddressRoute(false, false, 0)),
                                                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                                    radius: Dimensions.radiusLarge,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor, size: 28),
                                                        const SizedBox(height: Dimensions.paddingSizeSmall),
                                                        Text(
                                                          'add_new_address'.tr,
                                                          style: robotoBold.copyWith(
                                                            color: Theme.of(context).primaryColor,
                                                            fontSize: Dimensions.fontSizeSmall,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }
                                              return _buildAddressItem(addressController, index);
                                            },
                                          )
                                        else
                                          ListView.builder(
                                            physics: const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: addressController.addressList!.length,
                                            itemBuilder: (context, index) => _buildAddressItem(addressController, index),
                                          )
                                      else
                                        NoDataScreen(text: 'no_saved_address_found'.tr, fromAddress: true)
                                    else
                                      const Padding(
                                        padding: EdgeInsets.only(top: 80),
                                        child: Center(child: CircularProgressIndicator()),
                                      ),

                                    // Extra bottom space for floating button
                                    const SizedBox(height: 80),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : NotLoggedInScreen(callBack: (value) {
                  initCall();
                  setState(() {});
                }),
        ),
        bottomNavigationBar: widget.fromDashboard
            ? Container(height: GetPlatform.isIOS ? 80 : 65)
            : const SizedBox.shrink(),
      );
    });
  }

  Widget _buildAddressItem(AddressController addressController, int index) {
    return AddressWidget(
      address: addressController.addressList![index],
      fromAddress: true,
      onTap: () {
        Get.toNamed(RouteHelper.getMapRoute(
          addressController.addressList![index],
          'address',
          false,
        ));
      },
      onEditPressed: () {
        Get.toNamed(RouteHelper.getEditAddressRoute(
          addressController.addressList![index],
        ));
      },
      onRemovePressed: () {
        if (Get.isSnackbarOpen) {
          Get.back();
        }
        Get.dialog(
          AddressConfirmDialogue(
            icon: Images.locationConfirm,
            title: 'are_you_sure'.tr,
            description: 'you_want_to_delete_this_location'.tr,
            onYesPressed: () {
              addressController.deleteUserAddressByID(
                addressController.addressList![index].id,
                index,
              ).then((response) {
                Get.back();
                showCustomSnackBar(
                  response.message,
                  isError: !response.isSuccess,
                );
              });
            },
          ),
        );
      },
    );
  }
}
