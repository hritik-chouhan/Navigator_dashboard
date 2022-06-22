import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_api/mapbox_api.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
// import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_search_flutter/mapbox_search_flutter.dart';
import 'package:navigator2/TurnNavigation.dart';
import 'package:navigator2/direction.dart';
import 'package:navigator2/location.dart';
import 'package:navigator2/provider.dart';
import 'package:navigator2/response.dart';
import 'dart:convert';
import 'location.dart';
import 'package:http/http.dart' as http;
// import 'package:latlong2/latlong.dart';
import 'provider.dart';
import 'package:geolocator/geolocator.dart';


final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


class HomeNavigation extends ConsumerWidget {
  HomeNavigation({Key? key}) : super(key: key);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    TextEditingController _startPointController = TextEditingController();

  // Future<dynamic> _acquireCurrentPosition() async {
  //   Position position = await determinePosition();
  //   return LatLng(position.latitude, position.longitude);
  // }
  final String mapboxToken = 'pk.eyJ1IjoiaHJpdGlrMzk2MSIsImEiOiJjbDRpZjJoZmEwbmt2M2JwOTR0ZmxqamVpIn0.j7hMYKw95zKarr69MMtfcA';
  late MapboxMapController mapController;

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }
  bool myLocationenabled = false;


  @override
  Widget build(BuildContext context,  ref) {

    // TODO: implement build
    var Position = ref.read(currlnglatProvider);
    print(Position);
    String CurrrentAddress = ref.watch(CurrentAdressProvider);
    _addSourceAndLineLayer( Map geometry,bool removeLayer) async {
      // Can animate camera to focus on the item
      mapController.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(target: ref.read(destinationlnglatProvider))));

          // Add a polyLine between source and destination
          // Map geometry = getGeometryFromSharedPrefs(carouselData[index]['index']);
      final _fills = {
        "type": "FeatureCollection",
        "features": [
          {
            "type": "Feature",
            "id": 0,
            "properties": <String, dynamic>{},
            "geometry": geometry,
          },
        ],
      };
      print('draw');

      // Remove lineLayer and source if it exists
      if (removeLayer == true) {
        await mapController.removeLayer("lines");
        await mapController.removeSource("fills");
      }
      print('Draw');
      // Add new source and lineLayer
      await mapController.addSource("fills", GeojsonSourceProperties(data: _fills));
      print('draw');
      await mapController.addLineLayer(
        "fills",
        "lines",
        LineLayerProperties(
          lineColor: Colors.green.toHexStringRGB(),
          lineCap: "round",
          lineJoin: "round",
          lineWidth: 5,
        ),
      );
    }
    _onStyleLoadedCallback() async {
      mapController.addSymbol(
          SymbolOptions(
            geometry: ref.read(destinationlnglatProvider),
            iconSize: 0.2,
            iconImage: 'img.png',
          ),
        );
      
      // _addSourceAndLineLayer(0, false);
    }

    return Scaffold(
      key: _scaffoldKey,
      // appBar: AppBar(),
      body: Stack(
        children: [
          MapboxMap(
                    accessToken: 'pk.eyJ1IjoiaHJpdGlrMzk2MSIsImEiOiJjbDRpZjJoZmEwbmt2M2JwOTR0ZmxqamVpIn0.j7hMYKw95zKarr69MMtfcA',

                    onMapCreated: _onMapCreated,
                    onCameraIdle: () => print("onCameraIdle"),
                    initialCameraPosition:
                                CameraPosition(
                                    // target: LatLng(0.0, 0.0)
                                  target: ref.read(currlnglatProvider),
                                  zoom : 15,
                                  tilt: 30,
                                ),
                    myLocationEnabled: myLocationenabled,
                    onStyleLoadedCallback: _onStyleLoadedCallback,
                    myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
                    minMaxZoomPreference: MinMaxZoomPreference(5,17),
                          ),
          Positioned(
            bottom: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Hi there!',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        const Text("Your Current Address"),
                        Text(CurrrentAddress,
                            style: const TextStyle(color: Colors.indigo)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>  Direction())),
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(20)),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('Where do you wanna go today?'),
                                ])),
                      ]),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 160,
              child: IconButton(
                onPressed: () async{
                var currpos = await determinePosition();
                LatLng value = LatLng(currpos.latitude, currpos.longitude);
                await ref.read(currlnglatProvider.notifier).update(value);
                var Position = ref.read(currlnglatProvider);
                print(Position);
                mapController.moveCamera(

                  CameraUpdate.newCameraPosition(
                    CameraPosition(

                      bearing: 270.0,
                      // target: LatLng(51.5160895, -0.1294527),
                      target: ref.read(currlnglatProvider) as dynamic,
                      tilt: 30.0,
                      zoom: 17.0,
                    ),
                  ),
                );
                Map response = await getAdress(Position);
                String curradress = response['features'][0]['place_name'];
                ref.read(CurrentAdressProvider.notifier).update(curradress);
                myLocationenabled = true;
                mapController.addSymbol(
                  SymbolOptions(
                    geometry: ref.read(currlnglatProvider),
                    iconSize: 0.2,
                    iconImage: 'img.png',
                  ),
                );


              }, icon: Icon(Icons.my_location),
                iconSize: 35,
                hoverColor: Colors.white,
                splashColor: Colors.white,

          ))


        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: ()async{
      //     var currpos = await determinePosition();
      //     LatLng value = LatLng(currpos.latitude, currpos.longitude);
      //     await ref.read(currlnglatProvider.notifier).update(value);
      //     var Position = ref.read(currlnglatProvider);
      //     print(Position);
      //     mapController.moveCamera(
      //
      //       CameraUpdate.newCameraPosition(
      //         CameraPosition(
      //
      //           bearing: 270.0,
      //           // target: LatLng(51.5160895, -0.1294527),
      //           target: ref.read(currlnglatProvider) as dynamic,
      //           tilt: 30.0,
      //           zoom: 17.0,
      //         ),
      //       ),
      //     );
      //     Map response = await getAdress(Position);
      //     String curradress = response['features'][0]['place_name'];
      //     ref.read(CurrentAdressProvider.notifier).update(curradress);
      //     myLocationenabled = true;
      //     mapController.addSymbol(
      //       SymbolOptions(
      //         geometry: ref.read(currlnglatProvider),
      //         iconSize: 0.2,
      //         iconImage: 'img.png',
      //       ),
      //     );
      //
      //
      //
      //   },
      //   child: Icon(Icons.my_location),
      // ),

    );
    throw UnimplementedError();
  }


}

// @override











