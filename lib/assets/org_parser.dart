import 'dart:convert';

import 'package:flutter/services.dart';

class Organizations {
  String keyword;
  int id;
  String autocompleteterm;
  String country;

  Organizations({
    this.keyword = "",
    this.id = 0,
    this.autocompleteterm = "",
    this.country = ""
  });

  factory Organizations.fromJson(Map<String, dynamic> parsedJson) {
    return Organizations(
        keyword: parsedJson['keyword'] as String,
        id: parsedJson['id'],
        autocompleteterm: parsedJson['autocompleteTerm'] as String,
        country: parsedJson['country'] as String
    );
  }
}


class OrgsViewModel {
  //static List<Organizations> organizations =  List<Organizations>.filled();
  
  static List<Organizations> orgs = [];

  static Future loadOrganizations() async {
    try {
      orgs = <Organizations>[];
      String jsonString = await rootBundle.loadString('lib/assets/organizations.json'); //
      Map parsedJson = json.decode(jsonString);
      var categoryJson = parsedJson['players'] as List;
      for (int i = 0; i < categoryJson.length; i++) {
        orgs.add(Organizations.fromJson(categoryJson[i]));
        print(orgs);
      }
    } catch (e) {
      print(e);
    }
  }
}