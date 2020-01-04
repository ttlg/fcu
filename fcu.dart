import 'dart:convert';
import "dart:io";
import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import "package:http/http.dart" as http;
import 'package:http/http.dart';
import "package:yaml/yaml.dart";
Future<String> getNewestVersion(String package) async {
  Response html = await http.get('https://pub.dev/packages/' + package);
  Document document = parser.parse(html.body);
  final jsonScript =
      document.querySelector('script[type="application/ld+json"]');
  final json = jsonDecode(jsonScript.innerHtml);
  return json['version'].toString();
}
void main() async {
  File file = new File('pubspec.yaml');
  if (!(await file.exists())) {
    print('\'pubspec.yaml\' does not exist');
    return;
  }
  String yamlString = file.readAsStringSync();
  Map yaml = loadYaml(yamlString);
  YamlMap dependencies = yaml['dependencies'];
  for (final packageName
      in dependencies.keys.where((key) => dependencies[key] is String)) {
    final currentVersion = dependencies[packageName].replaceFirst('^', '');
    print(packageName + ': ' + currentVersion);
    final newestVersion = await getNewestVersion(packageName);
    if (newestVersion.compareTo(currentVersion) > 0) {
      print(' => ' + newestVersion);
    }
  }
}


