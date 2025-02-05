import 'package:common/isolate.dart';
import 'package:fileflow/config/init.dart';
import 'package:fileflow/config/init_error.dart';
import 'package:fileflow/config/theme.dart';
import 'package:fileflow/gen/strings.g.dart';
import 'package:fileflow/pages/home_page.dart';
import 'package:fileflow/provider/local_ip_provider.dart';
import 'package:fileflow/provider/settings_provider.dart';
import 'package:fileflow/util/ui/dynamic_colors.dart';
import 'package:fileflow/widget/watcher/life_cycle_watcher.dart';
import 'package:fileflow/widget/watcher/shortcut_watcher.dart';
import 'package:fileflow/widget/watcher/tray_watcher.dart';
import 'package:fileflow/widget/watcher/window_watcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';

Future<void> main(List<String> args) async {
  final RefenaContainer container;
  try {
    container = await preInit(args);
  } catch (e, stackTrace) {
    showInitErrorApp(
      error: e,
      stackTrace: stackTrace,
    );
    return;
  }

  runApp(RefenaScope.withContainer(
    container: container,
    child: TranslationProvider(
      child: const FileFlowApp(),
    ),
  ));
}

class FileFlowApp extends StatelessWidget {
  const FileFlowApp();

  @override
  Widget build(BuildContext context) {
    final ref = context.ref;
    final (themeMode, colorMode) = ref.watch(settingsProvider.select((settings) => (settings.theme, settings.colorMode)));
    final dynamicColors = ref.watch(dynamicColorsProvider);
    return TrayWatcher(
      child: WindowWatcher(
        child: LifeCycleWatcher(
          onChangedState: (AppLifecycleState state) {
            switch (state) {
              case AppLifecycleState.resumed:
                ref.redux(localIpProvider).dispatch(InitLocalIpAction());
                break;
              case AppLifecycleState.detached:
                // The main isolate is only exited when all child isolates are exited.
                // https://github.com/FileFlow/FileFlow/issues/1568
                ref.redux(parentIsolateProvider).dispatch(IsolateDisposeAction());
                break;
              default:
                break;
            }
          },
          child: ShortcutWatcher(
            child: MaterialApp(
              title: t.appName,
              locale: TranslationProvider.of(context).flutterLocale,
              supportedLocales: AppLocaleUtils.supportedLocales,
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              debugShowCheckedModeBanner: false,
              theme: getTheme(colorMode, Brightness.light, dynamicColors),
              darkTheme: getTheme(colorMode, Brightness.dark, dynamicColors),
              themeMode: themeMode,
              navigatorKey: Routerino.navigatorKey,
              home: RouterinoHome(
                builder: () => const HomePage(
                  initialTab: HomeTab.receive,
                  appStart: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
