import 'package:fileflow/gen/strings.g.dart';
import 'package:fileflow/model/persistence/color_mode.dart';
import 'package:fileflow/provider/device_info_provider.dart';
import 'package:fileflow/util/native/platform_check.dart';
import 'package:fileflow/util/ui/dynamic_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:yaru/yaru.dart' as yaru;

final _borderRadius = BorderRadius.circular(5); // Define border radius for rounded corners

/// On desktop, we need to add additional padding to achieve the same visual appearance as on mobile
double get desktopPaddingFix => checkPlatformIsDesktop() ? 8 : 0; // Adjust padding for desktop platforms

// Function to get the theme data based on color mode and brightness
ThemeData getTheme(ColorMode colorMode, Brightness brightness, DynamicColors? dynamicColors) {

  // Determine the color scheme based on color mode, brightness, and dynamic colors
  final colorScheme = _determineColorScheme(colorMode, brightness, dynamicColors);

  // Define the light input border style
  final lightInputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: colorScheme.secondaryContainer),
    borderRadius: _borderRadius,
  );

  // Define the dark input border style
  final darkInputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: colorScheme.secondaryContainer),
    borderRadius: _borderRadius,
  );

  // Handle platform-specific font settings
  final String? fontFamily;
  if (checkPlatform([TargetPlatform.windows])) {
    fontFamily = switch (LocaleSettings.currentLocale) {
      AppLocale.ja => 'Yu Gothic UI',
      AppLocale.ko => 'Malgun Gothic',
      AppLocale.zhCn => 'Microsoft YaHei UI',
      AppLocale.zhHk || AppLocale.zhTw => 'Microsoft JhengHei UI',
      _ => 'Segoe UI Variable Display',
    };
  } else {
    fontFamily = null; // No special font for non-Windows platforms
  }

  // Return the theme data object with customized settings
  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true, // Enable Material 3 design
    navigationBarTheme: colorScheme.brightness == Brightness.dark
        ? NavigationBarThemeData(
            iconTheme: WidgetStateProperty.all(const IconThemeData(color: Colors.white)),
          )
        : null,
    inputDecorationTheme: InputDecorationTheme(
      filled: true, // Set filled input fields
      fillColor: colorScheme.secondaryContainer, // Set fill color for input fields
      border: colorScheme.brightness == Brightness.light ? lightInputBorder : darkInputBorder, // Set border based on brightness
      focusedBorder: colorScheme.brightness == Brightness.light ? lightInputBorder : darkInputBorder, // Set border for focused state
      enabledBorder: colorScheme.brightness == Brightness.light ? lightInputBorder : darkInputBorder, // Set border for enabled state
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10), // Set content padding inside input fields
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: colorScheme.brightness == Brightness.dark ? Colors.white : null, // Set text color for elevated buttons
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8 + desktopPaddingFix), // Set padding for elevated buttons
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8 + desktopPaddingFix), // Set padding for text buttons
      ),
    ),
    fontFamily: fontFamily, // Set the font family based on platform and locale
  );
}

// Function to update the system overlay style based on the context's theme
Future<void> updateSystemOverlayStyle(BuildContext context) async {
  final brightness = Theme.of(context).brightness; // Get the current brightness
  await updateSystemOverlayStyleWithBrightness(brightness); // Update the system overlay style with the brightness
}

// Function to update system overlay style for Android based on brightness
Future<void> updateSystemOverlayStyleWithBrightness(Brightness brightness) async {
  if (checkPlatform([TargetPlatform.android])) {
    // For Android, handle edge-to-edge style and system UI overlays
    final darkMode = brightness == Brightness.dark;
    final androidSdkInt = RefenaScope.defaultRef.read(deviceInfoProvider).androidSdkInt ?? 0;
    final bool edgeToEdge = androidSdkInt >= 29;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // Enable edge-to-edge system UI mode

    // Update system UI overlay style based on brightness and edge-to-edge mode
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Make status bar transparent
      statusBarIconBrightness: brightness == Brightness.light ? Brightness.dark : Brightness.light, // Set icon brightness based on theme
      systemNavigationBarColor: edgeToEdge ? Colors.transparent : (darkMode ? Colors.black : Colors.white), // Set navigation bar color
      systemNavigationBarContrastEnforced: false,
      systemNavigationBarIconBrightness: darkMode ? Brightness.light : Brightness.dark, // Set navigation bar icon brightness
    ));
  } else {
    // For non-Android platforms (like iOS), set the system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: brightness, // Set status bar brightness for iOS
      statusBarColor: Colors.transparent, // Not relevant to this issue
    ));
  }
}

// Extension on ThemeData to get the actual card color with elevation
extension ThemeDataExt on ThemeData {
  Color get cardColorWithElevation {
    return ElevationOverlay.applySurfaceTint(cardColor, colorScheme.surfaceTint, 1); // Apply elevation tint to card color
  }
}

// Extension on ColorScheme to define custom colors like 'warning'
extension ColorSchemeExt on ColorScheme {
  Color get warning {
    return Colors.orange; // Custom 'warning' color
  }

  Color? get secondaryContainerIfDark {
    return brightness == Brightness.dark ? secondaryContainer : null; // Return secondary container color if dark theme
  }

  Color? get onSecondaryContainerIfDark {
    return brightness == Brightness.dark ? onSecondaryContainer : null; // Return on secondary container color if dark theme
  }
}

// Extension on InputDecorationTheme to access the border radius
extension InputDecorationThemeExt on InputDecorationTheme {
  BorderRadius get borderRadius => _borderRadius; // Access border radius value
}

// Function to determine the appropriate color scheme based on color mode, brightness, and dynamic colors
ColorScheme _determineColorScheme(ColorMode mode, Brightness brightness, DynamicColors? dynamicColors) {
  final defaultColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.blue, // Set seed color for color scheme
    brightness: brightness, // Use brightness to determine light or dark theme
  );

  final colorScheme = switch (mode) {
    ColorMode.system => brightness == Brightness.light ? dynamicColors?.light : dynamicColors?.dark, // Use dynamic colors based on brightness
    ColorMode.FileFlow => null, // Handle FileFlow mode (default case)
  };

  return colorScheme ?? defaultColorScheme; // Return color scheme or default if null
}
