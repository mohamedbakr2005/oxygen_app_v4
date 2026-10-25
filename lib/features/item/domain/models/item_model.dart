import 'dart:convert';
import 'package:Oxygen_Mart/features/item/domain/models/basic_medicine_model.dart';

class ItemModel {
  int? totalSize;
  String? limit;
  int? offset;
  List<Item>? items;
  List<Categories>? categories;

  ItemModel(
      {this.totalSize, this.limit, this.offset, this.items, this.categories});

  ItemModel.fromJson(dynamic json) {
    if (json == null) return;
    if (json is List) {
      items = [];
      for (var v in json) {
        try {
          if (v != null) items!.add(Item.fromJson(v));
        } catch (_) {}
      }
      totalSize = items!.length;
      return;
    }
    if (json is Map) {
      totalSize = int.tryParse(json['total_size']?.toString() ?? '') ?? (json['total_size'] as int?);
      limit = json['limit']?.toString();
      offset = int.tryParse(json['offset']?.toString() ?? '');
      items = [];

      dynamic rawProducts = json['products'] ?? json['items'];
      if (rawProducts is String) {
        try { rawProducts = jsonDecode(rawProducts); } catch (_) {}
      }
      if (rawProducts is List) {
        for (var v in rawProducts) {
          try {
            if (v != null) items!.add(Item.fromJson(v));
          } catch (_) {}
        }
      }

      if (json['categories'] != null) {
        categories = <Categories>[];
        dynamic rawCategories = json['categories'];
        if (rawCategories is String) {
          try { rawCategories = jsonDecode(rawCategories); } catch (_) {}
        }
        if (rawCategories is List) {
          for (var v in rawCategories) {
            try {
              if (v != null) categories!.add(Categories.fromJson(v));
            } catch (_) {}
          }
        }
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
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Item {
  int? id;
  String? name;
  String? description;
  String? imageFullUrl;
  List<String>? imagesFullUrl;
    String? video;
  String? videoLink;
  String? videoFullUrl;
  String? videoSourceType;
  String? videoPreviewType;
  String? videoPreviewUrl;
  String? videoThumbnailUrl;
  String? videoEmbedUrl;
  String? videoPreviewModalType;
  String? videoPreviewModalUrl;
  bool? hasVideoPreview;
  bool? hasVideoSource;
  String? storeImageFullUrl;
  String? storeLogoFullUrl;
  String? offerLabel;
  int? verifiedSeller;
  StoreDetails? storeDetails;
  String? brandName;
  bool? freeDelivery;
  String? slug;

  int? categoryId;
  List<CategoryIds>? categoryIds;
  List<Variation>? variations;
  List<FoodVariation>? foodVariations;
  List<AddOns>? addOns;
  List<ChoiceOptions>? choiceOptions;
  double? price;
  double? tax;
  double? discount;
  String? discountType;
  String? availableTimeStarts;
  String? availableTimeEnds;
  int? storeId;
  String? storeName;
  int? zoneId;
  double? storeDiscount;
  bool? scheduleOrder;
  double? avgRating;
  int? ratingCount;
  int? veg;
  int? moduleId;
  String? moduleType;
  String? unitType;
  int? stock;
  String? availableDateStarts;
  int? organic;
  int? quantityLimit;
  int? flashSale;
  bool? isStoreHalalActive;
  bool? isHalalItem;
  bool? isPrescriptionRequired;
  List<String>? nutritionsName;
  List<String>? allergiesName;
  List<String>? genericName;

  Item({
    this.id,
    this.name,
    this.description,
    this.imageFullUrl,
    this.imagesFullUrl,
          this.video,
      this.videoLink,
      this.videoFullUrl,
      this.videoSourceType,
      this.videoPreviewType,
      this.videoPreviewUrl,
      this.videoThumbnailUrl,
      this.videoEmbedUrl,
      this.videoPreviewModalType,
      this.videoPreviewModalUrl,
      this.hasVideoPreview,
      this.hasVideoSource,
      this.storeImageFullUrl,
      this.storeLogoFullUrl,
      this.offerLabel,
      this.verifiedSeller,
      this.storeDetails,
      this.brandName,
      this.freeDelivery,
      this.slug,
      this.categoryId,
    this.categoryIds,
    this.variations,
    this.foodVariations,
    this.addOns,
    this.choiceOptions,
    this.price,
    this.tax,
    this.discount,
    this.discountType,
    this.availableTimeStarts,
    this.availableTimeEnds,
    this.storeId,
    this.storeName,
    this.zoneId,
    this.storeDiscount,
    this.scheduleOrder,
    this.avgRating,
    this.ratingCount,
    this.veg,
    this.moduleId,
    this.moduleType,
    this.unitType,
    this.stock,
    this.organic,
    this.quantityLimit,
    this.flashSale,
    this.isStoreHalalActive,
    this.isHalalItem,
    this.isPrescriptionRequired,
    this.nutritionsName,
    this.allergiesName,
    this.genericName,
  });

  Item.fromJson(dynamic rawJson) {
    if (rawJson == null) return;
    final Map<String, dynamic> json = rawJson is Map ? Map<String, dynamic>.from(rawJson) : {};
    if (json.isEmpty) return;

    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    name = json['name']?.toString();
    description = json['description']?.toString();
    imageFullUrl = json['image_full_url']?.toString();
    if (json['images_full_url'] != null) {
      imagesFullUrl = [];
      dynamic rawImages = json['images_full_url'];
      if (rawImages is String) {
        try { rawImages = jsonDecode(rawImages); } catch (_) {}
      }
      if (rawImages is List) {
        for (var v in rawImages) {
          if (v != null) imagesFullUrl!.add(v.toString());
        }
      }
    }
    video = json['video']?.toString();
    videoLink = json['video_link']?.toString();
    videoFullUrl = json['video_full_url']?.toString();
    videoSourceType = json['video_source_type']?.toString();
    videoPreviewType = json['video_preview_type']?.toString();
    videoPreviewUrl = json['video_preview_url']?.toString();
    videoThumbnailUrl = json['video_thumbnail_url']?.toString();
    videoEmbedUrl = json['video_embed_url']?.toString();
    videoPreviewModalType = json['video_preview_modal_type']?.toString();
    videoPreviewModalUrl = json['video_preview_modal_url']?.toString();
    hasVideoPreview = json['has_video_preview'] == true || json['has_video_preview'] == 1 || json['has_video_preview'] == '1';
    hasVideoSource = json['has_video_source'] == true || json['has_video_source'] == 1 || json['has_video_source'] == '1';
    storeImageFullUrl = json['store_image_full_url']?.toString();
    storeLogoFullUrl = json['store_logo_full_url']?.toString();
    offerLabel = json['offer_label']?.toString();
    verifiedSeller = json['verified_seller'] != null ? int.tryParse(json['verified_seller'].toString()) : null;
    brandName = json['brand_name']?.toString();
    freeDelivery = json['free_delivery'] == 1 || json['free_delivery'] == true || json['free_delivery'] == '1';
    slug = json['slug']?.toString();
    storeDetails = json['store_details'] != null ? StoreDetails.fromJson(json['store_details']) : null;
    categoryId = json['category_id'] != null ? int.tryParse(json['category_id'].toString()) : null;

    if (json['category_ids'] != null) {
      categoryIds = [];
      dynamic rawCategories = json['category_ids'];
      if (rawCategories is String) {
        try {
          rawCategories = jsonDecode(rawCategories);
        } catch (_) {}
      }
      if (rawCategories is List) {
        for (var v in rawCategories) {
          try {
            if (v != null) categoryIds!.add(CategoryIds.fromJson(v));
          } catch (_) {}
        }
      }
    }

    variations = [];
    if (json['variations'] != null) {
      dynamic rawVar = json['variations'];
      if (rawVar is String) {
        try {
          rawVar = jsonDecode(rawVar);
        } catch (_) {}
      }
      if (rawVar is List) {
        for (var v in rawVar) {
          try {
            if (v != null) variations!.add(Variation.fromJson(v));
          } catch (_) {}
        }
      }
    }

    foodVariations = [];
    if (json['food_variations'] != null) {
      dynamic rawFoodVar = json['food_variations'];
      if (rawFoodVar is String) {
        try {
          rawFoodVar = jsonDecode(rawFoodVar);
        } catch (_) {}
      }
      if (rawFoodVar is List) {
        for (var v in rawFoodVar) {
          try {
            if (v != null) foodVariations!.add(FoodVariation.fromJson(v));
          } catch (_) {}
        }
      }
    }

    if (json['add_ons'] != null || json['addons'] != null) {
      addOns = [];
      dynamic rawAddOns = json['add_ons'] ?? json['addons'];
      if (rawAddOns is String) {
        try { rawAddOns = jsonDecode(rawAddOns); } catch (_) {}
      }
      if (rawAddOns is List) {
        for (var v in rawAddOns) {
          try {
            if (v != null) addOns!.add(AddOns.fromJson(v));
          } catch (_) {}
        }
      }
    }

    if (json['choice_options'] != null) {
      choiceOptions = [];
      dynamic rawChoice = json['choice_options'];
      if (rawChoice is String) {
        try { rawChoice = jsonDecode(rawChoice); } catch (_) {}
      }
      if (rawChoice is List) {
        for (var v in rawChoice) {
          try {
            if (v != null) choiceOptions!.add(ChoiceOptions.fromJson(v));
          } catch (_) {}
        }
      }
    }

    price = json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0;
    tax = json['tax'] != null ? double.tryParse(json['tax'].toString()) : 0.0;
    discount = json['discount'] != null ? double.tryParse(json['discount'].toString()) ?? 0.0 : 0.0;
    discountType = json['discount_type']?.toString();
    availableTimeStarts = json['available_time_starts']?.toString();
    availableTimeEnds = json['available_time_ends']?.toString();
    storeId = json['store_id'] != null ? int.tryParse(json['store_id'].toString()) : null;
    storeName = json['store_name']?.toString();
    zoneId = json['zone_id'] != null ? int.tryParse(json['zone_id'].toString()) : null;
    storeDiscount = json['store_discount'] != null ? double.tryParse(json['store_discount'].toString()) ?? 0.0 : 0.0;
    scheduleOrder = json['schedule_order'] == 1 || json['schedule_order'] == true || json['schedule_order'] == '1';
    avgRating = json['avg_rating'] != null ? double.tryParse(json['avg_rating'].toString()) ?? 0.0 : 0.0;
    ratingCount = json['rating_count'] != null ? int.tryParse(json['rating_count'].toString()) : null;
    moduleId = json['module_id'] != null ? int.tryParse(json['module_id'].toString()) : null;
    moduleType = json['module_type']?.toString();
    veg = json['veg'] != null ? int.tryParse(json['veg'].toString()) ?? 0 : 0;
    stock = json['stock'] != null ? int.tryParse(json['stock'].toString()) : null;
    unitType = json['unit_type']?.toString();
    availableDateStarts = json['available_date_starts']?.toString();
    organic = json['organic'] != null ? int.tryParse(json['organic'].toString()) : null;
    quantityLimit = json['maximum_cart_quantity'] != null ? int.tryParse(json['maximum_cart_quantity'].toString()) : null;
    flashSale = json['flash_sale'] != null ? int.tryParse(json['flash_sale'].toString()) : null;
    isStoreHalalActive = json['halal_tag_status'] == 1 || json['halal_tag_status'] == '1' || json['halal_tag_status'] == true;
    isHalalItem = json['is_halal'] == 1 || json['is_halal'] == '1' || json['is_halal'] == true;
    isPrescriptionRequired = json['is_prescription_required'] == 1 || json['is_prescription_required'] == '1' || json['is_prescription_required'] == true;

    if (json['nutritions_name'] != null) {
      nutritionsName = [];
      dynamic rawNut = json['nutritions_name'];
      if (rawNut is String) {
        try { rawNut = jsonDecode(rawNut); } catch (_) {}
      }
      if (rawNut is List) {
        for (var e in rawNut) {
          if (e != null && e.toString().trim().isNotEmpty) nutritionsName!.add(e.toString().trim());
        }
      }
    }

    if (json['allergies_name'] != null) {
      allergiesName = [];
      dynamic rawAll = json['allergies_name'];
      if (rawAll is String) {
        try { rawAll = jsonDecode(rawAll); } catch (_) {}
      }
      if (rawAll is List) {
        for (var e in rawAll) {
          if (e != null && e.toString().trim().isNotEmpty) allergiesName!.add(e.toString().trim());
        }
      }
    }

    if (json['generic_name'] != null) {
      genericName = [];
      dynamic rawGen = json['generic_name'];
      if (rawGen is String) {
        try { rawGen = jsonDecode(rawGen); } catch (_) {}
      }
      if (rawGen is List) {
        for (var e in rawGen) {
          if (e != null && e.toString().trim().isNotEmpty) genericName!.add(e.toString().trim());
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['image_full_url'] = imageFullUrl;
    data['images_full_url'] = imagesFullUrl;
    data['video'] = video;
    data['video_link'] = videoLink;
    data['video_full_url'] = videoFullUrl;
    data['video_source_type'] = videoSourceType;
    data['video_preview_type'] = videoPreviewType;
    data['video_preview_url'] = videoPreviewUrl;
    data['video_thumbnail_url'] = videoThumbnailUrl;
    data['video_embed_url'] = videoEmbedUrl;
    data['video_preview_modal_type'] = videoPreviewModalType;
    data['video_preview_modal_url'] = videoPreviewModalUrl;
    data['has_video_preview'] = hasVideoPreview;
    data['has_video_source'] = hasVideoSource;
    data['store_image_full_url'] = storeImageFullUrl;
    data['store_logo_full_url'] = storeLogoFullUrl;
    data['offer_label'] = offerLabel;
    data['verified_seller'] = verifiedSeller;
    data['brand_name'] = brandName;
    data['free_delivery'] = freeDelivery;
    data['slug'] = slug;
    if (storeDetails != null) {
      data['store_details'] = storeDetails!.toJson();
    }
    data['category_id'] = categoryId;
    if (categoryIds != null) {
      data['category_ids'] = categoryIds!.map((v) => v.toJson()).toList();
    }
    if (variations != null) {
      data['variations'] = variations!.map((v) => v.toJson()).toList();
    }
    if (foodVariations != null) {
      data['food_variations'] = foodVariations!.map((v) => v.toJson()).toList();
    }
    if (addOns != null) {
      data['add_ons'] = addOns!.map((v) => v.toJson()).toList();
    }
    if (choiceOptions != null) {
      data['choice_options'] = choiceOptions!.map((v) => v.toJson()).toList();
    }
    data['price'] = price;
    data['tax'] = tax;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['available_time_starts'] = availableTimeStarts;
    data['available_time_ends'] = availableTimeEnds;
    data['store_id'] = storeId;
    data['store_name'] = storeName;
    data['zone_id'] = zoneId;
    data['store_discount'] = storeDiscount;
    data['schedule_order'] = scheduleOrder;
    data['avg_rating'] = avgRating;
    data['rating_count'] = ratingCount;
    data['veg'] = veg;
    data['module_id'] = moduleId;
    data['module_type'] = moduleType;
    data['stock'] = stock;
    data['unit_type'] = unitType;
    data['available_date_starts'] = availableDateStarts;
    data['organic'] = organic;
    data['maximum_cart_quantity'] = quantityLimit;
    data['flash_sale'] = flashSale;
    data['halal_tag_status'] = isStoreHalalActive;
    data['is_halal'] = isHalalItem;
    data['is_prescription_required'] = isPrescriptionRequired;
    data['nutritions_name'] = nutritionsName;
    data['allergies_name'] = allergiesName;
    data['generic_name'] = genericName;
    return data;
  }
}

class CategoryIds {
  int? id;
  int? position;

  CategoryIds({this.id, this.position});

  CategoryIds.fromJson(dynamic json) {
    if (json is Map) {
      id = int.tryParse(json['id']?.toString() ?? '') ?? 0;
      position = int.tryParse(json['position']?.toString() ?? '') ?? 0;
    } else if (json != null) {
      id = int.tryParse(json.toString()) ?? 0;
      position = 1;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['position'] = position;
    return data;
  }
}

class Variation {
  String? type;
  double? price;
  int? stock;

  Variation({this.type, this.price, this.stock});

  Variation.fromJson(dynamic rawJson) {
    if (rawJson == null) return;
    final Map<String, dynamic> json = rawJson is Map ? Map<String, dynamic>.from(rawJson) : {};
    type = json['type']?.toString();
    price = json['price'] != null ? double.tryParse(json['price'].toString()) : null;
    stock = json['stock'] != null ? int.tryParse(json['stock'].toString()) ?? 0 : 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['price'] = price;
    data['stock'] = stock;
    return data;
  }
}

class AddOns {
  int? id;
  String? name;
  double? price;

  AddOns({
    this.id,
    this.name,
    this.price,
  });

  AddOns.fromJson(dynamic rawJson) {
    if (rawJson == null) return;
    final Map<String, dynamic> json = rawJson is Map ? Map<String, dynamic>.from(rawJson) : {};
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    name = json['name']?.toString();
    price = json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    return data;
  }
}

class ChoiceOptions {
  String? name;
  String? title;
  List<String>? options;

  ChoiceOptions({this.name, this.title, this.options});

  ChoiceOptions.fromJson(dynamic rawJson) {
    if (rawJson == null) return;
    final Map<String, dynamic> json = rawJson is Map ? Map<String, dynamic>.from(rawJson) : {};
    name = json['name']?.toString();
    title = json['title']?.toString();
    if (json['options'] != null) {
      dynamic rawOpt = json['options'];
      if (rawOpt is String) {
        try { rawOpt = jsonDecode(rawOpt); } catch (_) {}
      }
      if (rawOpt is List) {
        options = rawOpt.map((e) => e.toString()).toList();
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['title'] = title;
    data['options'] = options;
    return data;
  }
}

class FoodVariation {
  String? name;
  bool? multiSelect;
  int? min;
  int? max;
  bool? required;
  List<VariationValue>? variationValues;

  FoodVariation(
      {this.name,
      this.multiSelect,
      this.min,
      this.max,
      this.required,
      this.variationValues});

  FoodVariation.fromJson(dynamic rawJson) {
    if (rawJson == null) return;
    final Map<String, dynamic> json = rawJson is Map ? Map<String, dynamic>.from(rawJson) : {};
    if (json['max'] != null || json['name'] != null) {
      name = json['name']?.toString();
      multiSelect = json['type'] == 'multi';
      min = multiSelect == true ? int.tryParse(json['min']?.toString() ?? '') ?? 0 : 0;
      max = multiSelect == true ? int.tryParse(json['max']?.toString() ?? '') ?? 0 : 0;
      required = json['required'] == 'on' || json['required'] == true || json['required'] == 1 || json['required'] == '1';
      if (json['values'] != null) {
        variationValues = [];
        dynamic rawVals = json['values'];
        if (rawVals is String) {
          try { rawVals = jsonDecode(rawVals); } catch (_) {}
        }
        if (rawVals is List) {
          for (var v in rawVals) {
            try {
              if (v != null) variationValues!.add(VariationValue.fromJson(v));
            } catch (_) {}
          }
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = multiSelect;
    data['min'] = min;
    data['max'] = max;
    data['required'] = required;
    if (variationValues != null) {
      data['values'] = variationValues!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VariationValue {
  String? level;
  double? optionPrice;
  bool? isSelected;

  VariationValue({this.level, this.optionPrice, this.isSelected});

  VariationValue.fromJson(dynamic rawJson) {
    if (rawJson == null) return;
    final Map<String, dynamic> json = rawJson is Map ? Map<String, dynamic>.from(rawJson) : {};
    level = json['label']?.toString();
    optionPrice = json['optionPrice'] != null ? double.tryParse(json['optionPrice'].toString()) ?? 0.0 : 0.0;
    isSelected = json['isSelected'] == true || json['isSelected'] == 'true' || json['isSelected'] == 1;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = level;
    data['optionPrice'] = optionPrice;
    data['isSelected'] = isSelected;
    return data;
  }
}

class StoreDetails {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? slug;
  int? zoneId;
  bool? showLowStockCount;
  int? minimumStockForWarning;

  StoreDetails({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.slug,
    this.zoneId,
    this.showLowStockCount,
    this.minimumStockForWarning,
  });

  StoreDetails.fromJson(dynamic rawJson) {
    if (rawJson == null) return;
    final Map<String, dynamic> json = rawJson is Map ? Map<String, dynamic>.from(rawJson) : {};
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    name = json['name']?.toString();
    phone = json['phone']?.toString();
    email = json['email']?.toString();
    slug = json['slug']?.toString();
    zoneId = json['zone_id'] != null ? int.tryParse(json['zone_id'].toString()) : null;
    showLowStockCount = (json['show_low_stock_count'] == 1 || json['show_low_stock_count'] == true || json['show_low_stock_count'] == '1');
    minimumStockForWarning = json['minimum_stock_for_warning'] != null ? int.tryParse(json['minimum_stock_for_warning'].toString()) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    data['slug'] = slug;
    data['zone_id'] = zoneId;
    data['show_low_stock_count'] = showLowStockCount;
    data['minimum_stock_for_warning'] = minimumStockForWarning;
    return data;
  }
}


