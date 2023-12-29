import 'package:control/control.dart';
import 'package:sizzle_starter/src/core/utils/logger.dart';

/// Observer for [Controller], react to changes in the any controller.
final class AppControlObserver implements IControllerObserver {
  /// Create a new [AppControlObserver]
  const AppControlObserver();

  @override
  void onError(Controller controller, Object error, StackTrace stackTrace) {
    logger.error(
      'Controller: ${controller.runtimeType} | $error',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void onCreate(Controller controller) {
    logger.info(
      'Controller: ${controller.runtimeType} | Created',
    );
  }

  @override
  void onDispose(Controller controller) {
    logger.info(
      'Controller: ${controller.runtimeType} | Disposed',
    );
  }

  @override
  void onStateChanged<S extends Object>(
    StateController<S> controller,
    S prevState,
    S nextState,
  ) {
    logger.debug(
      'Controller: ${controller.runtimeType} | $prevState -> $nextState',
    );
  }
}
