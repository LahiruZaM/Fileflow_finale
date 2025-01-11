part of 'about_page.dart';

/// Packagers who distribute the app.
/// Also write your full name here if you want.
/// 
/// The keys represent various distribution platforms.
/// The values are lists of contributors or maintainers
/// who manage the packaging for the respective platforms.

const _packagers = <String, List<String>>{
  // Chocolatey - A Windows package manager
  'Chocolatey': [
    '@brogers5', // Maintainer for Chocolatey
  ],

  // Winget - Windows Package Manager CLI
  'Winget': [
    '@sitiom',   // Maintainer for Winget
    '@Tienisto', // Co-maintainer for Winget
  ],

  // Scoop - A command-line installer for Windows
  'Scoop': [
    '@sitiom', // Maintainer for Scoop
  ],

  // Homebrew - The macOS package manager
  'Homebrew': [
    '@Tienisto', // Maintainer for Homebrew
  ],

  // Flathub - Centralized Flatpak repository
  'Flathub': [
    '@proletarius101', // Maintainer for Flathub
    '@Tienisto',       // Co-maintainer for Flathub
  ],

  // Nix - A package manager for Linux and macOS
  'Nix': [
    '@sikmir', // Maintainer for Nix
    '@linsui', // Co-maintainer for Nix
  ],

  // Snapcraft - Snap package manager for Linux
  'Snapcraft': [
    '@thatLeaflet', // Maintainer for Snapcraft
  ],

  // AUR - Arch User Repository
  'AUR': [
    '@Nixuge', // Maintainer for AUR
  ],

  // F-Droid - Open-source app repository for Android
  'F-Droid': [
    '@linsui',   // Maintainer for F-Droid
    '@Tienisto', // Co-maintainer for F-Droid
  ],
};
