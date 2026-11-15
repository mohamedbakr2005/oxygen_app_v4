import 'dart:convert';
import 'package:Oxygen_Mart/features/location/domain/models/zone_response_model.dart';

class AddressModel {
  int? id;
  String? addressType;
  String? contactPersonNumber;
  String? address;
  String? additionalAddress;
  String? latitude;
  String? longitude;
  int? zoneId;
  int? rideZoneId;
  List<int>? zoneIds;
  String? method;
  String? contactPersonName;
  String? streetNumber;
  String? house;
  String? floor;
  List<ZoneData>? zoneData;
  List<int>? areaIds;
  String? email;

  AddressModel({
    this.id,
    this.addressType,
    this.contactPersonNumber,
    this.address,
    this.additionalAddress,
    this.latitude,
    this.longitude,
    this.zoneId,
    this.rideZoneId,
    this.zoneIds,
    this.method,
    this.contactPersonName,
    this.streetNumber,
    this.house,
    this.floor,
    this.zoneData,
    this.areaIds,
    this.email,
  });

  AddressModel copyWith({
    String? contactPersonName,
    String? contactPersonNumber,
  }) {
    return AddressModel(
      id: id,
      addressType: addressType,
      contactPersonNumber: contactPersonNumber ?? this.contactPersonNumber,
      address: address,
      additionalAddress: additionalAddress,
      latitude: latitude,
      longitude: longitude,
      zoneId: zoneId,
      rideZoneId: rideZoneId,
      zoneIds: zoneIds,
      method: method,
      contactPersonName: contactPersonName ?? this.contactPersonName,
      streetNumber: streetNumber,
      house: house,
      floor: floor,
      zoneData: zoneData,
      areaIds: areaIds,
      email: email,
    );
  }

  AddressModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    addressType = json['address_type'] == 'null' ? null : json['address_type'];
    contactPersonNumber = (json['contact_person_number'] != null && json['contact_person_number'].toString() != 'null')
        ? json['contact_person_number']?.toString()
        : null;
    address = json['address'] == 'null' ? null : json['address'];
    additionalAddress = json['additional_address'] == 'null' ? null : json['additional_address'];
    latitude = (json['latitude'] != null && json['latitude'].toString() != 'null') ? json['latitude']?.toString() : null;
    longitude = (json['longitude'] != null && json['longitude'].toString() != 'null') ? json['longitude']?.toString() : null;
    zoneId = (json['zone_id'] != null && json['zone_id'] != 'null')
        ? int.tryParse(json['zone_id'].toString())
        : null;
    rideZoneId = (json['ride_zone_id'] != null && json['ride_zone_id'] != 'null')
        ? int.tryParse(json['ride_zone_id'].toString())
        : null;
    if (json['zone_ids'] != null && json['zone_ids'] is List) {
      zoneIds = [];
      json['zone_ids'].forEach((id) {
        if (id != null) {
          int? parsed = int.tryParse(id.toString());
          if (parsed != null) zoneIds!.add(parsed);
        }
      });
    }
    method = json['_method'];
    contactPersonName = (json['contact_person_name'] != null && json['contact_person_name'].toString() != 'null')
        ? json['contact_person_name'].toString()
        : null;
    streetNumber = (json['road'] != null && json['road'].toString() != 'null') ? json['road'].toString() : null;
    house = (json['house'] != null && json['house'].toString() != 'null') ? json['house'].toString() : null;
    floor = (json['floor'] != null && json['floor'].toString() != 'null') ? json['floor'].toString() : null;
    if (json['zone_data'] != null) {
      zoneData = [];
      if (json['zone_data'] is List) {
        json['zone_data'].forEach((v) {
          if (v is Map<String, dynamic>) {
            zoneData!.add(ZoneData.fromJson(v));
          } else if (v is String) {
            try {
              zoneData!.add(ZoneData.fromJson(jsonDecode(v)));
            } catch (_) {}
          }
        });
      }
    }
    if (json['area_ids'] != null && json['area_ids'] is List) {
      areaIds = [];
      json['area_ids'].forEach((id) {
        if (id != null) {
          int? parsed = int.tryParse(id.toString());
          if (parsed != null) areaIds!.add(parsed);
        }
      });
    }
    if (json['contact_person_email'] != null && json['contact_person_email'].toString() != 'null') {
      email = json['contact_person_email'].toString();
    } else if (json['email'] != null && json['email'].toString() != 'null') {
      email = json['email'].toString();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['address_type'] = addressType;
    data['contact_person_number'] = contactPersonNumber;
    data['address'] = address;
    data['additional_address'] = additionalAddress;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['zone_id'] = zoneId;
    data['ride_zone_id'] = rideZoneId;
    data['zone_ids'] = zoneIds;
    data['_method'] = method;
    data['contact_person_name'] = contactPersonName;
    data['road'] = streetNumber;
    data['house'] = house;
    data['floor'] = floor;
    if (zoneData != null) {
      data['zone_data'] = zoneData!.map((v) => v.toJson()).toList();
    }
    data['area_ids'] = areaIds;
    if (email != null) {
      data['contact_person_email'] = email;
    }
    return data;
  }
}
