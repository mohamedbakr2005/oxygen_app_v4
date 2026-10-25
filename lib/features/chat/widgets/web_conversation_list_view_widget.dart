import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/custom_ink_well.dart';
import 'package:Oxygen_Mart/common/widgets/paginated_list_view.dart';
import 'package:Oxygen_Mart/features/chat/controllers/chat_controller.dart';
import 'package:Oxygen_Mart/features/chat/domain/models/conversation_model.dart';
import 'package:Oxygen_Mart/features/chat/enums/user_type_enum.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/features/notification/domain/models/notification_body_model.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/date_converter.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class WebConversationListViewWidget extends StatefulWidget {
  final ScrollController scrollController;
  final ConversationsModel? conversation;
  final ChatController chatController;
  final String type;

  const WebConversationListViewWidget({
    super.key,
    required this.scrollController,
    required this.conversation,
    required this.chatController,
    required this.type,
  });

  @override
  State<WebConversationListViewWidget> createState() =>
      _WebConversationListViewWidgetState();
}

class _WebConversationListViewWidgetState
    extends State<WebConversationListViewWidget> {
  @override
  void initState() {
    super.initState();

    Get.find<ChatController>().getConversationList(1, type: widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return (widget.conversation != null &&
            widget.conversation?.conversations != null)
        ? widget.conversation!.conversations!.isNotEmpty
            ? RefreshIndicator(
                onRefresh: () async {
                  await Get.find<ChatController>()
                      .getConversationList(1, type: widget.type);
                },
                child: SingleChildScrollView(
                  controller: widget.scrollController,
                  // physics: const NeverScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                  child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: PaginatedListView(
                        scrollController: widget.scrollController,
                        onPaginate: (int? offset) =>
                            widget.chatController.getConversationList(offset!),
                        totalSize: widget.conversation!.totalSize,
                        offset: widget.conversation!.offset,
                        enabledPagination:
                            widget.chatController.searchConversationModel ==
                                null,
                        itemView: ListView.builder(
                          itemCount: widget.conversation!.conversations!.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeLarge),
                          itemBuilder: (context, index) {
                            final Conversation? conv = widget.conversation?.conversations?[index];
                            if (conv == null) {
                              return const SizedBox.shrink();
                            }

                            String? type;
                            User? user;
                            if (conv.senderType == UserType.user.name ||
                                conv.senderType == UserType.customer.name) {
                              user = conv.receiver;
                              type = conv.receiverType;
                            } else {
                              user = conv.sender;
                              type = conv.senderType;
                            }

                            final String userName = user != null
                                ? '${user.fName ?? ''} ${user.lName ?? ''}'.trim()
                                : '';
                            final String displayTitle = userName.isNotEmpty
                                ? userName
                                : '${(type ?? 'user').tr} ${'deleted'.tr}';

                            return Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: (widget.chatController
                                                    .selectedIndex ==
                                                index &&
                                            widget.chatController.type == type)
                                        ? Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.10)
                                        : Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall),
                                  ),
                                  child: CustomInkWell(
                                    onTap: () {
                                      if (AuthHelper.isLoggedIn()) {
                                        Get.find<ChatController>().getMessages(
                                            1,
                                            NotificationBodyModel(
                                              type: conv.senderType,
                                              notificationType:
                                                  NotificationType.message,
                                              adminId:
                                                  type == UserType.admin.name
                                                      ? 0
                                                      : null,
                                              restaurantId:
                                                  type == UserType.vendor.name
                                                      ? user?.id
                                                      : null,
                                              deliverymanId: type ==
                                                      UserType.delivery_man.name
                                                  ? user?.id
                                                  : null,
                                            ),
                                            user,
                                            conv.id,
                                            firstLoad: true);
                                        if (Get.find<ProfileController>()
                                                    .userInfoModel ==
                                                null ||
                                            Get.find<ProfileController>()
                                                    .userInfoModel!
                                                    .userInfo ==
                                                null) {
                                          Get.find<ProfileController>()
                                              .getUserInfo();
                                        }
                                        widget.chatController
                                            .setNotificationBody(
                                          NotificationBodyModel(
                                            type: type,
                                            notificationType:
                                                NotificationType.message,
                                            adminId: type == UserType.admin.name
                                                ? 0
                                                : null,
                                            restaurantId:
                                                type == UserType.vendor.name
                                                    ? user?.id
                                                    : null,
                                            deliverymanId: type ==
                                                    UserType.delivery_man.name
                                                ? user?.id
                                                : null,
                                            conversationId: conv.id,
                                            index: index,
                                            image:
                                                '${user?.imageFullUrl ?? ''}',
                                            name: userName,
                                            receiverType: type,
                                          ),
                                        );

                                        widget.chatController
                                            .setSelectedIndex(index);
                                      }
                                    },
                                    highlightColor: Theme.of(context)
                                        .colorScheme
                                        .surface
                                        .withOpacity(0.1),
                                    radius: Dimensions.radiusSmall,
                                    child: Stack(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeSmall),
                                        child: Row(children: [
                                          ClipOval(
                                              child: CustomImage(
                                            height: 50,
                                            width: 50,
                                            image:
                                                '${user?.imageFullUrl ?? ''}',
                                          )),
                                          const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeSmall),
                                          Expanded(
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                Text(
                                                  displayTitle,
                                                  style: robotoMedium,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeExtraSmall),
                                                if (conv.lastMessage?.message != null &&
                                                    conv.lastMessage!.message!.isNotEmpty)
                                                  Text(
                                                    conv.lastMessage!.message!,
                                                    style: robotoRegular.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeSmall,
                                                        color: Theme.of(
                                                                context)
                                                            .disabledColor),
                                                  ),
                                              ])),
                                        ]),
                                      ),
                                      if (conv.lastMessageTime != null &&
                                          conv.lastMessageTime!.isNotEmpty)
                                        Positioned(
                                          right:
                                              Get.find<LocalizationController>()
                                                      .isLtr
                                                  ? 5
                                                  : null,
                                          top: 15,
                                          left: Get.find<LocalizationController>()
                                                  .isLtr
                                              ? null
                                              : 5,
                                          child: Text(
                                            DateConverter.convertOnlyTodayTime(
                                                conv.lastMessageTime!),
                                            style: robotoRegular.copyWith(
                                                color:
                                                    Theme.of(context).hintColor,
                                                fontSize: Dimensions
                                                    .fontSizeExtraSmall),
                                          ),
                                        ),
                                      GetBuilder<ProfileController>(
                                          builder: (profileController) {
                                        final int? currentUserId = profileController.userInfoModel?.userInfo?.id ??
                                            profileController.userInfoModel?.id;
                                        final int? senderId = conv.lastMessage?.senderId;
                                        final int unreadCount = conv.unreadMessageCount ?? 0;
                                        final bool showUnread = currentUserId != null &&
                                            senderId != null &&
                                            senderId != currentUserId &&
                                            unreadCount > 0;

                                        if (!showUnread) {
                                          return const SizedBox();
                                        }

                                        return Positioned(
                                          right: Get.find<
                                                      LocalizationController>()
                                                  .isLtr
                                              ? 5
                                              : null,
                                          bottom: 8,
                                          left: Get.find<
                                                      LocalizationController>()
                                                  .isLtr
                                              ? null
                                              : 5,
                                          child: Container(
                                            padding: const EdgeInsets.all(
                                                Dimensions
                                                    .paddingSizeExtraSmall),
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                shape: BoxShape.circle),
                                            child: Text(
                                              unreadCount.toString(),
                                              style: robotoMedium.copyWith(
                                                  color: Theme.of(context)
                                                      .cardColor,
                                                  fontSize: Dimensions
                                                      .fontSizeExtraSmall),
                                            ),
                                          ),
                                        );
                                      }),
                                    ]),
                                  ),
                                ),
                                index + 1 ==
                                        widget
                                            .conversation!.conversations!.length
                                    ? const SizedBox()
                                    : Divider(
                                        color: Theme.of(context)
                                            .disabledColor
                                            .withOpacity(.5)),
                              ],
                            );
                          },
                        ),
                      )),
                ),
              )
            : Center(child: Text('no_conversation_found'.tr))
        : const ConversationShimmer();
  }
}

class ConversationShimmer extends StatelessWidget {
  const ConversationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)
              ],
            ),
            child: Shimmer.fromColors(
              period: const Duration(milliseconds: 2000),
      baseColor: Colors.grey,
      highlightColor: Colors.white,
              enabled: true,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Column(
                  children: [
                    Row(children: [
                      ClipOval(
                          child: Container(
                              height: 50, width: 50, color: Colors.grey[300])),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Container(
                                height: 10,
                                width: Get.width * 0.5,
                                color: Colors.grey[300]),
                            const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall),
                            Container(
                                height: 10,
                                width: Get.width * 0.3,
                                color: Colors.grey[300]),
                          ])),
                    ]),
                    Divider(
                        color: Theme.of(context).disabledColor.withOpacity(.5)),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
