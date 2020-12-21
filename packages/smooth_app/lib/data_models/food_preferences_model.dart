import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:smooth_app/database/user_database.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:http/http.dart' as http;

import 'dart:developer';

/* preferences JSON sample:

https://world.openfoodfacts.org/api/v0/preferences

[
{
id: "not_important",
name: "Not important"
},
{
id: "important",
name: "Important"
},
{
id: "very_important",
name: "Very important"
},
{
id: "mandatory",
name: "Mandatory"
}
]

*/

Future<List<Preference>> fetchPreferences(http.Client client) async {
  final response =
  await client.get('https://world.openfoodfacts.org/api/v0/preferences');

  final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();

  return parsed.map<Preference>((json) => Preference.fromJson(json)).toList();
}

class Preference {
  final String id;
  final String name;

  Preference({this.id, this.name});

  factory Preference.fromJson(Map<String, dynamic> json) {

    log("Preference factory", error: json);

    return Preference(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}


/* attribute_groups JSON sample:

[
{
name: "Food processing",
id: "processing",
attributes: [
{
id: "nova",
default: "important",
icon_url: "https://static.openfoodfacts.org/images/misc/nova-group-1.svg",
name: "NOVA group",
setting_name: "No or little food processing (NOVA group)"
},
{
setting_name: "No or few additives",
name: "Additives",
icon_url: "https://static.openfoodfacts.org/images/icons/0-additives.svg",
id: "additives"
}
]
},
..
]

*/

class Attribute {
  final String id;
  final String name;
  final String default_value;
  final String icon_url;
  final String setting_name;

  Attribute({this.id, this.name, this.default_value, this.icon_url, this.setting_name});

  factory Attribute.fromJson(Map<String, dynamic> json) {

    log("Attribute factory", error: json);

    return new Attribute(
      id: json['id'] as String,
      name: json['name'] as String,
      default_value: json['default'] as String,
      icon_url: json['icon_url'] as String,
      setting_name: json['setting_name'] as String,
    );
  }
}

class AttributeGroup {
  final String id;
  final String name;
  final List<Attribute> attributes;

  AttributeGroup({this.id, this.name, this.attributes});

  factory AttributeGroup.fromJson(Map<String, dynamic> json) {

    log("AttributeGroup factory");

    var attributesList = json['attributes'] as List;

    List<Attribute> attributes = new List<Attribute>();
    attributes = attributesList.map((i)=>Attribute.fromJson(i)).toList();

    return new AttributeGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      attributes: attributes,
    );
  }
}

class AttributeGroups {
  // ignore: non_constant_identifier_names
  final List<AttributeGroup> attribute_groups;

  AttributeGroups({
    this.attribute_groups,
  });

  factory AttributeGroups.fromJson(List<dynamic> json) {

    log("AttributeGroups factory");

    List<AttributeGroup> attribute_groups = new List<AttributeGroup>();
    attribute_groups = json.map((i)=>AttributeGroup.fromJson(i)).toList();

    return new AttributeGroups(
      attribute_groups: attribute_groups,
    );
  }
}

Future<AttributeGroups> fetchAttributeGroups(http.Client client) async {
  final response =
  await client.get('https://world.openfoodfacts.org/api/v0/attribute_groups');

  final json = jsonDecode(response.body).cast<Map<String, dynamic>>();

  return(AttributeGroups.fromJson(json));
}

class FoodPreferencesModel extends ChangeNotifier {
  FoodPreferencesModel() {
    userDatabase = UserDatabase();
    _loadData();
  }

  Future<bool> _loadData() async {
    try {
      preferences = await fetchPreferences(http.Client());
      userPreferences = await userDatabase.getUserPreferences();
      attributeGroups = await fetchAttributeGroups(http.Client());
      dataLoaded = true;
      notifyListeners();
      return true;
    } catch (e) {
      print('An error occurred while loading user preferences : $e');
      dataLoaded = false;
      return false;
    }
  }

  List<Preference> preferences;
  UserDatabase userDatabase;
  UserPreferences userPreferences;
  bool dataLoaded = false;
  AttributeGroups attributeGroups;

  UserPreferencesVariableValue getVariable(UserPreferencesVariable variable) {
    return userPreferences.getVariable(variable);
  }

  void setVariable(UserPreferencesVariable variable, int value) {
    if (dataLoaded) {
      userPreferences.setVariable(
          variable, UserPreferencesVariableValueExtention.fromInt(value));
      notifyListeners();
    }
  }

  void saveUserPreferences() {
    userDatabase.saveUserPreferences(userPreferences);
  }
}
