import 'package:actual/common/const/data.dart';

class DataUtils {
  static String pathToUrl(String value) {
    return 'http://$realIp$value';
  }

  static List<String> listPathsToUrl(List paths) {
    return paths.map((e) => pathToUrl(e)).toList();
  }
}