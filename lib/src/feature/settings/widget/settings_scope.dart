import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:sizzle_starter/src/core/utils/extensions/context_extension.dart';
import 'package:sizzle_starter/src/feature/app/model/app_theme.dart';
import 'package:sizzle_starter/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:sizzle_starter/src/feature/settings/bloc/settings_controller.dart';

/// {@template theme_scope_controller}
/// A controller that holds and operates the app theme.
/// {@endtemplate}
abstract interface class ThemeScopeController {
  /// Get the current [AppTheme].
  AppTheme get theme;

  /// Set the theme mode to [themeMode].
  void setThemeMode(ThemeMode themeMode);

  /// Set the theme accent color to [color].
  void setThemeSeedColor(Color color);
}

/// {@template locale_scope_controller}
/// A controller that holds and operates the app locale.
/// {@endtemplate}
abstract interface class LocaleScopeController {
  /// Get the current [Locale]
  Locale get locale;

  /// Set locale to [locale].
  void setLocale(Locale locale);
}

/// {@template settings_scope_controller}
/// A controller that holds and operates the app settings.
/// {@endtemplate}
abstract interface class SettingsScopeController
    implements ThemeScopeController, LocaleScopeController {}

enum _SettingsScopeAspect {
  /// The theme aspect.
  theme,

  /// The locale aspect.
  locale;
}

/// {@template settings_scope}
/// Settings scope is responsible for handling settings-related stuff.
///
/// For example, it holds facilities to change
/// - theme seed color
/// - theme mode
/// - locale
/// {@endtemplate}
class SettingsScope extends StatefulWidget {
  /// {@macro settings_scope}
  const SettingsScope({required this.child, super.key});

  /// The child widget.
  final Widget child;

  /// Get the [SettingsScopeController] of the closest [SettingsScope] ancestor.
  static SettingsScopeController of(
    BuildContext context, {
    bool listen = true,
  }) =>
      context.inhOf<_InheritedSettingsScope>(listen: listen).controller;

  /// Get the [ThemeScopeController] of the closest [SettingsScope] ancestor.
  static ThemeScopeController themeOf(BuildContext context) => context
      .inheritFrom<_SettingsScopeAspect, _InheritedSettingsScope>(
        aspect: _SettingsScopeAspect.theme,
      )
      .controller;

  /// Get the [LocaleScopeController] of the closest [SettingsScope] ancestor.
  static LocaleScopeController localeOf(BuildContext context) => context
      .inheritFrom<_SettingsScopeAspect, _InheritedSettingsScope>(
        aspect: _SettingsScopeAspect.locale,
      )
      .controller;

  @override
  State<SettingsScope> createState() => _SettingsScopeState();
}

/// State for widget SettingsScope
class _SettingsScopeState extends State<SettingsScope>
    implements SettingsScopeController {
  late final SettingsController _settingsController;

  @override
  void initState() {
    super.initState();
    _settingsController = SettingsController(
      DependenciesScope.of(context).settingsRepository,
    );
  }

  @override
  void dispose() {
    _settingsController.dispose();
    super.dispose();
  }

  @override
  void setLocale(Locale locale) {
    _settingsController.updateLocale(locale: locale);
  }

  @override
  void setThemeMode(ThemeMode themeMode) {
    _settingsController.updateTheme(
      appTheme: AppTheme(mode: themeMode, seed: theme.seed),
    );
  }

  @override
  void setThemeSeedColor(Color color) {
    _settingsController.updateTheme(
      appTheme: AppTheme(mode: theme.mode, seed: color),
    );
  }

  @override
  Locale get locale => _settingsController.state.locale;

  @override
  AppTheme get theme => _settingsController.state.appTheme;

  @override
  Widget build(BuildContext context) =>
      StateConsumer<SettingsController, SettingsState>(
        controller: _settingsController,
        builder: (context, state, _) => _InheritedSettingsScope(
          controller: this,
          state: state,
          child: widget.child,
        ),
      );
}

class _InheritedSettingsScope extends InheritedModel<_SettingsScopeAspect> {
  const _InheritedSettingsScope({
    required this.controller,
    required this.state,
    required super.child,
  });

  final SettingsScopeController controller;
  final SettingsState state;

  @override
  bool updateShouldNotify(_InheritedSettingsScope oldWidget) =>
      state != oldWidget.state;

  @override
  bool updateShouldNotifyDependent(
    covariant _InheritedSettingsScope oldWidget,
    Set<_SettingsScopeAspect> dependencies,
  ) {
    var shouldNotify = false;

    if (dependencies.contains(_SettingsScopeAspect.theme)) {
      shouldNotify = shouldNotify || state.appTheme != oldWidget.state.appTheme;
    }

    if (dependencies.contains(_SettingsScopeAspect.locale)) {
      final locale = state.locale.languageCode;
      final oldLocale = oldWidget.state.locale.languageCode;

      shouldNotify = shouldNotify || locale != oldLocale;
    }

    return shouldNotify;
  }
}
