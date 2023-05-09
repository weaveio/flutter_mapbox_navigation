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
  //MapBoxNavigationViewController? _viewController;
  final _options = MapBoxNavigation.instance.getDefaultOptions();

  final _home = WayPoint(
      name: "Home",
      latitude: 37.77440680146262,
      longitude: -122.43539772352648,
      isSilent: false);

  final _store = WayPoint(
      name: "Store",
      latitude: 37.76556957793795,
      longitude: -122.42409811526268,
      isSilent: false);

  bool _navStarted = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    _options.simulateRoute = false;

    MapBoxNavigation.instance.registerRouteEventListener(_onEmbeddedRouteEvent);
    MapBoxNavigation.instance.setDefaultOptions(_options);

    String? platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await MapBoxNavigation.instance.getPlatformVersion();
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    print("Platform version: $platformVersion");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            _embeddedView(),
            // const Center(
            //   child: Text(
            //     'Ready!',
            //     style: TextStyle(
            //       color: Colors.red,
            //       fontSize: 32.0,
            //     ),
            //   ),
            // ),
            // Positioned(
            //     right: 50.0,
            //     bottom: 50.0,
            //     child: TextButton(
            //         onPressed: () => _start(), child: const Text('Start'))),
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
    final b = await MapBoxNavigation.instance.startNavigation(
      wayPoints: [
        _home,
        _store,
      ],
      options: _options,
    );

    print(b);

    setState(() {
      _navStarted = true;
    });
    //_viewController!.startNavigation(options: _options);
  }

  Future<void> _initController(
      MapBoxNavigationViewController controller) async {
    print("init!!!");
    //  _viewController = controller;
    // await _viewController!.initialize();
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
