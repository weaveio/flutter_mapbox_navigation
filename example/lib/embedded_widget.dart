import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';

class EmbeddedWidget extends StatefulWidget {
  const EmbeddedWidget({Key? key}) : super(key: key);

  @override
  State<EmbeddedWidget> createState() => _EmbeddedWidgetState();
}

class _EmbeddedWidgetState extends State<EmbeddedWidget> {
  MapBoxNavigationViewController? _viewController;
  final _options = MapBoxNavigation.instance.getDefaultOptions();

  final _home = WayPoint(
      name: "Home",
      latitude: 37.31205960038342,
      longitude: -121.96555237126196,
      isSilent: false);

  final _store = WayPoint(
      name: "Store",
      latitude: 37.28678446449039,
      longitude: -121.8735955773303,
      isSilent: false);

  bool _canNavigate = false;
  bool _showView = false;

  @override
  void initState() {
    super.initState();

    initialize();
  }

  void initialize() {
    _options.simulateRoute = true;
    _options.zoom = 15.0;

    MapBoxNavigation.instance.registerRouteEventListener(_onEmbeddedRouteEvent);
    MapBoxNavigation.instance.setDefaultOptions(_options);

    // MapBoxNavigation.instance.startNavigation(
    //   wayPoints: [
    //     _home,
    //     _store,
    //   ],
    // );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black26,
        body: Stack(
          children: [
            _embeddedView(),
            Positioned(
              right: 50.0,
              bottom: 50.0,
              child: TextButton(
                onPressed: _canNavigate ? () => _start() : null,
                child: const Text('Start navigation'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _embeddedView() {
    return MapBoxNavigationView(
      options: _options,
      onRouteEvent: _onEmbeddedRouteEvent,
      onCreated: _initController,
    );
  }

  Future<void> _start() async {
    // setState(() {
    //   _canNavigate = true;
    // });
    print("buiding route");
    final result = await _viewController?.buildRoute(
      wayPoints: [
        _home,
        _store,
      ],
      options: _options,
    );

    print("build result: $result");

    if (result == true) {
      _viewController!.startNavigation(options: _options);
    } else {
      print("*****build result failed***************");
    }
  }

  Future<void> _initController(
      MapBoxNavigationViewController controller) async {
    _viewController = controller;
    await _viewController!.initialize();

    print("control init!!!");

    setState(() {
      _canNavigate = true;
    });

    if (_canNavigate) {
      _start();
    }
  }

  Future<void> _onEmbeddedRouteEvent(RouteEvent e) async {
    print("on event: ${e.eventType}");

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        if (e.data is String && (e.data as String).isNotEmpty) {
          final m = jsonDecode(e.data);

          if (m is List && m.isNotEmpty) {
            final f = m.first;

            if (f is Map) {
              print('distance in meters: ${f['distance']}');
              print('duration: ${f['duration']}');
            }
          }
        }

        break;
      case MapBoxEvent.route_build_failed:
        print(e);
        print('route building failed');
        break;
      case MapBoxEvent.navigation_running:
      case MapBoxEvent.on_arrival:
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        break;
      default:
        break;
    }
  }
}
