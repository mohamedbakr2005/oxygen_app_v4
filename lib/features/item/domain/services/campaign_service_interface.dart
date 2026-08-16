import 'package:Oxygen_Mart/common/enums/data_source_enum.dart';
import 'package:Oxygen_Mart/features/item/domain/models/basic_campaign_model.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';

abstract class CampaignServiceInterface {
  Future<List<BasicCampaignModel>?> getBasicCampaignList(DataSourceEnum source);
  Future<BasicCampaignModel?> getCampaignDetails(String campaignID);
  Future<List<Item>?> getItemCampaignList(DataSourceEnum dataSource);
}
