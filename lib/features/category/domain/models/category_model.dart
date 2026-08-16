
class CategoryModel {
  int? _id;
  String? _name;
  int? _parentId;
  int? _position;
  String? _createdAt;
  String? _updatedAt;
  String? _imageFullUrl;
  String? _slug;
  int? _moduleId;

  CategoryModel(
    {int? id,
    String? name,
    int? parentId,
    int? position,
    String? createdAt,
    String? updatedAt,
    String? imageFullUrl,
    String? slug,
    int? moduleId}) {
    _id = id;
    _name = name;
    _parentId = parentId;
    _position = position;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _imageFullUrl = imageFullUrl;
    _slug = slug;
    _moduleId = moduleId;
  }

  int? get id => _id;
  String? get name => _name;
  int? get parentId => _parentId;
  int? get position => _position;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get imageFullUrl => _imageFullUrl;
  String? get slug => _slug;
  int? get moduleId => _moduleId;

  CategoryModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _parentId = json['parent_id'];
    _position = json['position'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _imageFullUrl = json['image_full_url'];
    _slug = json['slug'];
    _moduleId = json['module_id'] is String ? int.tryParse(json['module_id']) : json['module_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['name'] = _name;
    data['parent_id'] = _parentId;
    data['position'] = _position;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['image_full_url'] = _imageFullUrl;
    data['slug'] = _slug;
    data['module_id'] = _moduleId;

    return data;
  }
}
