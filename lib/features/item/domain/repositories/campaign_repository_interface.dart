import 'package:Oxygen_Mart/common/enums/data_source_enum.dart';
import 'package:Oxygen_Mart/interfaces/repository_interface.dart';

abstract class CampaignRepositoryInterface implements RepositoryInterface {
  @override
  Future getList(
      {int? offset,
      bool isBasicCampaign = false,
      bool isItemCampaign = false,
      DataSourceEnum source});
}
