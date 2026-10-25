class VerificationDataModel {
  String? phone;
  String? email;
  String? verificationType;
  String? otp;
  String? loginType;
  String? guestId;
  String? name;
  String? orderId;

  VerificationDataModel({
    this.phone,
    this.email,
    this.verificationType,
    this.otp,
    this.loginType,
    this.guestId,
    this.name,
    this.orderId,
  });

  VerificationDataModel.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    email = json['email'];
    verificationType = json['verification_type'];
    otp = json['otp'];
    loginType = json['login_type'];
    guestId = json['guest_id'];
    name = json['name'];
    orderId = json['order_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (phone != null) {
      data['phone'] = phone;
    }
    if (email != null) {
      data['email'] = email;
    }
    data['verification_type'] = verificationType;
    data['otp'] = otp;
    data['login_type'] = loginType;
    if (guestId != null) {
      data['guest_id'] = guestId;
    }
    if (name != null) {
      data['name'] = name;
    }
    if (orderId != null) {
      data['order_id'] = orderId;
    }
    return data;
  }
}
