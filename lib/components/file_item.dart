import 'package:adb_files/components/delete_dialog.dart';
import 'package:adb_files/components/download_dialog.dart';
import 'package:adb_files/models/app_state_manager.dart';
import 'package:file_icon/file_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/repository.dart';
import '../models/enums.dart';
import '../models/file.dart';

class FileItem extends StatefulWidget {
  final AdbFile file;
  const FileItem({Key? key, required this.file}) : super(key: key);

  @override
  _FileItemState createState() => _FileItemState();
}

class _FileItemState extends State<FileItem> {
  late TextEditingController _controller;
  late FocusNode _node;
  bool _isRename = false;

  @override
  void initState() {
    super.initState();
    _node = FocusNode(debugLabel: 'Button');
    _node.addListener(_onFocusChange);
    _controller = TextEditingController(text: widget.file.name);
  }

  @override
  void dispose() {
    _node.removeListener(_onFocusChange);
    _node.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_node.hasFocus) {
      if (widget.file.name != _controller.text) {
        List<AdbFile> files = context.read<AppStateManager>().files;
        if (files.indexWhere((AdbFile file) => file.name == _controller.text) >
            -1) {
          _showRenameDialog();
        } else {
          Repository.rename(
              widget.file.path, widget.file.name, _controller.text);
        }
      }
    }
  }

  Future<void> _showRenameDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'There is already a ${widget.file.isDirectory ? 'Directory' : 'File'} with that name'),
                const SizedBox(
                  height: 8.0,
                ),
                const Text(
                    'Proceeding will merge the content in one directory which can result in overwriting any existing content.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(Colors.red)),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Proceed'),
              onPressed: () {
                Repository.rename(
                  widget.file.path,
                  widget.file.name,
                  _controller.text,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showDownloadDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return DownloadDialog(
          fullPath: widget.file.fullPath,
        );
      },
    );
  }

  Future<void> showDeleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return DeleteDialog(fullPath: widget.file.fullPath);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onDoubleTap: () {
          context.read<AppStateManager>().go(widget.file.fullPath);
        },
        onSecondaryTapUp: (details) {
          _showContextMenu(context, details.globalPosition);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FileIcon(
              widget.file.isDirectory ? '.sql' : '.sh',
              size: 64.0,
            ),
            _isRename
                ? TextField(
                    focusNode: _node,
                    autofocus: true,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        focusedBorder:
                            OutlineInputBorder(borderSide: BorderSide())),
                    controller: _controller,
                    textAlign: TextAlign.center,
                    onEditingComplete: () {
                      // Repository.rename(file.path, file.name, value);
                    },
                  )
                : SelectableText.rich(
                    TextSpan(
                      children: widget.file
                          .getFormatNameList()
                          .asMap()
                          .map((index, text) {
                            return MapEntry(
                              index,
                              TextSpan(
                                text: widget.file.getFormatNameList().length ==
                                        index + 1
                                    ? text
                                    : '$text.',
                                style: TextStyle(
                                  color: widget.file.isDirectory
                                      ? index % 2 == 1
                                          ? Colors.blue
                                          : Colors.black87
                                      : Colors.black87,
                                ),
                              ),
                            );
                          })
                          .values
                          .toList(),
                    ),
                    maxLines: 2,
                  )
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, Offset offset) async {
    final screenSize = MediaQuery.of(context).size;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        screenSize.width - offset.dx,
        screenSize.height - offset.dy,
      ),
      items: [
        const PopupMenuItem<FileAction>(
          value: FileAction.open,
          child: Text('Open'),
        ),
        const PopupMenuItem<FileAction>(
          value: FileAction.download,
          child: Text('Download'),
        ),
        const PopupMenuItem<FileAction>(
          value: FileAction.rename,
          child: Text('Rename'),
        ),
        const PopupMenuItem<FileAction>(
          value: FileAction.move,
          child: Text('Move'),
        ),
        const PopupMenuItem<FileAction>(
          value: FileAction.copy,
          child: Text('Copy'),
        ),
        const PopupMenuItem<FileAction>(
          value: FileAction.paste,
          child: Text('Paste'),
        ),
        const PopupMenuItem<FileAction>(
          value: FileAction.delete,
          child: Text('Delete'),
        ),
        const PopupMenuItem<FileAction>(
          value: FileAction.info,
          child: Text('info'),
        )
      ],
      elevation: 8.0,
    ).then((action) async {
      switch (action) {
        case FileAction.open:
          context.read<AppStateManager>().go(widget.file.fullPath);
          break;
        case FileAction.download:
          showDownloadDialog();
          break;
        case FileAction.rename:
          // _node.requestFocus();
          setState(() {
            _isRename = true;
          });
          break;
        case FileAction.move:
          context.read<MoveCopyManager>().move(widget.file);
          break;
        case FileAction.copy:
          context.read<MoveCopyManager>().copy(widget.file);
          break;
        case FileAction.paste:
          break;
        case FileAction.delete:
          showDeleteDialog();
          break;
        default:
      }
      // NOTE: even you didnt select item this method will be called with null of value so you should call your call back with checking if value is not null
      // context.read<FileActionManager>().request(action, file: widget.file);
    });
  }
}
