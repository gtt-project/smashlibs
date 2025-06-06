part of smashlibs;

abstract class OnMapTapHandler {
  void handleTap(LatLng tapCoordinate, double zoom);
  void handleLongTap(LatLng tapCoordinate, double zoom);
}

// ignore: must_be_immutable
class SmashMapWidget extends StatelessWidget {
  JTS.Coordinate? _initCenterCoordonate;
  JTS.Envelope? _initBounds;
  JTS.Envelope? _constraintBounds;
  Crs? _crs;
  double _initZoom = 13.0;
  double _minZoom = SmashMapState.MINZOOM;
  double _maxZoom = SmashMapState.MAXZOOM;
  bool _canRotate = false;
  bool _canScrollWheelZoom = true;
  bool _useLayerManager = true;
  bool _addBorder = false;
  bool consumerBuild = false;
  bool _isMapReady = false;
  HighlightedGeometry? highlightedGeometry;

  MapController _mapController = MapController();
  FlutterMap? flutterMap;
  List<Widget> preLayers = [];
  List<Widget> postLayers = [];
  List<LayerSource> layerSources = [];
  List<List<String?>> _attributionsAndUrls = [];
  AttributionAlignment _attributionAlignment = AttributionAlignment.bottomRight;
  void Function(LatLng, double) _handleTap = (ll, z) {};
  void Function(LatLng, double) _handleLongTap = (ll, z) {};
  void Function() _onMapReady = () {};
  void Function(MapCamera, bool) _onPositionChanged =
      (mapPosition, hasGesture) {};

  SmashMapWidget({Key? key})
      : super(key: key != null ? key : ValueKey("SMASH_MAPVIEW"));

  /// Set the initial parameters for the map.
  ///
  /// The [centerCoordinate] is the initial center of the map.
  /// The [initBounds] is the initial bounds of the map.
  /// The [constraintBounds] is the bounds that the map cannot go outside of.
  /// The [crs] is the coordinate reference system of the map.
  /// The [initZoom] is the initial zoom level of the map.
  /// The [minZoom] is the minimum zoom level of the map.
  /// The [maxZoom] is the maximum zoom level of the map.
  /// The [canRotate] is a boolean that indicates if the map can be rotated.
  /// The [canScrollWheelZoom] is a boolean that indicates if the map can be zoomed by wheel on desktop.
  /// The [useLayerManager] is a boolean that indicates if the map should use the layer manager or layers are added manually.
  /// The [addBorder] is a boolean that indicates if the map should have a border.
  void setInitParameters({
    JTS.Coordinate? centerCoordinate,
    JTS.Envelope? initBounds,
    JTS.Envelope? constraintBounds,
    Crs? crs,
    double? initZoom,
    double? minZoom,
    double? maxZoom,
    bool canRotate = false,
    bool canScrollWheelZoom = true,
    bool useLayerManager = true,
    bool addBorder = false,
  }) {
    if (centerCoordinate != null) _initCenterCoordonate = centerCoordinate;
    if (initBounds != null) _initBounds = initBounds;
    if (constraintBounds != null) _constraintBounds = constraintBounds;
    if (crs != null) _crs = crs;
    if (initZoom != null) _initZoom = initZoom;
    if (minZoom != null) _minZoom = minZoom;
    if (maxZoom != null) _maxZoom = maxZoom;
    _canRotate = canRotate;
    _useLayerManager = useLayerManager;
    _addBorder = addBorder;
    _canScrollWheelZoom = canScrollWheelZoom;
  }

  void setTapHandlers(
      {Function(LatLng, double)? handleTap,
      Function(LatLng, double)? handleLongTap}) {
    if (handleTap != null) _handleTap = handleTap;
    if (handleLongTap != null) _handleLongTap = handleLongTap;
  }

  void setOnMapReady(Function()? onMapReady) {
    if (onMapReady != null) _onMapReady = onMapReady;
  }

  bool isMapReady() {
    return _isMapReady;
  }

  void setOnPositionChanged(Function(MapCamera, bool)? onPositionChanged) {
    if (onPositionChanged != null) _onPositionChanged = onPositionChanged;
  }

  void setAttributionsAndUrls(List<List<String?>> attributionsAndUrls,
      {AttributionAlignment alignment = AttributionAlignment.bottomRight}) {
    _attributionsAndUrls = attributionsAndUrls;
    _attributionAlignment = alignment;
  }

  /// Clear all layers list (pre, post and manual [LayerSource]s).
  void clearLayers() {
    preLayers.clear();
    postLayers.clear();
    layerSources.clear();
  }

  /// Add a [LayerSource]. If [_useLayerManager] is set to false,
  /// this creates a custom datasource list to be used (in case the common
  /// layers are not wanted in a different map view).
  void addLayerSource(LayerSource layerSource) {
    if (_useLayerManager) {
      LayerManager().addLayerSource(layerSource);
    } else if (!layerSources.contains(layerSource)) {
      layerSources.add(layerSource);
    }
  }

  void removeLayerSource(LayerSource layerSource) {
    if (_useLayerManager) {
      LayerManager().removeLayerSource(layerSource);
    } else if (layerSources.contains(layerSource)) {
      layerSources.remove(layerSource);
    }
  }

  /// Add a layer to the list of layers that is loaded before
  /// the [LayerManager] layers.
  void addPreLayer(Widget layer) {
    int index = _getLayerIndex(preLayers, layer);
    if (index != -1) {
      preLayers[index] = layer;
    } else {
      preLayers.add(layer);
    }
  }

  /// Add a layer to the list of layers that is loaded after
  /// the [LayerManager] layers.
  void addPostLayer(Widget layer) {
    int index = _getLayerIndex(postLayers, layer);
    if (index != -1) {
      postLayers[index] = layer;
    } else {
      postLayers.add(layer);
    }
  }

  void clearPostLayers() {
    postLayers.clear();
  }

  int _getLayerIndex(List<Widget> list, Widget layer) {
    int i = 0;
    for (var item in list) {
      if (item.key == layer.key) {
        return i;
      }
      i++;
    }
    return -1;
  }

  /// Rebuild the map view, loading new layers and refreshing the view.
  void triggerRebuild(BuildContext context) {
    Provider.of<SmashMapBuilder>(context, listen: false).reBuild();
  }

  void zoomToBounds(JTS.Envelope bounds) {
    _mapController.fitCamera(CameraFit.bounds(
      bounds: LatLngBounds(
        LatLng(bounds.getMinY(), bounds.getMinX()),
        LatLng(bounds.getMaxY(), bounds.getMaxX()),
      ),
    ));
  }

  void centerOn(JTS.Coordinate ll) {
    _mapController.move(
        LatLngExt.fromCoordinate(ll), _mapController.camera.zoom);
  }

  void zoomTo(double newZoom) {
    _mapController.move(_mapController.camera.center, newZoom);
  }

  void zoomIn() {
    var z = _mapController.camera.zoom + 1;
    if (z > _maxZoom) z = _maxZoom;
    zoomTo(z);
  }

  void zoomOut() {
    var z = _mapController.camera.zoom - 1;
    if (z < _minZoom) z = _minZoom;
    zoomTo(z);
  }

  void centerAndZoomOn(JTS.Coordinate ll, double newZoom) {
    _mapController.move(LatLngExt.fromCoordinate(ll), newZoom);
  }

  void rotate(double heading) {
    _mapController.rotate(heading);
  }

  JTS.Envelope? getBounds() {
    return LatLngBoundsExt.fromBounds(_mapController.camera.visibleBounds)
        .toEnvelope();
  }

  /// Set a highlight geometry object or allow to set it to null to remove it.
  void setHighlightedGeometry(BuildContext context, HighlightedGeometry? geom) {
    highlightedGeometry = geom;
    triggerRebuild(context);
  }

  @override
  Widget build(BuildContext context) {
    consumerBuild = false;
    return Consumer<SmashMapBuilder>(builder: (context, mapBuilder, child) {
      consumerBuild = true;
      mapBuilder.context = context;
      // mapBuilder.scaffoldKey = _scaffoldKey;
      return consumeBuild(mapBuilder);
    });
  }

  Widget consumeBuild(SmashMapBuilder mapBuilder) {
    // print("SmashMapWidget consumeBuild");
    var layers = <Widget>[];

    layers.addAll(preLayers);
    if (_useLayerManager) {
      layers.addAll(LayerManager().getActiveLayers());
    } else {
      layers.addAll(layerSources
          .map((l) => SmashMapLayer(
                l,
                key: ValueKey(l.getName()),
              ))
          .toList());
    }
    layers.addAll(postLayers);

    BuildContext context = mapBuilder.context!;
    var mapState = Provider.of<SmashMapState>(context, listen: false);
    mapState.mapView = this;
    var mapFlags = InteractiveFlag.all &
        ~InteractiveFlag.flingAnimation &
        ~InteractiveFlag.pinchMove;
    if (!_canRotate) {
      mapFlags = mapFlags & ~InteractiveFlag.rotate;
    }
    if (!_canScrollWheelZoom) {
      mapFlags = mapFlags & ~InteractiveFlag.scrollWheelZoom;
    }

    // ! TODO check
    // GeometryEditorState editorState =
    //     Provider.of<GeometryEditorState>(context, listen: false);
    // if (editorState.isEnabled) {
    //   GeometryEditManager().startEditing(editorState.editableGeometry, () {
    //     // editorState.refreshEditLayer();
    //     triggerRebuild(context);
    //   });
    //   GeometryEditManager().addEditLayers(layers);
    // }
    var layerKey = "SmashMapEditLayer-${key.toString()}";
    layers.add(SmashMapEditLayer(
      key: ValueKey(layerKey),
    ));

    if (highlightedGeometry != null) {
      addHighlightLayer(layers);
    }

    // add attributions
    if (_attributionsAndUrls.isNotEmpty) {
      List<SourceAttribution> attributions = [];
      for (var attribution in _attributionsAndUrls) {
        if (attribution.length == 2 &&
            attribution[1] != null &&
            attribution[1]!.isNotEmpty) {
          attributions.add(TextSourceAttribution(
            attribution[0] ?? "",
            onTap: () {
              if (attribution[1] != null && attribution[1]!.isNotEmpty) {
                launchUrlString(attribution[1]!,
                    mode: LaunchMode.externalApplication);
              }
            },
            prependCopyright: false,
          ));
        } else if (attribution.length >= 1) {
          attributions.add(TextSourceAttribution(
            attribution[0] ?? "",
            prependCopyright: false,
          ));
        }
      }
      RichAttributionWidget richAttributionWidget = RichAttributionWidget(
        key: ValueKey("SmashMapAttribution-${key.toString()}"),
        attributions: attributions,
        showFlutterMapAttribution: false,
        alignment: _attributionAlignment,
      );
      layers.add(richAttributionWidget);
    }
    var mapKey = "FlutterMapWidget-${key.toString()}";
    flutterMap = FlutterMap(
      key: ValueKey(mapKey),
      options: new MapOptions(
        crs: _crs ?? Epsg3857(),
        initialCameraFit: _initBounds != null
            ? CameraFit.bounds(
                bounds: LatLngBounds(
                  LatLng(_initBounds!.getMinY(), _initBounds!.getMinX()),
                  LatLng(_initBounds!.getMaxY(), _initBounds!.getMaxX()),
                ),
              )
            : null,
        cameraConstraint: _constraintBounds != null
            ? CameraConstraint.contain(
                bounds: LatLngBounds(
                  LatLng(_constraintBounds!.getMinY(),
                      _constraintBounds!.getMinX()),
                  LatLng(_constraintBounds!.getMaxY(),
                      _constraintBounds!.getMaxX()),
                ),
              )
            : const CameraConstraint.unconstrained(),
        initialCenter: _initCenterCoordonate != null && _initBounds == null
            ? new LatLng(_initCenterCoordonate!.y, _initCenterCoordonate!.x)
            : const LatLng(46, 11),
        initialZoom: _initZoom,
        minZoom: _minZoom,
        maxZoom: _maxZoom,
        onPositionChanged: (newPosition, hasGesture) {
          _onPositionChanged(newPosition, hasGesture);
        },
        onMapEvent: (MapEvent mapEvent) {
          if (mapEvent is MapEventDoubleTapZoom ||
              mapEvent is MapEventScrollWheelZoom ||
              mapEvent is MapEventMove) {
            SmashMapState mapState =
                Provider.of<SmashMapState>(context, listen: false);
            mapState.notifyListenersMsg("manual zoom update");
          }
        },
        onTap: (TapPosition tPos, LatLng point) {
          _handleTap(point, _mapController.camera.zoom);
          if (highlightedGeometry != null) {
            highlightedGeometry = null;
            triggerRebuild(context);
          }
        },
        onLongPress: (TapPosition tPos, LatLng point) =>
            _handleLongTap(point, _mapController.camera.zoom),
        interactionOptions: InteractionOptions(
          flags: mapFlags,
        ),
        onMapReady: () {
          _isMapReady = true;
          _onMapReady();
        },
        backgroundColor: Colors.transparent,
      ),
      children: layers,
      mapController: _mapController,
    );

    Widget finalWidget = flutterMap!;
    if (_addBorder) {
      finalWidget = Container(
        child: flutterMap,
        decoration: BoxDecoration(
            color: SmashColors.mainBackground,
            border:
                Border.all(width: 1, color: SmashColors.mainDecorationsDarker)),
      );
    }
    return Stack(
      children: <Widget>[
        finalWidget,
        mapBuilder.inProgress
            ? Center(
                child: SmashCircularProgress(
                  label:
                      SLL.of(context).mainView_loadingData, //"Loading data...",
                ),
              )
            : SizedBox.shrink(),
        // Align(
        //   alignment: Alignment.bottomRight,
        //   child: _iconMode == IconMode.NAVIGATION_MODE
        //       ? IconButton(
        //           key: coachMarks.toolbarButtonKey,
        //           icon: Icon(
        //             MdiIcons.forwardburger,
        //             color: SmashColors.mainDecorations,
        //             size: 32,
        //           ),
        //           onPressed: () {
        //             setState(() {
        //               _iconMode = IconMode.TOOL_MODE;
        //             });
        //           },
        //         )
        //       : IconButton(
        //           icon: Icon(
        //             MdiIcons.backburger,
        //             color: SmashColors.mainDecorations,
        //             size: 32,
        //           ),
        //           onPressed: () {
        //             BottomToolbarToolsRegistry.disableAll(context);
        //             setState(() {
        //               _iconMode = IconMode.NAVIGATION_MODE;
        //             });
        //           },
        //         ),
        // )
      ],
    );
  }

  void addHighlightLayer(List<Widget> layers) {
    if (highlightedGeometry == null) return;
    var lines = <Polyline>[];
    var polygons = <Polygon>[];
    var points = <Marker>[];
    if (highlightedGeometry!.isPoint) {
      points = highlightedGeometry!.toMarkers();
    }
    if (highlightedGeometry!.isLine) {
      lines = highlightedGeometry!.tolines();
    }
    if (highlightedGeometry!.isPolygon) {
      polygons = highlightedGeometry!.toPolygons();
    }

    if (lines.isNotEmpty) {
      layers.add(PolylineLayer(
        polylines: lines,
      ));
    }
    if (polygons.isNotEmpty) {
      layers.add(PolygonLayer(
        polygons: polygons,
      ));
    }
    if (points.isNotEmpty) {
      layers.add(MarkerLayer(
        markers: points,
      ));
    }
  }
}
