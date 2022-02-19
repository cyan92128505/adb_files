import 'package:adb_files/components/move_copy_dialog.dart';
import 'package:adb_files/models/app_state_manager.dart';
import 'package:adb_files/screens/directory_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WindowScreen extends StatelessWidget {
  const WindowScreen({Key? key}) : super(key: key);

  static MaterialPage page() {
    return const MaterialPage(
        name: 'window', key: ValueKey('Window'), child: WindowScreen());
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateManager>();
    final moveCopyManager = context.watch<MoveCopyManager>();

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Consumer<DeviceManager>(builder: (context, state, _) {
            return Flexible(
              flex: 1,
              fit: FlexFit.loose,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.devices.length,
                  itemBuilder: (context, i) {
                    var device = state.devices[i];
                    return ListTile(
                      onTap: () {
                        state.select(device);
                      },
                      title: Text(device.model),
                    );
                  }),
            );
          }),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                AppBar(
                  title: Text(moveCopyManager.isMove || moveCopyManager.isCopy
                      ? 'Where to ${moveCopyManager.isMove ? 'move' : 'copy'}: ${moveCopyManager.file?.name}?'
                      : state.pages.isEmpty
                          ? ''
                          : state.pages.last),
                  leading: state.pages.length > 1
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            state.pop();
                          },
                        )
                      : Container(),
                  actions: <Widget>[
                    if (moveCopyManager.isMove || moveCopyManager.isCopy)
                      IconButton(
                        icon: const Icon(Icons.paste),
                        tooltip: 'Paste here',
                        onPressed: () {
                          showMoveCopyDialog(context, state.pages.last);
                          // handle the press
                        },
                      ),
                  ],
                ),
                const DirectoryScreen()
              ],
            ),
          )
          // DirectoryScreen()
        ],
      ),
    );
  }

  Future<void> showMoveCopyDialog(BuildContext context, path) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return MoveCopyDialog(fullPath: path);
      },
    );
  }
}
