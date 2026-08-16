import 'package:Oxygen_Mart/common/enums/data_source_enum.dart';
import 'package:Oxygen_Mart/features/home/domain/models/advertisement_model.dart';

abstract class AdvertisementServiceInterface {
  Future<List<AdvertisementModel>?> getAdvertisementList(DataSourceEnum source);
}
