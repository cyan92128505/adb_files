import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/app_state_manager.dart';
import 'navigation/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppRouter _appRouter;
  late AppStateManager _appStateManager;
  final DeviceManager _deviceManager = DeviceManager();

  @override
  void initState() {
    _appStateManager = AppStateManager(device: _deviceManager.active);
    _appRouter = AppRouter(appStateManager: _appStateManager);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DeviceManager>(
            lazy: false, create: (_) => _deviceManager),
        ChangeNotifierProxyProvider<DeviceManager, AppStateManager>(
          lazy: false,
          create: (_) => _appStateManager,
          update: (context, deviceManager, previous) =>
              previous!..setDevice(deviceManager.active),
        ),
        ChangeNotifierProvider<MoveCopyManager>(
            lazy: false, create: (_) => MoveCopyManager()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Router(
          routerDelegate: _appRouter,
          backButtonDispatcher: RootBackButtonDispatcher(),
        ),
      ),
    );
  }
}
