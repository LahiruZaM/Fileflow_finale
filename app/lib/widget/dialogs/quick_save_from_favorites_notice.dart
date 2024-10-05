import 'package:fileflow/gen/strings.g.dart';
import 'package:fileflow/util/native/platform_check.dart';
import 'package:fileflow/widget/dialogs/custom_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:routerino/routerino.dart';

class QuickSaveFromFavoritesNotice extends StatelessWidget {
  const QuickSaveFromFavoritesNotice({super.key});

  static Future<void> open(BuildContext context) async {
    if (checkPlatformIsDesktop()) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(t.dialogs.quickSaveFromFavoritesNotice.title),
          content: Text(t.dialogs.quickSaveFromFavoritesNotice.content),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text(t.general.close),
            )
          ],
        ),
      );
    } else {
      await context.pushBottomSheet(() => const QuickSaveFromFavoritesNotice());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      title: t.dialogs.quickSaveFromFavoritesNotice.title,
      description: t.dialogs.quickSaveFromFavoritesNotice.content,
      child: Center(
        child: ElevatedButton(
          onPressed: () => context.popUntilRoot(),
          child: Text(t.general.close),
        ),
      ),
    );
  }
}
