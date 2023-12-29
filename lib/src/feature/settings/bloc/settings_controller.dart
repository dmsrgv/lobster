import 'package:control/control.dart';
import 'package:flutter/material.dart' show Locale;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sizzle_starter/src/core/localization/localization.dart';
import 'package:sizzle_starter/src/feature/app/model/app_theme.dart';
import 'package:sizzle_starter/src/feature/settings/data/settings_repository.dart';

part 'settings_controller.freezed.dart';

/// States for the [SettingsController].
@freezed
sealed class SettingsState with _$SettingsState {
  const SettingsState._();

  /// Idle state for the [SettingsController].
  const factory SettingsState.idle({
    /// The current locale.
    required Locale locale,

    /// The current theme mode.
    required AppTheme appTheme,
  }) = _IdleSettingsState;

  /// Processing state for the [SettingsController].
  const factory SettingsState.processing({
    /// The current locale.
    required Locale locale,

    /// The current theme mode.
    required AppTheme appTheme,
  }) = _ProcessingSettingsState;

  /// Error state for the [SettingsController].
  const factory SettingsState.error({
    /// The current locale.
    required Locale locale,

    /// The current theme mode.
    required AppTheme appTheme,

    /// The error message.
    required String message,
  }) = _ErrorSettingsState;
}

/// A [Controller] that handles the settings.
final class SettingsController extends StateController<SettingsState>
    with SequentialControllerHandler {
  /// OK
  SettingsController(this._settingsRepository)
      : super(
          initialState: SettingsState.idle(
            appTheme: _settingsRepository.fetchThemeFromCache() ??
                AppTheme.defaultTheme,
            locale: _settingsRepository.fetchLocaleFromCache() ??
                Localization.computeDefaultLocale(),
          ),
        );

  final SettingsRepository _settingsRepository;

  /// Update theme
  void updateTheme({required AppTheme appTheme}) => handle(() async {
        setState(
          SettingsState.processing(
            locale: state.locale,
            appTheme: state.appTheme,
          ),
        );

        try {
          await _settingsRepository.setTheme(appTheme);

          setState(
            SettingsState.idle(
              appTheme: appTheme,
              locale: state.locale,
            ),
          );
        } catch (e) {
          setState(
            SettingsState.error(
              locale: state.locale,
              appTheme: state.appTheme,
              message: e.toString(),
            ),
          );
          rethrow;
        }
      });

  /// Update locale
  void updateLocale({required Locale locale}) => handle(() async {
        setState(
          _ProcessingSettingsState(
            appTheme: state.appTheme,
            locale: state.locale,
          ),
        );

        try {
          await _settingsRepository.setLocale(locale);

          setState(
            SettingsState.idle(appTheme: state.appTheme, locale: locale),
          );
        } on Object catch (e) {
          setState(
            SettingsState.error(
              appTheme: state.appTheme,
              locale: state.locale,
              message: e.toString(),
            ),
          );
          rethrow;
        }
      });
}
