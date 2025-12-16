import 'package:flet/flet.dart';
import 'package:flet_charts/flet_charts.dart' as flet_charts;
import 'package:flet_datatable2/flet_datatable2.dart' as flet_datatable2;
import 'package:flet_lottie/flet_lottie.dart' as flet_lottie;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const bool isProduction = bool.fromEnvironment('dart.vm.product');

Tester? tester;

void main([List<String>? args]) async {
  if (isProduction) {
    // ignore: avoid_returning_null_for_void
    debugPrint = (String? message, {int? wrapWidth}) => null;
  }

  await setupDesktop();

  WidgetsFlutterBinding.ensureInitialized();
  List<FletExtension> extensions = [
    flet_lottie.Extension(),
    flet_datatable2.Extension(),
    flet_charts.Extension(),
  ];

  // initialize extensions
  for (var extension in extensions) {
    extension.ensureInitialized();
  }

  var pageUrl = Uri.base.toString();
  var assetsDir = "";
  //debugPrint("Uri.base: ${Uri.base}");

  if (kDebugMode) {
    pageUrl = "http://localhost:8550";
  }

  if (kIsWeb) {
    debugPrint("Flet View is running in Web mode");
    var routeUrlStrategy = getFletRouteUrlStrategy();
    debugPrint("URL Strategy: $routeUrlStrategy");
    if (routeUrlStrategy == "path") {
      //usePathUrlStrategy();
    }
  } else {
    if (args!.isNotEmpty) {
      pageUrl = args[0];
      if (args.length > 1) {
        var pidFilePath = args[1];
        debugPrint("Args contain a path to PID file: $pidFilePath}");
        var pidFile = await File(pidFilePath).create();
        await pidFile.writeAsString("$pid");
      }
      if (args.length > 2) {
        assetsDir = args[2];
        debugPrint("Args contain a path assets directory: $assetsDir}");
      }
    } else if (!kDebugMode &&
        (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      throw Exception(
          'In desktop mode Flet app URL must be provided as a first argument.');
    }
  }

  debugPrint("Page URL: $pageUrl");

  FletAppErrorsHandler errorsHandler = FletAppErrorsHandler();

  if (!kDebugMode) {
    FlutterError.onError = (details) {
      errorsHandler.onError(details.exceptionAsString());
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      errorsHandler.onError(error.toString());
      return true;
    };
  }

  var app = FletApp(
    title: 'Flet',
    pageUrl: pageUrl,
    assetsDir: assetsDir,
    errorsHandler: errorsHandler,
    showAppStartupScreen: true,
    appStartupScreenMessage: "Working...",
    appErrorMessage: "The application encountered an error: {message}",
    extensions: extensions,
    multiView: isMultiView(),
    tester: tester,
  );

  if (app.multiView) {
    debugPrint("Flet Web Multi-View mode");
    runWidget(app);
  } else {
    runApp(app);
  }
}
