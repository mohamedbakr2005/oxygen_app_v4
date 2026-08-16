import 'dart:convert';
import 'dart:io';

void main() {
  var langs = ['en', 'ar', 'es', 'bn'];
  for (var lang in langs) {
    var newFile = File('E:/1/oxygen_app_new/assets/language/${lang}.json');
    var v4File = File('E:/1/oxygen_app_v4/assets/language/${lang}.json');
    if (!newFile.existsSync() || !v4File.existsSync()) continue;
    
    var newJson = jsonDecode(newFile.readAsStringSync());
    var v4Json = jsonDecode(v4File.readAsStringSync());
    
    newJson.forEach((k, v) {
      if (!v4Json.containsKey(k)) {
        v4Json[k] = v;
      }
    });
    
    // Write back pretty json
    var encoder = JsonEncoder.withIndent('  ');
    v4File.writeAsStringSync(encoder.convert(v4Json));
    print('Merged ${lang}');
  }
}
