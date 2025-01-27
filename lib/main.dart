import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'domain/i_settings_repository.dart';
import 'infrastructure/core/injection.dart';
import 'presentation/routes/app_routes.gr.dart' as app_router;
import 'presentation/themes/themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  configureInjection();
  // Instantiate to trigger update of remote configs
  getIt<ISettingsRepository>();

  runApp(AppWidget());
}

class AppWidget extends StatelessWidget {
  final _appRouter = app_router.AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      color: Colors.white,
      title: 'CollAction',
      theme: lightTheme(context),
      debugShowCheckedModeBanner: false,
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}
