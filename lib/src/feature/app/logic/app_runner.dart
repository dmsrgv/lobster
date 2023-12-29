import 'dart:async';

import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sizzle_starter/src/core/utils/app_control_observer.dart';
import 'package:sizzle_starter/src/core/utils/logger.dart';
import 'package:sizzle_starter/src/feature/app/widget/app.dart';
import 'package:sizzle_starter/src/feature/initialization/logic/initialization_processor.dart';
import 'package:sizzle_starter/src/feature/initialization/logic/initialization_steps.dart';
import 'package:sizzle_starter/src/feature/initialization/model/initialization_hook.dart';

/// A class which is responsible for initialization and running the app.
final class AppRunner
    with
        InitializationSteps,
        InitializationProcessor,
        InitializationFactoryImpl {
  /// Start the initialization and in case of success run application
  Future<void> initializeAndRun(InitializationHook hook) async {
    final bindings = WidgetsFlutterBinding.ensureInitialized();

    FlutterNativeSplash.preserve(widgetsBinding: bindings);

    FlutterError.onError = logger.logFlutterError;
    WidgetsBinding.instance.platformDispatcher.onError =
        logger.logPlatformDispatcherError;

    Controller.observer = const AppControlObserver();

    final result = await processInitialization(
      steps: initializationSteps,
      hook: hook,
      factory: this,
    );

    // Allow rendering
    FlutterNativeSplash.remove();

    // Attach this widget to the root of the tree.
    App(result: result).attach();
  }
}
