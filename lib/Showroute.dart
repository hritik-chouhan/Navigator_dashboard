import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:navigator2/provider.dart';

class showRoute extends StatefulWidget {
  final Map RouteResponse;
  final LatLng currlatlng;
  const showRoute({Key? key,required this.RouteResponse, required this.currlatlng}) : super(key: key);

  @override
  _showRouteState createState() => _showRouteState();
}

class _showRouteState extends State<showRoute> {
  final String mapboxToken = 'pk.eyJ1IjoiaHJpdGlrMzk2MSIsImEiOiJjbDRpZjJoZmEwbmt2M2JwOTR0ZmxqamVpIn0.j7hMYKw95zKarr69MMtfcA';

  // final List<CameraPosition> _kTripEndPoints = [];
  late MapboxMapController controller;
  late CameraPosition _initialCameraPosition;

  // Directions API response related
  late String distance;
  late String dropOffTime;
  late Map geometry;

  @override
  void initState() {
    // initialise distance, dropOffTime, geometry
    _initialiseDirectionsResponse();

    // initialise initialCameraPosition, address and trip end points
    _initialCameraPosition = CameraPosition(
        target: widget.currlatlng, zoom: 11);

    // for (String type in ['source', 'destination']) {
    //   _kTripEndPoints
    //       .add(CameraPosition(target: getTripLatLngFromSharedPrefs(type)));
    // }
    super.initState();
  }

  _initialiseDirectionsResponse() {
    distance = (widget.RouteResponse['distance'] / 1000).toStringAsFixed(1);
    geometry = widget.RouteResponse['geometry'];
  }

  _onMapCreated(MapboxMapController controller) async {
    this.controller = controller;
  }

  _onStyleLoadedCallback() async {
    // for (int i = 0; i < _kTripEndPoints.length; i++) {
    //   String iconImage = i == 0 ? 'circle' : 'square';
    //   await controller.addSymbol(
    //     SymbolOptions(
    //       geometry: _kTripEndPoints[i].target,
    //       iconSize: 0.1,
    //       iconImage: "assets/icon/$iconImage.png",
    //     ),
    //   );
    // }
    _addSourceAndLineLayer();
  }

  _addSourceAndLineLayer() async {
    // Create a polyLine between source and destination
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

    // Add new source and lineLayer
    await controller.addSource("fills", GeojsonSourceProperties(data: _fills));
    await controller.addLineLayer(
      "fills",
      "lines",
      LineLayerProperties(
        lineColor: Colors.indigo.toHexStringRGB(),
        lineCap: "round",
        lineJoin: "round",
        lineWidth: 3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back)),
        title: const Text('Review Ride'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: MapboxMap(
                accessToken: mapboxToken,
                initialCameraPosition: _initialCameraPosition,
                onMapCreated: _onMapCreated,
                onStyleLoadedCallback: _onStyleLoadedCallback,
                myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
                minMaxZoomPreference: const MinMaxZoomPreference(5, 16),
                scrollGesturesEnabled: true,
                rotateGesturesEnabled: true,
                zoomGesturesEnabled: true,
                compassEnabled: true,
                tiltGesturesEnabled: true,
                doubleClickZoomEnabled: true,
                myLocationEnabled: true,
              ),
            ),
            // reviewRideBottomSheet(context, distance, dropOffTime),
          ],
        ),
      ),
    );;
  }
}
