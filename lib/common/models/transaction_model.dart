import 'package:Oxygen_Mart/api/response_parser.dart';
import 'package:Oxygen_Mart/common/models/pagination_model.dart';

class TransactionModel {
  int? totalSize;
  String? limit;
  String? offset;
  List<Transaction>? data;

  TransactionModel({this.totalSize, this.limit, this.offset, this.data});

  TransactionModel.fromJson(Map<String, dynamic> json) {
    final PaginationModel pagination = PaginationModel.fromJson(json);
    totalSize = pagination.totalSize;
    limit = pagination.limit?.toString();
    offset = pagination.offset?.toString();
    final List<dynamic>? entries = ResponseParser.listOf(json);
    if (entries != null) {
      data = [];
      for (final dynamic v in entries) {
        data!.add(Transaction.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Transaction {
  int? userId;
  String? transactionId;
  double? credit;
  double? debit;
  double? adminBonus;
  double? balance;
  String? transactionType;
  String? reference;
  DateTime? createdAt;
  DateTime? updatedAt;

  Transaction({
    this.userId,
    this.transactionId,
    this.credit,
    this.debit,
    this.adminBonus,
    this.balance,
    this.transactionType,
    this.reference,
    this.createdAt,
    this.updatedAt,
  });

  Transaction.fromJson(Map<String, dynamic> json) {
    userId = json["user_id"];
    transactionId = json["transaction_id"];
    credit = json["credit"].toDouble();
    debit = json["debit"].toDouble();
    if (json["admin_bonus"] != null) {
      adminBonus = json["admin_bonus"].toDouble();
    }
    balance = json["balance"].toDouble();
    transactionType = json["transaction_type"];
    reference = json["reference"];
    createdAt = DateTime.parse(json["created_at"]);
    updatedAt = DateTime.parse(json["updated_at"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["user_id"] = userId;
    data["transaction_id"] = transactionId;
    data["credit"] = credit;
    data["debit"] = debit;
    data["admin_bonus"] = adminBonus;
    data["balance"] = balance;
    data["transaction_type"] = transactionType;
    data["reference"] = reference;
    data["created_at"] = createdAt!.toIso8601String();
    data["updated_at"] = updatedAt!.toIso8601String();
    return data;
  }
}
