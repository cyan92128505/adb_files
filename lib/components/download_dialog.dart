import 'package:adb_files/api/repository.dart';
import 'package:adb_files/models/download_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DownloadDialog extends StatefulWidget {
  final String fullPath;
  const DownloadDialog({Key? key, required this.fullPath}) : super(key: key);

  @override
  _DownloadDialogState createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  static const platform = MethodChannel('angjelko.io/adb-files');
  DownloadInfo? _downloadInfo;

  @override
  void initState() {
    download();
    super.initState();
  }

  void download() async {
    var path = await platform.invokeMethod('chooseDirectory');
    var _info = await Repository.download(widget.fullPath, "$path/");
    setState(() {
      _downloadInfo = _info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Downloading in progress...'),
      content: SingleChildScrollView(
        child: _downloadInfo != null
            ? ListBody(
                children: <Widget>[
                  Text('Amount of Files Moved: ${_downloadInfo?.count}'),
                  Text(
                      'Duration: ${_downloadInfo?.duration}${_downloadInfo?.durationUnit}'),
                  Text(
                      'Size: ${_downloadInfo?.size}${_downloadInfo?.sizeUnit}'),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
      actions: <Widget>[
        if (_downloadInfo != null)
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
      ],
    );
  }
}
