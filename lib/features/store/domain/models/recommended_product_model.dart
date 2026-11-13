import 'dart:convert';
import 'package:Oxygen_Mart/api/response_parser.dart';
import 'package:Oxygen_Mart/common/models/pagination_model.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';

RecommendedItemModel recommendedItemModelFromRawJson(String rawJson) =>
    RecommendedItemModel.fromJson(
      ResponseParser.payloadOf(jsonDecode(rawJson)) as Map<String, dynamic>,
    );

class RecommendedItemModel {
  int? totalSize;
  String? limit;
  String? offset;
  List<Item>? items;

  RecommendedItemModel({this.totalSize, this.limit, this.offset, this.items});

  RecommendedItemModel.fromJson(Map<String, dynamic> json) {
    final PaginationModel _pg = PaginationModel.fromJson(json);
    totalSize = _pg.totalSize;
    limit = _pg.limit?.toString();
    offset = _pg.offset?.toString();
    final List<dynamic>? entries = ResponseParser.listOf(json, legacyKey: 'items');
    if (entries != null) {
      items = <Item>[];
      for (final dynamic v in entries) {
        items!.add(Item.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (items != null) {
      data['products'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
