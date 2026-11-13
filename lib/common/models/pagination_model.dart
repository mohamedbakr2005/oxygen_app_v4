import 'package:Oxygen_Mart/api/response_parser.dart';

class PaginationModel {
  final int? totalSize;
  final int? limit;
  final int? offset;
  final int? lastPage;

  const PaginationModel({this.totalSize, this.limit, this.offset, this.lastPage});

  factory PaginationModel.fromJson(Map<String, dynamic> rawJson) {
    final dynamic payload = ResponseParser.payloadOf(rawJson);
    final Map<String, dynamic> json = payload is Map ? Map<String, dynamic>.from(payload) : rawJson;
    final dynamic pagination = json['pagination'];
    if (pagination is Map) {
      return PaginationModel(
        totalSize: _toInt(pagination['total']),
        limit: _toInt(pagination['per_page']),
        offset: _toInt(pagination['current_page']),
        lastPage: _toInt(pagination['last_page']),
      );
    }
    return PaginationModel(
      totalSize: _toInt(json['total_size']),
      limit: _toInt(json['limit']),
      offset: _toInt(json['offset']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'total_size': totalSize,
    'limit': limit,
    'offset': offset,
  };

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
