import 'package:adb_files/models/app_state_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class MoveCopyDialog extends StatefulWidget {
  final String fullPath;
  const MoveCopyDialog({Key? key, required this.fullPath}) : super(key: key);

  @override
  _MoveCopyDialogState createState() => _MoveCopyDialogState();
}

class _MoveCopyDialogState extends State<MoveCopyDialog> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final appStateManager = context.read<AppStateManager>();
      final moveCopyManager = context.read<MoveCopyManager>();
      if (appStateManager.fileExistsAlready(moveCopyManager.file)) {
        moveCopyManager.fileExists();
      } else {
        moveCopyManager.paste(widget.fullPath);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final moveCopyManager = context.watch<MoveCopyManager>();
    return AlertDialog(
      title: const Text('Warning'),
      content: SingleChildScrollView(
          child: moveCopyManager.info != null
              ? ListBody(
                  children: <Widget>[
                    Text(
                        'Directories: ${moveCopyManager.info?.directoryCount}'),
                    Text('Files: ${moveCopyManager.info?.fileCount}'),
                    ExpansionTile(
                      title: const Text('Details'),
                      children: moveCopyManager.info!.files
                          .map((file) => ListTile(title: Text(file.fullPath)))
                          .toList(),
                    ),
                  ],
                )
              : moveCopyManager.existsAlready
                  ? ListBody(
                      children: <Widget>[
                        ElevatedButton(
                            onPressed: () {
                              moveCopyManager.paste(widget.fullPath,
                                  replace: true);
                            },
                            child: const Column(
                              children: [
                                Text('Replace'),
                                Text(
                                    'This means whole folder will be replaced!')
                              ],
                            )),
                        if (moveCopyManager.file != null &&
                            moveCopyManager.file!.isDirectory)
                          ElevatedButton(
                              onPressed: () {
                                moveCopyManager.paste(widget.fullPath,
                                    merge: true);
                              },
                              child: const Column(
                                children: [
                                  Text('Merge'),
                                  Text(
                                      "This means the 2 folders will be merged together but any subfiles and subdirectories will be overwritten!")
                                ],
                              )),
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    )),
      actions: <Widget>[
        TextButton(
          child: Text(moveCopyManager.info != null ? 'Ok' : 'Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
            moveCopyManager.cancel();
            context.read<AppStateManager>().refresh();
          },
        ),
      ],
    );
  }
}
