
import 'package:fileflow/gen/strings.g.dart';
import 'package:fileflow/provider/network/server/server_provider.dart';
import 'package:fileflow/provider/selection/selected_receiving_files_provider.dart';
import 'package:fileflow/util/file_size_helper.dart';
import 'package:fileflow/util/file_type_ext.dart';
import 'package:fileflow/util/native/pick_directory_path.dart';
import 'package:fileflow/util/native/platform_check.dart';
import 'package:fileflow/widget/custom_dropdown_button.dart';
import 'package:fileflow/widget/custom_icon_button.dart';
import 'package:fileflow/widget/dialogs/file_name_input_dialog.dart';
import 'package:fileflow/widget/dialogs/quick_actions_dialog.dart';
import 'package:fileflow/widget/responsive_list_view.dart';
import 'package:flutter/material.dart';
import 'package:refena_flutter/refena_flutter.dart';

class ReceiveOptionsPage extends StatelessWidget {
  const ReceiveOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ref = context.ref;

    // Watch the current server session. If no session exists, display an empty page.
    final receiveSession = ref.watch(serverProvider.select((s) => s?.session));
    if (receiveSession == null) {
      return Scaffold(
        body: Container(),
      );
    }

    // Watch the state of selected receiving files.
    final selectState = ref.watch(selectedReceivingFilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.receiveOptionsPage.title),
      ),
      body: ResponsiveListView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        children: [
          // Display destination directory selection option.
          Row(
            children: [
              Text(t.receiveOptionsPage.destination, style: Theme.of(context).textTheme.titleLarge),
              if (checkPlatformWithFileSystem())
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: CustomIconButton(
                    onPressed: () async {
                      final directory = await pickDirectoryPath();
                      if (directory != null) {
                        ref.notifier(serverProvider).setSessionDestinationDir(directory);
                      }
                    },
                    child: const Icon(Icons.edit),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(checkPlatformWithFileSystem() ? receiveSession.destinationDirectory : t.receiveOptionsPage.appDirectory),

          // Display option to save to gallery if supported by the platform.
          if (checkPlatformWithGallery())
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(t.receiveOptionsPage.saveToGallery, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Row(
                  children: [
                    CustomDropdownButton<bool>(
                      value: receiveSession.saveToGallery,
                      expanded: false,
                      items: [false, true].map((b) {
                        return DropdownMenuItem(
                          value: b,
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 80),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(b ? t.general.on : t.general.off),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (b) => ref.notifier(serverProvider).setSessionSaveToGallery(b),
                    ),
                    if (receiveSession.containsDirectories && !receiveSession.saveToGallery) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(t.receiveOptionsPage.saveToGalleryOff, style: const TextStyle(color: Colors.grey)),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          const SizedBox(height: 20),

          // Display list of received files with quick actions.
          Row(
            children: [
              Text(t.general.files, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(width: 10),
              Tooltip(
                message: t.dialogs.quickActions.title,
                child: CustomIconButton(
                  onPressed: () async {
                    await showDialog(context: context, builder: (_) => const QuickActionsDialog());
                  },
                  child: const Icon(Icons.tips_and_updates),
                ),
              ),
              const SizedBox(width: 10),
              Tooltip(
                message: t.general.reset,
                child: CustomIconButton(
                  onPressed: () async {
                    ref.notifier(selectedReceivingFilesProvider).setFiles(receiveSession.files.values.map((f) => f.file).toList());
                  },
                  child: const Icon(Icons.undo),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Display each file with its details and actions (rename, select/unselect).
          ...receiveSession.files.values.map((file) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(file.file.fileType.icon, size: 46),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectState[file.file.id] ?? file.file.fileName,
                          style: const TextStyle(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                        Text(
                          '${!selectState.containsKey(file.file.id) ? t.general.skipped : (selectState[file.file.id] == file.file.fileName ? t.general.unchanged : t.general.renamed)} - ${file.file.size.asReadableFileSize}',
                          style: TextStyle(
                              color: !selectState.containsKey(file.file.id)
                                  ? Colors.grey
                                  : (selectState[file.file.id] == file.file.fileName
                                      ? Theme.of(context).colorScheme.onSecondaryContainer
                                      : Colors.orange)),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconButton(
                        onPressed: selectState[file.file.id] == null
                            ? null
                            : () async {
                                final result = await showDialog<String>(
                                  context: context,
                                  builder: (_) => FileNameInputDialog(
                                    originalName: file.file.fileName,
                                    initialName: selectState[file.file.id]!,
                                  ),
                                );
                                if (result != null) {
                                  ref.notifier(selectedReceivingFilesProvider).rename(file.file.id, result);
                                }
                              },
                        child: const Icon(Icons.edit),
                      ),
                      Checkbox(
                        value: selectState.containsKey(file.file.id),
                        activeColor: Theme.of(context).colorScheme.onSurface,
                        checkColor: Theme.of(context).colorScheme.surface,
                        onChanged: (selected) {
                          if (selected == true) {
                            ref.notifier(selectedReceivingFilesProvider).select(file.file);
                          } else {
                            ref.notifier(selectedReceivingFilesProvider).unselect(file.file.id);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
