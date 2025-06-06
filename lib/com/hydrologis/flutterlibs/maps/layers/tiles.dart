/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */
part of smashlibs;

class TileSource extends TiledRasterLayerSource {
  String? name;
  String? absolutePath;
  String? url;
  int minZoom = DEFAULT_MINZOOM_INT;
  int maxZoom = DEFAULT_MAXZOOM_INT;
  int maxNativeZoom = DEFAULT_MAXNATIVEZOOM_INT;
  String? attribution;
  LatLngBounds? bounds;
  List<String> subdomains = [];
  bool isVisible = true;
  bool isTms = false;
  bool isWms = false;
  bool? doGpkgAsOverlay;
  double opacityPercentage = 100;
  List<int>? rgbToHide;
  int _srid = SmashPrj.EPSG3857_INT;

  bool canDoProperties = true;

  ErrorTileCallBack? errorTileCallback = (tile, exception, stacktrace) {
    // ignore tiles that can't load to avoid
    // if (exception is String) {
    //   SMLogger().e(exception, null, stacktrace);
    // } else {
    //   SMLogger()
    //       .e("Unable to load tile: ${tile.coordinates}", null, stacktrace);
    // }
  };
  bool overrideTilesOnUrlChange = true;

  TileSource({
    this.name,
    this.absolutePath,
    this.url,
    required this.minZoom,
    required this.maxZoom,
    this.maxNativeZoom = DEFAULT_MAXNATIVEZOOM_INT,
    this.attribution,
    this.subdomains = const <String>[],
    this.isVisible = true,
    this.isTms = false,
    this.opacityPercentage = 100,
    this.rgbToHide,
    this.doGpkgAsOverlay,
  }) {
    isLoaded = true;
  }

  TileSource.fromMap(Map<String, dynamic> map) {
    this.name = map[LAYERSKEY_LABEL];
    var relativePath = map[LAYERSKEY_FILE];
    if (relativePath != null) {
      absolutePath = Workspace.makeAbsolute(relativePath);
    }
    this.url = map[LAYERSKEY_URL];
    this.minZoom = map[LAYERSKEY_MINZOOM] ?? DEFAULT_MINZOOM_INT;
    this.maxZoom = map[LAYERSKEY_MAXZOOM] ?? DEFAULT_MAXZOOM_INT;
    this.maxNativeZoom =
        map[LAYERSKEY_MAXNATIVEZOOM] ?? DEFAULT_MAXNATIVEZOOM_INT;
    this.attribution = map[LAYERSKEY_ATTRIBUTION];
    this.isVisible = map[LAYERSKEY_ISVISIBLE];
    this.opacityPercentage = (map[LAYERSKEY_OPACITY] ?? 100).toDouble();
    this.doGpkgAsOverlay = map[LAYERSKEY_GPKG_DOOVERLAY];

    var c2hide = map[LAYERSKEY_COLORTOHIDE];
    if (c2hide != null) {
      var split = c2hide.split(",");
      this.rgbToHide = [
        int.parse(split[0]),
        int.parse(split[1]),
        int.parse(split[2]),
      ];
    }
    _srid = map[LAYERSKEY_SRID] ?? _srid;

    var subDomains = map['subdomains'] as String?;
    if (subDomains != null) {
      this.subdomains = subDomains.split(",");
    }
    getBounds(null);
    isLoaded = true;
  }

  TileSource.Open_Street_Map_Standard({
    this.name = "Open Street Map",
    this.url = "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
    this.attribution = "OpenStreetMap, ODbL",
    this.minZoom = DEFAULT_MINZOOM_INT,
    this.maxZoom = DEFAULT_MAXZOOM_INT,
    this.maxNativeZoom = 16,
    this.isVisible = true,
    this.isTms = false,
    this.canDoProperties = true,
  }) {
    isLoaded = true;
  }

  TileSource.OpenTopoMap({
    this.name = "OpenTopoMap",
    this.url = "https://tile.opentopomap.org/{z}/{x}/{y}.png",
    this.attribution = "OpenStreetMap, ODbL",
    this.minZoom = DEFAULT_MINZOOM_INT,
    this.maxZoom = DEFAULT_MAXZOOM_INT,
    this.maxNativeZoom = DEFAULT_MAXNATIVEZOOM_INT,
    this.isVisible = true,
    this.canDoProperties = true,
  }) {
    isLoaded = true;
  }

  TileSource.Open_Street_Map_HOT({
    this.name = "Open Street Map H.O.T.",
    this.url = "https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
    this.attribution = "OpenStreetMap, ODbL",
    this.subdomains = const ['a', 'b'],
    this.minZoom = DEFAULT_MINZOOM_INT,
    this.maxZoom = DEFAULT_MAXZOOM_INT,
    this.maxNativeZoom = DEFAULT_MAXNATIVEZOOM_INT,
    this.isVisible = true,
    this.isTms = false,
    this.canDoProperties = true,
  }) {
    isLoaded = true;
  }

  // TileSource.Stamen_Watercolor({
  //   this.name= "Stamen Watercolor",
  //   this.url= "https://c.tile.stamen.com/watercolor/{z}/{x}/{y}.jpg",
  //   this.attribution:
  //       "Map tiles by Stamen Design, under CC BY 3.0. Data by OpenStreetMap, under ODbL",
  //   this.minZoom= DEFAULT_MINZOOM,
  //   this.maxZoom= DEFAULT_MAXZOOM,
  //   this.isVisible= true,
  //   this.isTms= false,
  //   this.canDoProperties = true,
  // });

  TileSource.Opnvkarte_Transport({
    this.name = "Opnvkarte Transport",
    this.url = "https://tile.memomaps.de/tilegen/{z}/{x}/{y}.png",
    this.attribution = "OpenStreetMap, ODbL",
    this.minZoom = DEFAULT_MINZOOM_INT,
    this.maxZoom = DEFAULT_MAXZOOM_INT,
    this.maxNativeZoom = DEFAULT_MAXNATIVEZOOM_INT,
    this.isVisible = true,
    this.isTms = false,
    this.canDoProperties = true,
  }) {
    isLoaded = true;
  }

  TileSource.Esri_Satellite({
    this.name = "Esri Satellite",
    this.url:
        "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
    this.attribution = "Copyright Esri",
    this.minZoom = DEFAULT_MINZOOM_INT,
    this.maxZoom = DEFAULT_MAXZOOM_INT,
    this.maxNativeZoom = 17,
    this.isVisible = true,
    this.isTms = false,
    this.canDoProperties = true,
  }) {
    isLoaded = true;
  }

  TileSource.Mapsforge(String filePath) {
    this.name = HU.FileUtilities.nameFromFile(filePath, false);
    this.absolutePath = Workspace.makeAbsolute(filePath);
    this.attribution =
        "Map tiles by Mapsforge, Data by OpenStreetMap, under ODbL";
    this.minZoom = DEFAULT_MINZOOM_INT;
    this.maxZoom = 22;
    this.maxNativeZoom = 25;
    this.isVisible = true;
    this.isTms = false;
    this.canDoProperties = true;
    isLoaded = true;
  }

  TileSource.Mapurl(String filePath) {
    //        url=http://tile.openstreetmap.org/ZZZ/XXX/YYY.png
    //        minzoom=0
    //        maxzoom=19
    //        center=11.42 46.8
    //        type=google
    //        format=png
    //        defaultzoom=13
    //        mbtiles=defaulttiles/_mapnik.mbtiles
    //        description=Mapnik - Openstreetmap Slippy Map Tileserver - Data, imagery and map information provided by MapQuest, OpenStreetMap and contributors, ODbL.

    this.name = HU.FileUtilities.nameFromFile(filePath, false);

    var paramsMap = HU.FileUtilities.readFileToHashMap(filePath);

    String type = paramsMap["type"] ?? "tms";
    if (type.toLowerCase() == "wms") {
      throw ArgumentError("WMS mapurls are not supported at the time.");
      // TODO work on fixing WMS support, needs more love
//      String layer = paramsMap["layer"];
//      if (layer != null) {
//        this.name = layer;
//        this.isWms = true;
//      }
    }

    String? url = paramsMap["url"];
    if (url == null) {
      throw ArgumentError("The url for the service needs to be defined.");
    }
    url = url.replaceFirst("ZZZ", "{z}");
    url = url.replaceFirst("YYY", "{y}");
    url = url.replaceFirst("XXX", "{x}");

    String maxZoomStr = paramsMap["maxzoom"] ?? "19";
    int maxZoom = double.parse(maxZoomStr).toInt();
    String minZoomStr = paramsMap["minzoom"] ?? "0";
    int minZoom = double.parse(minZoomStr).toInt();
    String descr = paramsMap["description"] ?? "no description";

    this.url = url;
    this.attribution = descr;
    this.minZoom = minZoom;
    this.maxZoom = maxZoom;
    this.maxNativeZoom = DEFAULT_MAXNATIVEZOOM_INT;
    this.isVisible = true;
    this.isTms = type == "tms";
    this.canDoProperties = true;
    isLoaded = true;
  }

  TileSource.Mbtiles(String filePath) {
    this.name = HU.FileUtilities.nameFromFile(filePath, false);
    this.absolutePath = Workspace.makeAbsolute(filePath);
    this.attribution = "";
    this.minZoom = DEFAULT_MINZOOM_INT;
    this.maxZoom = 22;
    this.maxNativeZoom = maxZoom;
    this.isVisible = true;
    this.isTms = true;
    this.canDoProperties = true;
    getBounds(null);
    isLoaded = true;
  }

  TileSource.Geopackage(String filePath, String tableName) {
    this.name = tableName;
    this.absolutePath = Workspace.makeAbsolute(filePath);
    this.attribution = "";
    this.minZoom = DEFAULT_MINZOOM_INT;
    this.maxZoom = 22;
    this.maxNativeZoom = 22;
    this.isVisible = true;
    this.isTms = true;
    this.canDoProperties = true;
    this.doGpkgAsOverlay = true;
    getBounds(null);
    isLoaded = true;
  }

  Future<void> open() async {}

  String? getAbsolutePath() {
    return absolutePath;
  }

  String? getUrl() {
    return url;
  }

  String? getName() {
    return name;
  }

  String? getUser() => null;

  String? getPassword() => null;

  String? getAttribution() {
    return attribution;
  }

  void setAttribution(String attribution) {
    this.attribution = attribution;
  }

  bool isActive() {
    return isVisible;
  }

  void setActive(bool active) {
    isVisible = active;
  }

  IconData getIcon() => SmashIcons.iconTypeRaster;

  Future<LatLngBounds?> getBounds(BuildContext? context) async {
    if (bounds == null) {
      try {
        if (FileManager.isMapsforge(getAbsolutePath())) {
          bounds = await getMapsforgeBounds(File(absolutePath!));
        } else if (FileManager.isMbtiles(getAbsolutePath())) {
          var prov = SmashMBTilesImageProvider(File(absolutePath!));
          prov.open();
          bounds = prov.bounds;
          prov.dispose();
        } else if (FileManager.isGeopackage(getAbsolutePath())) {
          var ch = GPKG.ConnectionsHandler();
          var db = ch.open(absolutePath!, tableName: name);
          var tileEntry = db.tile(TableName(name!, schemaSupported: false));
          if (tileEntry != null) {
            var env = tileEntry.bounds;
            if (tileEntry.srid != GPKG.Proj.EPSG4326_INT) {
              env = GPKG.Proj.transformEnvelopeToWgs84(
                  proj4dart.Projection.get("EPSG:${tileEntry.srid}")!, env);
            }

            bounds = LatLngBounds(LatLng(env.getMinY(), env.getMinX()),
                LatLng(env.getMaxY(), env.getMaxX()));
          } else {
            throw ArgumentError(
                "No tile entry found for table $name in db: $absolutePath");
          }
          // var prov = GeopackageImageProvider(File(absolutePath), name);
          // prov.open();
          // bounds = prov.bounds;
          // prov.dispose();
        }
      } on Exception catch (e, s) {
        SMLogger().e("En error occurred while loading ", e, s);
      }
    }
    return bounds;
  }

  Future<List<Widget>> toLayers(BuildContext context) async {
    bool retinaModeOn = GpPreferences()
        .getBooleanSync(SmashPreferencesKeys.KEY_RETINA_MODE_ON, false);
    if (FileManager.isMapsforge(getAbsolutePath())) {
      // mapsforge
      double tileSize = 256;
      var mapsforgeTileProvider =
          MapsforgeTileProvider(File(absolutePath!), tileSize: tileSize);
      await mapsforgeTileProvider.open();
      var layerKey = "${name}_${mapsforgeTileProvider.getRenderThemeName()}";
      var urlTemplate = mapsforgeTileProvider.getUrlTemplate();
      return [
        Opacity(
            opacity: opacityPercentage / 100.0,
            child: TileLayer(
              key: ValueKey(layerKey),
              tileProvider: mapsforgeTileProvider,
              // urlTemplate: urlTemplate,
              tileSize: tileSize,
              keepBuffer: 2,
              panBuffer: 0,
              maxZoom: maxZoom.toDouble(),
              maxNativeZoom: maxNativeZoom,
              tms: isTms,
              retinaMode: false, // not supported
              errorTileCallback: errorTileCallback,
              // fallbackUrl: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            ))
      ];
    } else if (FileManager.isMbtiles(getAbsolutePath())) {
      var tileProvider = SmashMBTilesImageProvider(File(absolutePath!));
      tileProvider.open();
      // mbtiles
      return [
        Opacity(
          opacity: opacityPercentage / 100.0,
          child: TileLayer(
            key: ValueKey(name),
            tileProvider: tileProvider,
            maxZoom: maxZoom.toDouble(),
            maxNativeZoom: maxNativeZoom,
            tms: true,
            retinaMode: false, // not supported
            errorTileCallback: errorTileCallback,
          ),
        )
      ];
    } else if (FileManager.isGeopackage(getAbsolutePath())) {
      var ch = GPKG.ConnectionsHandler();
      var db = ch.open(absolutePath!, tableName: name);

      if (doGpkgAsOverlay != null && doGpkgAsOverlay!) {
        var tileEntry = db.tile(TableName(name!, schemaSupported: false));
        var to4326function;
        if (tileEntry!.srid != GPKG.Proj.EPSG4326_INT) {
          to4326function = (var envelope) {
            return GPKG.Proj.transformEnvelopeToWgs84(
                proj4dart.Projection.get("EPSG:${tileEntry.srid}")!, envelope);
          };
        }
        var fetcher = GPKG.TilesFetcher(tileEntry);
        var lazyTiles =
            fetcher.getAllLazyTiles(db, to4326BoundsConverter: to4326function);
        var overlayImages = lazyTiles.map((lt) {
          var minX = lt.tileBoundsLatLong!.getMinX();
          var minY = lt.tileBoundsLatLong!.getMinY();
          var maxX = lt.tileBoundsLatLong!.getMaxX();
          var maxY = lt.tileBoundsLatLong!.getMaxY();

          return OverlayImage(
            bounds: LatLngBounds(LatLng(minY, minX), LatLng(maxY, maxX)),
            opacity: opacityPercentage / 100.0,
            imageProvider: GeopackageLazyTileImageProvider(lt, rgbToHide),
          );
        }).toList();
        return [
          OverlayImageLayer(key: ValueKey(name), overlayImages: overlayImages),
        ];
      } else {
        var tileProvider = GeopackageTileImageProvider(
            db, TableName(name!, schemaSupported: false));
        return [
          Opacity(
            opacity: opacityPercentage / 100.0,
            child: TileLayer(
              key: ValueKey(name),
              tileProvider: tileProvider,
              maxZoom: maxZoom.toDouble(),
              maxNativeZoom: maxNativeZoom,
              tms: true,
              retinaMode: false, // not supported
              errorTileCallback: errorTileCallback,
            ),
          )
        ];
      }
    } else if (isOnlineService()) {
      TileProvider tileProvider =
          ExceptionsToTrack.getDefaultForOnlineServices();
      if (isWms) {
        var tileLayerOptions = Opacity(
          opacity: opacityPercentage / 100.0,
          child: TileLayer(
            key: ValueKey(name),
            wmsOptions: WMSTileLayerOptions(
              baseUrl: url!,
              layers: [name!],
            ),
            maxZoom: maxZoom.toDouble(),
            maxNativeZoom: maxNativeZoom,
            retinaMode: retinaModeOn,
            tileProvider: tileProvider,
            errorTileCallback: errorTileCallback,
          ),
        );
        return [tileLayerOptions];
      } else {
        return [
          Opacity(
            opacity: opacityPercentage / 100.0,
            child: TileLayer(
              key: ValueKey(name),
              tms: isTms,
              urlTemplate: url,
              maxZoom: maxZoom.toDouble(),
              maxNativeZoom: maxNativeZoom,
              subdomains: subdomains,
              retinaMode: retinaModeOn,
              tileProvider: tileProvider,
              errorTileCallback: errorTileCallback,
            ),
          )
        ];
      }
    } else {
      throw Exception(
          "Type not supported: ${absolutePath != null ? absolutePath : url}");
    }
  }

  String toJson() {
    String? savePath;
    if (absolutePath != null) {
      savePath = Workspace.makeRelative(absolutePath!);
    }

    var pathLine =
        savePath != null ? "\"$LAYERSKEY_FILE\": \"$savePath\"," : "";
    var urlLine = url != null ? "\"$LAYERSKEY_URL\": \"$url\"," : "";

    var colorToHideLine = "";
    if (rgbToHide != null) {
      var cJoin = rgbToHide!.join(",");
      colorToHideLine = "\"$LAYERSKEY_COLORTOHIDE\":\"$cJoin\",";
    }
    var doGeopkgMode = "";
    if (doGpkgAsOverlay != null) {
      doGeopkgMode = "\"$LAYERSKEY_GPKG_DOOVERLAY\":$doGpkgAsOverlay,";
    }

    var json = '''
    {
        "$LAYERSKEY_LABEL": "$name",
        $pathLine
        $urlLine
        "$LAYERSKEY_MINZOOM": $minZoom,
        "$LAYERSKEY_MAXZOOM": $maxZoom,
        "$LAYERSKEY_MAXNATIVEZOOM": $maxNativeZoom,
        "$LAYERSKEY_OPACITY": $opacityPercentage,
        "$LAYERSKEY_ATTRIBUTION": "$attribution",
        "$LAYERSKEY_SRID": $_srid,
        "$LAYERSKEY_TYPE": "$LAYERSTYPE_TMS",
        $colorToHideLine
        $doGeopkgMode
        "$LAYERSKEY_ISVISIBLE": $isVisible ${subdomains.isNotEmpty ? "," : ""}
        ${subdomains.isNotEmpty ? "\"subdomains\": \"${subdomains.join(',')}\"" : ""}
    }
    ''';
    return json;
  }

  @override
  void disposeSource() {
    GPKG.ConnectionsHandler()
        .close(getAbsolutePath() ?? getUrl()!, tableName: getName());
  }

  @override
  bool hasProperties() {
    return canDoProperties;
  }

  Widget getPropertiesWidget() {
    return TileSourcePropertiesWidget(this);
  }

  @override
  bool isZoomable() {
    return bounds != null;
  }

  @override
  Future<void> load(BuildContext? context) async {
    getBounds(context);
  }

  @override
  int getSrid() {
    return _srid;
  }
}

/// The tiff properties page.
class TileSourcePropertiesWidget extends StatefulWidget {
  final TileSource _source;
  TileSourcePropertiesWidget(this._source);

  @override
  State<StatefulWidget> createState() {
    return TileSourcePropertiesWidgetState(_source);
  }
}

class TileSourcePropertiesWidgetState
    extends State<TileSourcePropertiesWidget> {
  TileSource _source;
  double _opacitySliderValue = 100;
  Color _hideColor = Colors.white;
  bool _somethingChanged = false;
  bool useHideColor = false;
  bool isGeopackage = false;
  bool? doGpkgAsOverlay;
  String mapsforgeTheme = "defaultrender";

  TileSourcePropertiesWidgetState(this._source);

  @override
  void initState() {
    _opacitySliderValue = _source.opacityPercentage;
    if (_opacitySliderValue > 100) {
      _opacitySliderValue = 100;
    }
    if (_opacitySliderValue < 0) {
      _opacitySliderValue = 0;
    }

    var rgbToHide = _source.rgbToHide;
    if (rgbToHide != null) {
      useHideColor = true;
      _hideColor =
          Color.fromARGB(255, rgbToHide[0], rgbToHide[1], rgbToHide[2]);
    }

    if (this._source.doGpkgAsOverlay != null) {
      isGeopackage = true;
      doGpkgAsOverlay = this._source.doGpkgAsOverlay;
    }

    // get mapsforge theme from preferences
    mapsforgeTheme = GpPreferences().getStringSync(
            "KEY_MAPSFORGE_THEME_${_source.absolutePath}", "defaultrender") ??
        "defaultrender";

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var absolutePath = widget._source.getAbsolutePath();
    bool showColorHide = false;
    if (absolutePath != null) {
      showColorHide = FileManager.isGeopackage(absolutePath);
    }

    bool isMapsforge = FileManager.isMapsforge(absolutePath);

    return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (_somethingChanged) {
            _source.opacityPercentage = _opacitySliderValue;
            if (useHideColor) {
              _source.rgbToHide = [
                _hideColor.red,
                _hideColor.green,
                _hideColor.blue
              ];
            } else {
              _source.rgbToHide = null;
            }
            _source.doGpkgAsOverlay = doGpkgAsOverlay;
            _source.isLoaded = false;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title:
                Text(SLL.of(context).tiles_tileProperties), //"Tile Properties"
          ),
          body: ListView(
            children: <Widget>[
              if (!isMapsforge)
                Padding(
                  padding: SmashUI.defaultPadding(),
                  child: Card(
                    shape: SmashUI.defaultShapeBorder(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(MdiIcons.opacity),
                          title: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child:
                                Text(SLL.of(context).tiles_opacity), //"Opacity"
                          ),
                          subtitle: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Flexible(
                                  flex: 1,
                                  child: Slider(
                                    activeColor: SmashColors.mainSelection,
                                    min: 0.0,
                                    max: 100,
                                    divisions: 10,
                                    onChanged: (newRating) {
                                      _somethingChanged = true;
                                      setState(() =>
                                          _opacitySliderValue = newRating);
                                    },
                                    value: _opacitySliderValue,
                                  )),
                              Container(
                                width: 50.0,
                                alignment: Alignment.center,
                                child: SmashUI.normalText(
                                  '${_opacitySliderValue.toInt()}',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (isMapsforge)
                Padding(
                  padding: SmashUI.defaultPadding(),
                  child: Card(
                    shape: SmashUI.defaultShapeBorder(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(MdiIcons.mapMarker),
                          title: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(SLL.of(context).mapsforge_theme),
                          ),
                          subtitle: TextButton(
                            style: SmashUI.defaultFlatButtonStyle(
                                color: SmashColors.mainDecorations),
                            onPressed: () async {
                              List<String> themes = [
                                "defaultrender",
                                "darkrender",
                                "custom",
                                "elevate",
                              ];
                              var selected =
                                  await SmashDialogs.showSingleChoiceDialog(
                                      context,
                                      SLL
                                          .of(context)
                                          .mapsforge_select_tiles_theme,
                                      themes,
                                      selected: mapsforgeTheme);
                              if (selected != null) {
                                GpPreferences().setString(
                                    "KEY_MAPSFORGE_THEME_$absolutePath",
                                    selected);
                                setState(() {
                                  mapsforgeTheme = selected;
                                  _somethingChanged = true;
                                });
                              }
                            },
                            child:
                                SmashUI.titleText(mapsforgeTheme, bold: true),
                          ),
                        ),
                        ListTile(
                          leading: Icon(MdiIcons.opacity),
                          title: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child:
                                Text(SLL.of(context).tiles_opacity), //"Opacity"
                          ),
                          subtitle: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Flexible(
                                  flex: 1,
                                  child: Slider(
                                    activeColor: SmashColors.mainSelection,
                                    min: 0.0,
                                    max: 100,
                                    divisions: 10,
                                    onChanged: (newRating) {
                                      _somethingChanged = true;
                                      setState(() =>
                                          _opacitySliderValue = newRating);
                                    },
                                    value: _opacitySliderValue,
                                  )),
                              Container(
                                width: 50.0,
                                alignment: Alignment.center,
                                child: SmashUI.normalText(
                                  '${_opacitySliderValue.toInt()}',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (isGeopackage)
                Padding(
                  padding: SmashUI.defaultPadding(),
                  child: Card(
                    shape: SmashUI.defaultShapeBorder(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CheckboxListTile(
                          value: doGpkgAsOverlay,
                          title: Padding(
                            padding: SmashUI.defaultPadding(),
                            child: Text(SLL
                                .of(context)
                                .tiles_loadGeoPackageAsOverlay), //"Load geopackage tiles as overlay image as opposed to tile layer (best for gdal generated data and different projections)."
                          ),
                          onChanged: (newValue) {
                            setState(() {
                              doGpkgAsOverlay = newValue;
                              _somethingChanged = true;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              if (EXPERIMENTAL_HIDE_COLOR_RASTER__ENABLED && showColorHide)
                Padding(
                  padding: SmashUI.defaultPadding(),
                  child: Card(
                    shape: SmashUI.defaultShapeBorder(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(MdiIcons.eyedropperVariant),
                          title: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(SLL
                                .of(context)
                                .tiles_colorToHide), //"Color to hide"
                          ),
                          subtitle: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: SmashUI.defaultPadding(),
                                  child:
                                      ColorPickerButton(_hideColor, (newColor) {
                                    _hideColor = ColorExt.fromColor(newColor);
                                    _somethingChanged = true;
                                  }),
                                ),
                              ),
                              Checkbox(
                                value: useHideColor,
                                onChanged: (value) {
                                  setState(() {
                                    useHideColor = value!;
                                    _somethingChanged = true;
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ));
  }
}
