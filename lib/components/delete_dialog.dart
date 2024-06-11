import 'package:adb_files/api/repository.dart';
import 'package:adb_files/models/crud_info.dart';
import 'package:flutter/material.dart';

class DeleteDialog extends StatefulWidget {
  final String fullPath;
  const DeleteDialog({Key? key, required this.fullPath}) : super(key: key);

  @override
  _DeleteDialogState createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  CrudInfo? _crudInfo;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
  }

  void delete() async {
    setState(() {
      _confirmed = true;
    });
    var _info = await Repository.delete(widget.fullPath);
    setState(() {
      _crudInfo = _info;
      _confirmed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Warning'),
      content: SingleChildScrollView(
        child: _crudInfo != null
            ? ListBody(
                children: <Widget>[
                  Text('Directories: ${_crudInfo?.directoryCount}'),
                  Text('Files: ${_crudInfo?.fileCount}'),
                  ExpansionTile(
                    title: const Text('Details'),
                    children: _crudInfo!.files
                        .map((file) => ListTile(title: Text(file.fullPath)))
                        .toList(),
                  ),
                ],
              )
            : Center(
                child: _confirmed
                    ? const CircularProgressIndicator()
                    : const Text('Please confirm deletion')),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(_crudInfo != null ? 'Ok' : 'Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        if (_crudInfo == null)
          TextButton(
            style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(Colors.red)),
            child: const Text('Delete'),
            onPressed: () {
              delete();
            },
          ),
      ],
    );
  }
}
