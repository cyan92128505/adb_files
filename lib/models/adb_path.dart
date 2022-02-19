import 'package:adb_files/models/file.dart';

class AdbPath {
  final String path;
  final List<AdbFile> files;

  AdbPath(this.path, this.files);
}
