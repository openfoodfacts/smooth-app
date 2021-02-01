import 'dart:io';

import 'package:maybe_just_nothing/maybe_just_nothing.dart';
import 'package:yaml/yaml.dart';

class Config {
  Config(this._data);

  static Config readFile(File file) {
    if (!file.existsSync()) return Config(YamlMap());
    final yaml = loadYaml(file.readAsStringSync()) ?? YamlMap();
    if (yaml is YamlMap) return Config(yaml);
    throw 'Invalid config format';
  }

  final YamlMap _data;

  Maybe<String> get diffLinkTemplate => Maybe(_data['changelog'])
      .type<Map>()
      .map((_) => _['diff_link_template'])
      .type<String>();
}
