import 'package:Oxygen_Mart/common/enums/data_source_enum.dart';
import 'package:Oxygen_Mart/interfaces/repository_interface.dart';

abstract class BannerRepositoryInterface implements RepositoryInterface {
  @override
  Future getList(
      {int? offset,
      bool isBanner = false,
      bool isTaxiBanner = false,
      bool isFeaturedBanner = false,
      bool isParcelOtherBanner = false,
      bool isPromotionalBanner = false,
      DataSourceEnum? source});
}
