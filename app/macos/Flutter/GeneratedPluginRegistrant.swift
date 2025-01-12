//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

// Importing required Flutter plugins for macOS platform.
import connectivity_plus
import desktop_drop
import device_info_plus
import dynamic_color
import file_selector_macos
import gal
import in_app_purchase_storekit
import network_info_plus
import package_info_plus
import pasteboard
import path_provider_foundation
import photo_manager
import screen_retriever
import shared_preferences_foundation
import tray_manager
import uri_content
import url_launcher_macos
import video_player_avfoundation
import wakelock_plus
import window_manager

// A function to register all the plugins with the Flutter plugin registry.
func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  // Registering the Connectivity Plus plugin for network connectivity status.
  ConnectivityPlusPlugin.register(with: registry.registrar(forPlugin: "ConnectivityPlusPlugin"))
  
  // Registering the Desktop Drop plugin for drag-and-drop functionality on desktop.
  DesktopDropPlugin.register(with: registry.registrar(forPlugin: "DesktopDropPlugin"))
  
  // Registering the Device Info Plus plugin for accessing device-specific information.
  DeviceInfoPlusMacosPlugin.register(with: registry.registrar(forPlugin: "DeviceInfoPlusMacosPlugin"))
  
  // Registering the Dynamic Color plugin for system theme-based color support.
  DynamicColorPlugin.register(with: registry.registrar(forPlugin: "DynamicColorPlugin"))
  
  // Registering the File Selector plugin for file selection functionality.
  FileSelectorPlugin.register(with: registry.registrar(forPlugin: "FileSelectorPlugin"))
  
  // Registering the Gal plugin for additional image handling features.
  GalPlugin.register(with: registry.registrar(forPlugin: "GalPlugin"))
  
  // Registering the In-App Purchase plugin for handling in-app purchases on macOS.
  InAppPurchasePlugin.register(with: registry.registrar(forPlugin: "InAppPurchasePlugin"))
  
  // Registering the Network Info Plus plugin for network information like IP addresses.
  NetworkInfoPlusPlugin.register(with: registry.registrar(forPlugin: "NetworkInfoPlusPlugin"))
  
  // Registering the Package Info Plus plugin for accessing app package information.
  FPPPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FPPPackageInfoPlusPlugin"))
  
  // Registering the Pasteboard plugin for clipboard and pasteboard functionalities.
  PasteboardPlugin.register(with: registry.registrar(forPlugin: "PasteboardPlugin"))
  
  // Registering the Path Provider plugin for access to file system paths.
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  
  // Registering the Photo Manager plugin for accessing and managing photos.
  PhotoManagerPlugin.register(with: registry.registrar(forPlugin: "PhotoManagerPlugin"))
  
  // Registering the Screen Retriever plugin for screen management.
  ScreenRetrieverPlugin.register(with: registry.registrar(forPlugin: "ScreenRetrieverPlugin"))
  
  // Registering the Shared Preferences plugin for lightweight storage of key-value pairs.
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  
  // Registering the Tray Manager plugin for system tray management features.
  TrayManagerPlugin.register(with: registry.registrar(forPlugin: "TrayManagerPlugin"))
  
  // Registering the URI Content plugin for handling URI-based content.
  UriContentPlugin.register(with: registry.registrar(forPlugin: "UriContentPlugin"))
  
  // Registering the URL Launcher plugin for launching URLs in the browser.
  UrlLauncherPlugin.register(with: registry.registrar(forPlugin: "UrlLauncherPlugin"))
  
  // Registering the Video Player plugin for video playback.
  FVPVideoPlayerPlugin.register(with: registry.registrar(forPlugin: "FVPVideoPlayerPlugin"))
  
  // Registering the Wakelock Plus plugin for preventing the device from going to sleep.
  WakelockPlusMacosPlugin.register(with: registry.registrar(forPlugin: "WakelockPlusMacosPlugin"))
  
  // Registering the Window Manager plugin for managing application windows.
  WindowManagerPlugin.register(with: registry.registrar(forPlugin: "WindowManagerPlugin"))
}
