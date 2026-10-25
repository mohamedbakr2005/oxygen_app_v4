import 'dart:convert';
import 'package:Oxygen_Mart/features/address/domain/models/address_model.dart';
import 'package:Oxygen_Mart/features/parcel/domain/models/parcel_category_model.dart';
import 'package:Oxygen_Mart/features/pro/domain/models/pro_active_offer_model.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';

class PaginatedOrderModel {
  int? totalSize;
  String? limit;
  int? offset;
  List<OrderModel>? orders;

  PaginatedOrderModel({this.totalSize, this.limit, this.offset, this.orders});

  PaginatedOrderModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'].toString();
    offset =
        (json['offset'] != null && json['offset'].toString().trim().isNotEmpty)
            ? int.parse(json['offset'].toString())
            : null;
    if (json['orders'] != null) {
      orders = [];
      json['orders'].forEach((v) {
        if (v is Map<String, dynamic>) {
          orders!.add(OrderModel.fromJson(v));
        } else if (v is String) {
          try {
            orders!.add(OrderModel.fromJson(jsonDecode(v)));
          } catch (_) {}
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderModel {
  int? id;
  int? userId;
  double? orderAmount;
  double? couponDiscountAmount;
  String? couponDiscountTitle;
  String? paymentStatus;
  String? orderStatus;
  double? totalTaxAmount;
  String? paymentMethod;
  String? couponCode;
  String? orderNote;
  String? orderType;
  String? createdAt;
  String? updatedAt;
  double? deliveryCharge;
  String? scheduleAt;
  String? otp;
  String? pending;
  String? accepted;
  String? confirmed;
  String? processing;
  String? handover;
  String? pickedUp;
  String? delivered;
  String? canceled;
  String? refundRequested;
  String? refunded;
  int? scheduled;
  double? storeDiscountAmount;
  String? failed;
  int? detailsCount;
  List<String?>? orderAttachmentFullUrl;
  String? chargePayer;
  String? moduleType;
  DeliveryMan? deliveryMan;
  Store? store;
  AddressModel? deliveryAddress;
  AddressModel? receiverDetails;
  ParcelCategoryModel? parcelCategory;
  double? dmTips;
  String? refundCancellationNote;
  String? refundCustomerNote;
  Refund? refund;
  bool? prescriptionOrder;
  bool? taxStatus;
  String? cancellationReason;
  int? processingTime;
  bool? cutlery;
  String? unavailableItemNote;
  String? deliveryInstruction;
  double? taxPercentage;
  double? additionalCharge;
  double? partiallyPaidAmount;
  List<Payments>? payments;
  List<String>? orderProofFullUrl;
  OfflinePayment? offlinePayment;
  double? flashAdminDiscountAmount;
  double? flashStoreDiscountAmount;
  double? extraPackagingAmount;
  double? referrerBonusAmount;
  int? moduleId;
  ProBenefitType? benefitType;
  double? deliveryFeeReductionAmount;
  ProOfferType? deliveryOfferType;
  double? proDiscount;
  bool? canReorder;

  OrderModel({
    this.canReorder,
    this.benefitType,
    this.deliveryFeeReductionAmount,
    this.deliveryOfferType,
    this.proDiscount,
    this.id,
    this.userId,
    this.orderAmount,
    this.couponDiscountAmount,
    this.couponDiscountTitle,
    this.paymentStatus,
    this.orderStatus,
    this.totalTaxAmount,
    this.paymentMethod,
    this.couponCode,
    this.orderNote,
    this.orderType,
    this.createdAt,
    this.updatedAt,
    this.deliveryCharge,
    this.scheduleAt,
    this.otp,
    this.pending,
    this.accepted,
    this.confirmed,
    this.processing,
    this.handover,
    this.pickedUp,
    this.delivered,
    this.canceled,
    this.refundRequested,
    this.refunded,
    this.scheduled,
    this.storeDiscountAmount,
    this.failed,
    this.detailsCount,
    this.chargePayer,
    this.moduleType,
    this.deliveryMan,
    this.deliveryAddress,
    this.receiverDetails,
    this.parcelCategory,
    this.store,
    this.orderAttachmentFullUrl,
    this.dmTips,
    this.refundCancellationNote,
    this.refundCustomerNote,
    this.refund,
    this.prescriptionOrder,
    this.taxStatus,
    this.cancellationReason,
    this.processingTime,
    this.cutlery,
    this.unavailableItemNote,
    this.deliveryInstruction,
    this.taxPercentage,
    this.additionalCharge,
    this.partiallyPaidAmount,
    this.payments,
    this.orderProofFullUrl,
    this.offlinePayment,
    this.flashAdminDiscountAmount,
    this.flashStoreDiscountAmount,
    this.extraPackagingAmount,
    this.referrerBonusAmount,
    this.moduleId,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    orderAmount = json['order_amount'] != null ? double.tryParse(json['order_amount'].toString()) : null;
    couponDiscountAmount = json['coupon_discount_amount'] != null ? double.tryParse(json['coupon_discount_amount'].toString()) : null;
    couponDiscountTitle = json['coupon_discount_title'];
    paymentStatus = json['payment_status'];
    orderStatus = json['order_status'];
    totalTaxAmount = json['total_tax_amount'] != null ? double.tryParse(json['total_tax_amount'].toString()) : null;
    paymentMethod = json['payment_method'];
    couponCode = json['coupon_code'];
    orderNote = json['order_note'];
    orderType = json['order_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deliveryCharge = json['delivery_charge'] != null ? double.tryParse(json['delivery_charge'].toString()) : null;
    scheduleAt = json['schedule_at'];
    otp = json['otp'];
    pending = json['pending'];
    accepted = json['accepted'];
    confirmed = json['confirmed'];
    processing = json['processing'];
    handover = json['handover'];
    pickedUp = json['picked_up'];
    delivered = json['delivered'];
    canceled = json['canceled'];
    refundRequested = json['refund_requested'];
    refunded = json['refunded'];
    scheduled = json['scheduled'];
    storeDiscountAmount = json['store_discount_amount'] != null ? double.tryParse(json['store_discount_amount'].toString()) : null;
    failed = json['failed'];
    detailsCount = json['details_count'];
    if (json['order_attachment_full_url'] != null) {
      orderAttachmentFullUrl = [];
      json['order_attachment_full_url'].forEach((v) {
        orderAttachmentFullUrl!.add(v);
      });
    }
    chargePayer = json['charge_payer'];
    moduleType = json['module_type'];
    if (json['delivery_man'] != null) {
      try {
        deliveryMan = json['delivery_man'] is String
            ? DeliveryMan.fromJson(jsonDecode(json['delivery_man']))
            : DeliveryMan.fromJson(json['delivery_man']);
      } catch (_) {
        deliveryMan = null;
      }
    }
    if (json['store'] != null) {
      try {
        store = json['store'] is String
            ? Store.fromJson(jsonDecode(json['store']))
            : Store.fromJson(json['store']);
      } catch (_) {
        store = null;
      }
    }
    if (json['delivery_address'] != null) {
      try {
        deliveryAddress = json['delivery_address'] is String
            ? AddressModel.fromJson(jsonDecode(json['delivery_address']))
            : AddressModel.fromJson(json['delivery_address']);
      } catch (_) {
        deliveryAddress = null;
      }
    }
    if (json['receiver_details'] != null) {
      try {
        receiverDetails = json['receiver_details'] is String
            ? AddressModel.fromJson(jsonDecode(json['receiver_details']))
            : AddressModel.fromJson(json['receiver_details']);
      } catch (_) {
        receiverDetails = null;
      }
    }
    if (json['parcel_category'] != null) {
      try {
        parcelCategory = json['parcel_category'] is String
            ? ParcelCategoryModel.fromJson(jsonDecode(json['parcel_category']))
            : ParcelCategoryModel.fromJson(json['parcel_category']);
      } catch (_) {
        parcelCategory = null;
      }
    }
    dmTips = json['dm_tips'] != null ? double.tryParse(json['dm_tips'].toString()) : null;
    refundCancellationNote = json['refund_cancellation_note'];
    refundCustomerNote = json['refund_customer_note'];
    if (json['refund'] != null) {
      try {
        refund = json['refund'] is String
            ? Refund.fromJson(jsonDecode(json['refund']))
            : Refund.fromJson(json['refund']);
      } catch (_) {
        refund = null;
      }
    }
    prescriptionOrder = json['prescription_order'];
    taxStatus = json['tax_status'] == 'included' ? true : false;
    cancellationReason = json['cancellation_reason'];
    processingTime = json['processing_time'];
    cutlery = json['cutlery'];
    unavailableItemNote = json['unavailable_item_note'];
    deliveryInstruction = json['delivery_instruction'];
    taxPercentage = json['tax_percentage'] != null ? double.tryParse(json['tax_percentage'].toString()) : null;
    additionalCharge = json['additional_charge'] != null ? double.tryParse(json['additional_charge'].toString()) ?? 0 : 0;
    if (json['partially_paid_amount'] != null) {
      partiallyPaidAmount =
          double.tryParse(json['partially_paid_amount'].toString());
    }
    if (json['payments'] != null) {
      payments = <Payments>[];
      json['payments'].forEach((v) {
        if (v is Map<String, dynamic>) {
          payments!.add(Payments.fromJson(v));
        } else if (v is String) {
          try {
            payments!.add(Payments.fromJson(jsonDecode(v)));
          } catch (_) {}
        }
      });
    }
    if (json['order_proof_full_url'] != null) {
      orderProofFullUrl = [];
      json['order_proof_full_url'].forEach((v) {
        if (v != null) {
          orderProofFullUrl!.add(v.toString());
        }
      });
    }
    if (json['offline_payment'] != null) {
      try {
        offlinePayment = json['offline_payment'] is String
            ? OfflinePayment.fromJson(jsonDecode(json['offline_payment']))
            : OfflinePayment.fromJson(json['offline_payment']);
      } catch (_) {
        offlinePayment = null;
      }
    }
    flashAdminDiscountAmount = json['flash_admin_discount_amount'] != null ? double.tryParse(json['flash_admin_discount_amount'].toString()) : null;
    flashStoreDiscountAmount = json['flash_store_discount_amount'] != null ? double.tryParse(json['flash_store_discount_amount'].toString()) : null;
    extraPackagingAmount = json['extra_packaging_amount'] != null ? double.tryParse(json['extra_packaging_amount'].toString()) : null;
    referrerBonusAmount = json['ref_bonus_amount'] != null ? double.tryParse(json['ref_bonus_amount'].toString()) : null;
    moduleId = json['module_id'] is String ? int.tryParse(json['module_id']) : json['module_id'];
    benefitType = ProBenefitType.fromString(json['benefit_type']);
    deliveryFeeReductionAmount = json['delivery_fee_reduction_amount'] != null ? double.tryParse(json['delivery_fee_reduction_amount'].toString()) : null;
    deliveryOfferType = ProOfferType.fromString(json['delivery_offer_type']);
    proDiscount = json['pro_discount'] != null ? double.tryParse(json['pro_discount'].toString()) : null;
    canReorder = json['can_reorder'] == true || json['can_reorder'] == 1;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['order_amount'] = orderAmount;
    data['coupon_discount_amount'] = couponDiscountAmount;
    data['coupon_discount_title'] = couponDiscountTitle;
    data['payment_status'] = paymentStatus;
    data['order_status'] = orderStatus;
    data['total_tax_amount'] = totalTaxAmount;
    data['payment_method'] = paymentMethod;
    data['coupon_code'] = couponCode;
    data['order_note'] = orderNote;
    data['order_type'] = orderType;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['delivery_charge'] = deliveryCharge;
    data['schedule_at'] = scheduleAt;
    data['otp'] = otp;
    data['pending'] = pending;
    data['accepted'] = accepted;
    data['confirmed'] = confirmed;
    data['processing'] = processing;
    data['handover'] = handover;
    data['picked_up'] = pickedUp;
    data['delivered'] = delivered;
    data['canceled'] = canceled;
    data['refund_requested'] = refundRequested;
    data['refunded'] = refunded;
    data['scheduled'] = scheduled;
    data['store_discount_amount'] = storeDiscountAmount;
    data['failed'] = failed;
    data['order_attachment_full_url'] = orderAttachmentFullUrl;
    data['charge_payer'] = chargePayer;
    data['module_type'] = moduleType;
    data['details_count'] = detailsCount;
    if (deliveryMan != null) {
      data['delivery_man'] = deliveryMan!.toJson();
    }
    if (store != null) {
      data['store'] = store!.toJson();
    }
    if (deliveryAddress != null) {
      data['delivery_address'] = deliveryAddress!.toJson();
    }
    if (receiverDetails != null) {
      data['receiver_details'] = receiverDetails!.toJson();
    }
    if (parcelCategory != null) {
      data['parcel_category'] = parcelCategory!.toJson();
    }
    data['dm_tips'] = dmTips;
    data['refund_cancellation_note'] = refundCancellationNote;
    data['refund_customer_note'] = refundCustomerNote;
    if (deliveryAddress != null) {
      data['refund'] = refund!.toJson();
    }
    data['prescription_order'] = prescriptionOrder;
    data['processing_time'] = processingTime;
    data['cutlery'] = cutlery;
    data['unavailable_item_note'] = unavailableItemNote;
    data['delivery_instruction'] = deliveryInstruction;
    data['additional_charge'] = additionalCharge;
    data['partially_paid_amount'] = partiallyPaidAmount;
    if (payments != null) {
      data['payments'] = payments!.map((v) => v.toJson()).toList();
    }
    data['order_proof_full_url'] = orderProofFullUrl;
    if (offlinePayment != null) {
      data['offline_payment'] = offlinePayment!.toJson();
    }
    data['offline_payment'] = offlinePayment;
    data['flash_admin_discount_amount'] = flashAdminDiscountAmount;
    data['flash_store_discount_amount'] = flashStoreDiscountAmount;
    data['extra_packaging_amount'] = extraPackagingAmount;
    data['ref_bonus_amount'] = referrerBonusAmount;
    data['module_id'] = moduleId;
    data['benefit_type'] = benefitType?.name == 'deliveryFee' ? 'delivery_fee' : benefitType?.name;
    data['delivery_fee_reduction_amount'] = deliveryFeeReductionAmount;
    data['delivery_offer_type'] = deliveryOfferType?.toJson();
    data['pro_discount'] = proDiscount;
    data['can_reorder'] = canReorder;
    return data;
  }
}

class DeliveryMan {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? imageFullUrl;
  int? zoneId;
  int? active;
  int? available;
  double? avgRating;
  int? ratingCount;
  String? lat;
  String? lng;
  String? location;

  DeliveryMan({
    this.id,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.imageFullUrl,
    this.zoneId,
    this.active,
    this.available,
    this.avgRating,
    this.ratingCount,
    this.lat,
    this.lng,
    this.location,
  });

  DeliveryMan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    imageFullUrl = json['image_full_url'];
    zoneId = json['zone_id'];
    active = json['active'];
    available = json['available'];
    avgRating = json['avg_rating'].toDouble();
    ratingCount = json['rating_count'];
    lat = json['lat'];
    lng = json['lng'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['image_full_url'] = imageFullUrl;
    data['zone_id'] = zoneId;
    data['active'] = active;
    data['available'] = available;
    data['avg_rating'] = avgRating;
    data['rating_count'] = ratingCount;
    data['lat'] = lat;
    data['lng'] = lng;
    data['location'] = location;
    return data;
  }
}

class Payments {
  int? id;
  int? orderId;
  double? amount;
  String? paymentStatus;
  String? paymentMethod;
  String? createdAt;
  String? updatedAt;

  Payments(
      {this.id,
      this.orderId,
      this.amount,
      this.paymentStatus,
      this.paymentMethod,
      this.createdAt,
      this.updatedAt});

  Payments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    amount = json['amount']?.toDouble();
    paymentStatus = json['payment_status'];
    paymentMethod = json['payment_method'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['amount'] = amount;
    data['payment_status'] = paymentStatus;
    data['payment_method'] = paymentMethod;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class OfflinePayment {
  List<Input>? input;
  Data? data;
  List<MethodFields>? methodFields;

  OfflinePayment({this.input, this.data, this.methodFields});

  OfflinePayment.fromJson(Map<String, dynamic> json) {
    if (json['input'] != null) {
      input = <Input>[];
      json['input'].forEach((v) {
        input!.add(Input.fromJson(v));
      });
    }
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    if (json['method_fields'] != null) {
      methodFields = <MethodFields>[];
      json['method_fields'].forEach((v) {
        methodFields!.add(MethodFields.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (input != null) {
      data['input'] = input!.map((v) => v.toJson()).toList();
    }
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (methodFields != null) {
      data['method_fields'] = input!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Input {
  String? userInput;
  String? userData;

  Input({this.userInput, this.userData});

  Input.fromJson(Map<String, dynamic> json) {
    userInput = json['user_input'];
    userData = json['user_data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_input'] = userInput;
    data['user_data'] = userData;
    return data;
  }
}

class Data {
  String? status;
  String? methodId;
  String? methodName;
  String? customerNote;

  Data({this.status, this.methodId, this.methodName, this.customerNote});

  Data.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    methodId = json['method_id'].toString();
    methodName = json['method_name'];
    customerNote = json['customer_note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['method_id'] = methodId;
    data['method_name'] = methodName;
    data['customer_note'] = customerNote;
    return data;
  }
}

class MethodFields {
  String? inputName;
  String? inputData;

  MethodFields({this.inputName, this.inputData});

  MethodFields.fromJson(Map<String, dynamic> json) {
    inputName = json['input_name'];
    inputData = json['input_data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['input_name'] = inputName;
    data['input_data'] = inputData;
    return data;
  }
}
