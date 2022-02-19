import 'package:path/path.dart' as p;

class AdbFile {
  final String name;
  final bool isDirectory;
  final String path;

  AdbFile(this.name, this.isDirectory, this.path);

  String get fullPath => p.join(path, name);

  AdbFile.fromName(name, this.path)
      : isDirectory = name.endsWith('/'),
        name = p.basename(name);
}
