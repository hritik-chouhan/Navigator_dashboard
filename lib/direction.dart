import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_search_flutter/mapbox_search_flutter.dart';
import 'package:navigator2/Showroute.dart';
import 'package:navigator2/provider.dart';
import 'package:navigator2/response.dart';
import 'package:http/http.dart' as http;

import 'location.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


class Direction extends ConsumerWidget {
  Direction({Key? key}) : super(key: key);
  TextEditingController _startPointController = TextEditingController();
  TextEditingController _destinationPointController = TextEditingController();


  @override
  Widget build(BuildContext context,ref) {
    _startPointController.text = ref.watch(CurrentAdressProvider);
    _destinationPointController.text = ref.watch(DestinationAdressProvider);
    return Scaffold(
      key: _scaffoldKey,
      body: Card(

        elevation: 5,
        // width: MediaQuery.of(context).size.width,
        // height: MediaQuery.of(context).size.height*0.1,
        child: Column(
          children: [
            Flexible(
              child: TextFormField(
                controller: _startPointController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.my_location),
                  hintText: "Choose your current location",
                  suffixIcon: IconButton(
                      onPressed: () async {
                        var currpos = await determinePosition();
                        LatLng value = LatLng(currpos.latitude, currpos.longitude);
                        await ref.read(currlnglatProvider.notifier).update(value);
                        ref.read(CurrentAdressProvider.notifier).update('Current Position');
                      },
                      icon: const Icon(Icons.my_location),
                  ),

                ),

                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchPage(iscurrent: true),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 30,),
            Flexible(
              child: TextFormField(
                controller: _destinationPointController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.location_pin),
                  hintText: "Choose your destination",

                ),

                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchPage(iscurrent: false),
                    ),
                  );
                },
              ),
            ),

          ],

        ),





      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async{
            LatLng current = ref.read(currlnglatProvider);
            LatLng destination = ref.read(destinationlnglatProvider);
            Map RouteResponse = await getDirectionsAPIResponse(current,destination);
            print(RouteResponse);

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        showRoute(RouteResponse: RouteResponse,currlatlng: current,ref: ref)));
            // _addSourceAndLineLayer(RouteResponse['geometry'], true);
          },
          label: const Text('Show Route'),
          icon: const Icon(Icons.drive_eta_rounded),
      ),
    );
  }
}


class SearchPage extends ConsumerWidget {
  bool iscurrent;
  SearchPage({Key? key, required this.iscurrent}) : super(key: key);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context , ref) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.done),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        bottom: false,
        child: MapBoxPlaceSearchWidget(
          popOnSelect: false,
          apiKey: 'pk.eyJ1IjoiaHJpdGlrMzk2MSIsImEiOiJjbDRpZjJoZmEwbmt2M2JwOTR0ZmxqamVpIn0.j7hMYKw95zKarr69MMtfcA',
          searchHint: 'Search around your place',
          onSelected: (place) async{
            var url = 'https://api.mapbox.com/geocoding/v5/mapbox.places/${place.placeName}.json?proximity=ip&types=place%2Cpostcode%2Caddress&access_token=pk.eyJ1IjoiaHJpdGlrMzk2MSIsImEiOiJjbDRpZjJoZmEwbmt2M2JwOTR0ZmxqamVpIn0.j7hMYKw95zKarr69MMtfcA';
            http.Response response = await http.get(Uri.parse(url));
            Map data = json.decode(response.body);
            double longi = data['features'][0]['center'][0];
            double lati = data['features'][0]['center'][1];
            if(iscurrent){
              LatLng value = LatLng(lati,longi);
              ref.read(currlnglatProvider.notifier).update(value);
              ref.read(CurrentAdressProvider.notifier).update(place.placeName);

            }
            else{
              LatLng value = LatLng(lati,longi);
              ref.read(destinationlnglatProvider.notifier).update(value);
              ref.read(DestinationAdressProvider.notifier).update(place.placeName);
              LatLng distiloc = ref.read(destinationlnglatProvider);
              print(distiloc);
            }

            // print(longi);
            // print(lati);

          },
          context: context,
        ),
      ),
    );
  }
}




