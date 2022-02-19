import 'package:adb_files/models/file.dart';
import 'package:path/path.dart' as p;

class CrudInfo {
  final int directoryCount;
  final int fileCount;
  final List<AdbFile> files;

  CrudInfo(this.files, this.directoryCount, this.fileCount);

  factory CrudInfo.parseText(String text) {
    var isDirectory = RegExp(
      r"rmdir\s'",
      caseSensitive: true,
      multiLine: false,
    );

    var fullPath = RegExp(
      r"'(.+)'",
      caseSensitive: false,
      multiLine: false,
    );

    var files = text.split("\n").map((e) {
      var path = fullPath.firstMatch(e)?.group(1) ?? e;
      return AdbFile(
          p.basename(path), isDirectory.hasMatch(e), "${p.dirname(path)}/");
    });
    var _directoryCount = files.where((file) => file.isDirectory).length;
    return CrudInfo(
        files.toList(), _directoryCount, files.length - _directoryCount);
  }
}
