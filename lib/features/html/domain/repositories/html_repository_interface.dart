import 'package:Oxygen_Mart/interfaces/repository_interface.dart';
import 'package:Oxygen_Mart/util/html_type.dart';

abstract class HtmlRepositoryInterface extends RepositoryInterface {
  Future<dynamic> getHtmlText(HtmlType htmlType);
}
