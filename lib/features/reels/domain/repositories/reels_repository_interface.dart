import 'package:Oxygen_Mart/common/enums/data_source_enum.dart';
import 'package:Oxygen_Mart/common/models/response_model.dart';
import 'package:Oxygen_Mart/features/reels/domain/models/reel_model.dart';
import 'package:Oxygen_Mart/interfaces/repository_interface.dart';

abstract class ReelsRepositoryInterface extends RepositoryInterface {
  @override
  Future<ReelListModel?> getList({int? offset, int? limit, DataSourceEnum source = DataSourceEnum.local});

  Future<ReelStatsModel?> getReelStats(int reelId);

  Future<ReelLikeResponseModel> toggleReelLike(int reelId);

  Future<bool> visitReel(int reelId);
}

class ReelLikeResponseModel {
  final ResponseModel response;
  final bool? isLiked;
  final int? totalLikes;

  ReelLikeResponseModel({required this.response, this.isLiked, this.totalLikes});
}
