import 'package:flutter/material.dart';
import 'package:hms_site_kit_search/models/coordinate.dart';
import 'package:hms_site_kit_search/models/nearby_place_search_request.dart';
import 'package:hms_site_kit_search/models/nearby_place_search_response.dart';
import 'package:hms_site_kit_search/models/site.dart';
import 'package:hms_site_kit_search/widgets/custom_card.dart';
import '../util.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NearbySearchScreen extends StatefulWidget {
  static const String id = 'nearby_search_screen';

  @override
  _NearbySearchScreenState createState() => _NearbySearchScreenState();
}

class _NearbySearchScreenState extends State<NearbySearchScreen> {
  List<Site> sites = [];

  final TextEditingController queryTextController =
      TextEditingController(text: "Eiffel Tower");
  final TextEditingController languageTextController =
      TextEditingController(text: "en");
  final TextEditingController latTextController =
      TextEditingController(text: "48.893478");
  final TextEditingController lngTextController =
      TextEditingController(text: "2.334595");
  final TextEditingController radiusTextController =
      TextEditingController(text: "5000");
  final TextEditingController pageIndexTextController =
      TextEditingController(text: "1");
  final TextEditingController pageSizeTextController =
      TextEditingController(text: "20");
  final TextEditingController hwPoiTypeTextController =
      TextEditingController(text: "HOTEL");

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    lngTextController.dispose();
    latTextController.dispose();
    super.dispose();
  }
  void runSearch() async {
    NearbyPlaceRequest request = NearbyPlaceRequest(
      Coordinate(
        lat: double.parse(latTextController.text),
        lng: double.parse(lngTextController.text),
      ),
    );
    request.query = queryTextController.text.toString();
    request.location = Coordinate(
      lat: double.parse(latTextController.text),
      lng: double.parse(lngTextController.text),
    );
    request.hwPoiType = hwPoiTypeTextController.text;
    request.language = languageTextController.text;
    request.pageIndex = int.parse(pageIndexTextController.text);
    request.pageSize = int.parse(pageSizeTextController.text);
    request.radius = int.parse(radiusTextController.text);

    String url =
        'https://siteapi.cloud.huawei.com/mapApi/v1/siteService/nearbySearch?key=';
    print(json.encode(request.toJson()));
    var res = await http.post(url + API_KEY,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: json.encode(request.toJson()));
    NearbyPlaceResponse response = NearbyPlaceResponse.fromJson(json.decode(utf8.decode(res.bodyBytes)));
    setState(() {
      sites = response.sites;
      sites.sort((a, b) => a.distance.compareTo(b.distance));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black26,
        title: const Text('Nearby Search'),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          CustomText(
            labelText: "Query Text",
            controller: queryTextController,
          ),
          CustomText(
            labelText: "Language",
            controller: languageTextController,
          ),
          CustomText(
            labelText: "Latitude",
            controller: latTextController,
          ),
          CustomText(
            labelText: "Longitude",
            controller: lngTextController,
          ),
          CustomText(
            labelText: "Radius",
            controller: radiusTextController,
          ),
          CustomText(
            labelText: "PageIndex",
            controller: pageIndexTextController,
          ),
          CustomText(
            labelText: "PageSize",
            controller: pageSizeTextController,
          ),
          CustomText(
            labelText: "hwPoiType",
            controller: hwPoiTypeTextController,
          ),
          CustomButton(
            text: "Search",
            onPressed: () {
              runSearch();
            },
          ),
          sites.length == 0
              ? Text('No results')
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: sites.length,
                  itemBuilder: (context, index) {
                    return CustomCard(sites[index].siteId,sites[index].name,
                      sites[index].formatAddress,sites[index].address.countryCode,
                      sites[index].location.toString(),sites[index].viewport.toString(),
                      sites[index].distance.toString(),sites[index].poi.toString(),
                      index,);
                  },
                ),
        ]),
      ),
    );
  }
}
