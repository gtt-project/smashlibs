import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smashlibs/smashlibs.dart';
import 'package:dart_jts/dart_jts.dart';
import 'package:provider/provider.dart';

class MainSmashLibsPage extends StatefulWidget {
  const MainSmashLibsPage({super.key, required this.title});
  final String title;

  @override
  State<MainSmashLibsPage> createState() => _MainSmashLibsPageState();
}

class _MainSmashLibsPageState extends State<MainSmashLibsPage> {
  SmashMapWidget? mapView;
  final LayerSource _backgroundLayerSource = onlinesTilesSources[0];
  LayerSource _currentLayerSource = onlinesTilesSources[1];

  FutureOr<void> load(BuildContext context) async {
    if (mapView != null) {
      return;
    }
    await GpPreferences().initialize();
    if (context.mounted) await LayerManager().initialize(context);

    mapView = SmashMapWidget();
    mapView!.setInitParameters(
        canRotate: false,
        initZoom: 9,
        centerCoordinate: Coordinate(11, 46),
        canScrollWheelZoom: false);
    mapView!.setOnPositionChanged((newPosition, hasGest) {
      SmashMapState mapState =
          Provider.of<SmashMapState>(context, listen: false);
      mapState.setLastPositionQuiet(
          LatLngExt.fromLatLng(newPosition.center!).toCoordinate(),
          newPosition.zoom);
    });
    mapView!.setTapHandlers(
      handleTap: (ll, zoom) async {
        SmashDialogs.showToast(
            context, "Tapped: ${ll.longitude}, ${ll.latitude}",
            durationSeconds: 1);
        GeometryEditorState geomEditorState =
            Provider.of<GeometryEditorState>(context, listen: false);
        if (geomEditorState.isEnabled) {
          await GeometryEditManager().onMapTap(context, ll);
        }
      },
      handleLongTap: (ll, zoom) async {
        GeometryEditorState geomEditorState =
            Provider.of<GeometryEditorState>(context, listen: false);
        if (geomEditorState.isEnabled) {
          GeometryEditManager().onMapLongTap(context, ll, zoom.round());
        }
      },
    );

    mapView!.addLayerSource(_backgroundLayerSource);
    mapView!.addLayerSource(_currentLayerSource);

    int tapAreaPixels = GpPreferences()
            .getIntSync(SmashPreferencesKeys.KEY_VECTOR_TAPAREA_SIZE, 50) ??
        50;
    mapView!.addPostLayer(FeatureInfoLayer(
      tapAreaPixelSize: tapAreaPixels.toDouble(),
    ));

    var centerCrossStyle = CenterCrossStyle.fromPreferences();
    if (centerCrossStyle.visible) {
      mapView!.addPostLayer(CenterCrossLayer(
        crossColor: ColorExt(centerCrossStyle.color),
        crossSize: centerCrossStyle.size,
        lineWidth: centerCrossStyle.lineWidth,
      ));
    }

    mapView!.addPostLayer(ScaleLayer(
      lineColor: Colors.black,
      lineWidth: 3,
      textStyle: const TextStyle(color: Colors.black, fontSize: 14),
      padding: const EdgeInsets.all(10),
    ));

    mapView!.addPostLayer(RulerPluginLayer(tapAreaPixelSize: 1));
    mapView!.addPostLayer(BoxZoomPluginLayer());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, projectSnap) {
        if (projectSnap.hasError) {
          return SmashUI.errorWidget(projectSnap.error.toString());
        } else if (projectSnap.connectionState == ConnectionState.none ||
            projectSnap.data == null) {
          return SmashCircularProgress(label: "Loading...");
        }

        Widget widget = projectSnap.data as Widget;
        return widget;
      },
      future: getWidget(context),
    );
  }

  Future<Scaffold> getWidget(BuildContext context) async {
    var w = ScreenUtilities.getWidth(context);
    // pick 70% of the screen width
    var w2 = w * 0.7;
    await load(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          SizedBox(
            width: w2,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () async {
                      mapView!.removeLayerSource(_currentLayerSource);
                      _currentLayerSource = onlinesTilesSources[1];
                      await addLayerAndZoomTo(context);
                    },
                    child: SmashUI.normalText("WTS",
                        color: SmashColors.mainBackground),
                  ),
                  TextButton(
                    onPressed: () async {
                      mapView!.removeLayerSource(_currentLayerSource);
                      var url =
                          "https://geoservices.buergernetz.bz.it/mapproxy/wms";
                      _currentLayerSource = WmsSource(
                          url, "p_bz-Orthoimagery:Aerial-2020-RGB",
                          imageFormat: "image/png");
                      await addLayerAndZoomTo(context);
                    },
                    child: SmashUI.normalText("WMS",
                        color: SmashColors.mainBackground),
                  ),
                  TextButton(
                    onPressed: () async {
                      SmashDialogs.showInfoDialog(context,
                          "The postgis example connection parameters need to be set in the code. No generic postgis available.");

                      // mapView!.removeLayer(_currentLayerSource);
                      // // TODO change this with your db if you want to test in demo
                      // _currentLayerSource = PostgisSource(
                      //     "postgis:localhost:5432/testdb",
                      //     "testtable",
                      //     "testuser",
                      //     "testpwd",
                      //     null,
                      //     null,
                      //     useSSL: false);
                      // await addLayerAndZoomTo(context);
                    },
                    child: SmashUI.normalText("PostGIS",
                        color: SmashColors.mainBackground),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      body: Stack(children: [
        mapView ?? Container(),
        Align(
          alignment: Alignment.bottomLeft,
          child: SmashToolsBar(
            48,
            doZoom: true,
            doEdit: false,
            doQuery: false,
            buttonFgColor: SmashColors.gpsOnWithFix,
            buttonBgColor: SmashColors.mainDanger,
            buttonSelectionColor: SmashColors.mainDecorationsDarker,
          ),
        )
      ]),
      drawer: Drawer(
          child: ListView(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            color: SmashColors.mainBackground,
            child: DrawerHeader(child: Image.asset("assets/smash_icon.png")),
          ),
          Column(
            children: [
              ListTile(
                title: SmashUI.normalText("Zoom to garda lake", bold: true),
                onTap: () async {
                  zoomToPolygon(context);
                },
              ),
              ListTile(
                title: SmashUI.normalText("Zoom to Riva-Torbole", bold: true),
                onTap: () async {
                  zoomToLine(context);
                },
              ),
              ListTile(
                title: SmashUI.normalText("Zoom to Riva, Torbole", bold: true),
                onTap: () async {
                  zoomToPoints(context);
                },
              ),
              ListTile(
                title: SmashUI.normalText("Zoom with timer", bold: true),
                onTap: () async {
                  for (var i = 0; i < 2; i++) {
                    await Future.delayed(const Duration(seconds: 2));
                    if (context.mounted) {
                      zoomToPolygon(context);
                    }
                    await Future.delayed(const Duration(seconds: 2));
                    if (context.mounted) {
                      zoomToLine(context);
                    }
                    await Future.delayed(const Duration(seconds: 2));
                    if (context.mounted) {
                      zoomToPoints(context);
                    }
                  }
                  await Future.delayed(const Duration(seconds: 2));
                  if (context.mounted) {
                    mapView!.setHighlightedGeometry(context, null);
                  }
                },
              ),
            ],
          ),
        ],
      )),
      // bottomNavigationBar: SmashToolsBar(48.0),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void zoomToPolygon(BuildContext context) {
    var d = 0.2;
    var s = 45.6333;
    var w = 10.6833;
    var n = 45.7;
    var e = 10.7167;
    Envelope bounds = Envelope(w, e, s, n);
    bounds.expandBy(d, d);
    mapView!.zoomToBounds(bounds);

    var hlGeom = HighlightedGeometry.fromPolygon(
        LatLngBoundsExt.fromEnvelope(bounds).toPolygon());
    mapView!.setHighlightedGeometry(context, hlGeom);
  }

  void zoomToLine(BuildContext context) {
    var wkt =
        "LINESTRING ( 10.84052 45.88622, 10.86637 45.87956, 10.87613 45.86965)";
    WKTReader wktReader = WKTReader();
    var line = wktReader.read(wkt);
    var d = 0.02;
    Envelope bounds = line!.getEnvelopeInternal();
    bounds.expandBy(d, d);
    mapView!.zoomToBounds(bounds);

    var hlGeom = HighlightedGeometry.fromLineString(line,
        strokeColor: const Color.fromARGB(255, 49, 134, 237), strokeWidth: 5);
    mapView!.setHighlightedGeometry(context, hlGeom);
  }

  void zoomToPoints(BuildContext context) {
    var wkt = "MULTIPOINT ( 10.84052 45.88622, 10.87613 45.86965)";
    WKTReader wktReader = WKTReader();
    var multiPoint = wktReader.read(wkt);
    var d = 0.02;
    Envelope bounds = multiPoint!.getEnvelopeInternal();
    bounds.expandBy(d, d);
    mapView!.zoomToBounds(bounds);

    var hlGeom = HighlightedGeometry.fromPoint(multiPoint,
        color: const Color.fromARGB(255, 177, 30, 155), size: 25);
    mapView!.setHighlightedGeometry(context, hlGeom);
  }

  Future<void> addLayerAndZoomTo(BuildContext context) async {
    mapView!.addLayerSource(_currentLayerSource);
    var bounds = await _currentLayerSource.getBounds(context);
    if (bounds != null) {
      mapView!.zoomToBounds(LatLngBoundsExt.fromBounds(bounds).toEnvelope());
    }
    if (context.mounted) {
      mapView!.triggerRebuild(context);
    }
  }
}
