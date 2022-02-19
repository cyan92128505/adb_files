import 'dart:async';

import 'package:adb_files/models/crud_info.dart';
import 'package:adb_files/models/device.dart';
import 'package:process_run/shell.dart';

import '../models/download_info.dart';
import '../models/file.dart';

class Repository {
  static Shell shell = Shell();
  static String adbPath = 'adb';
  static String serial = "";
  static void setDevice(Device? device) {
    if (device != null) {
      serial = "-s ${device.serial}";
    }
  }

  static Future<List<AdbFile>> directories({name = '/sdcard/'}) async {
    var result = await shell.run('$adbPath $serial shell "ls $name" -F');
    return result.first.outLines.map((e) => AdbFile.fromName(e, name)).toList();
  }

  static Future<List<String>> devices() async {
    var result = await shell.run('$adbPath devices');
    var list = result.first.outLines.toList();
    list.removeAt(0);
    return list;
  }

  static Future<CrudInfo> move(path, newPath, {merge = false}) async {
    var result = await shell
        .run('$adbPath $serial shell "mv $path${merge ? '/*' : ''} $newPath"');
    return CrudInfo.parseText(
        result.first.outText.isNotEmpty ? result.first.outText : newPath);
  }

  static Future<CrudInfo> copy(path, newPath) async {
    var result =
        await shell.run('$adbPath $serial shell "cp -rv $path $newPath"');
    return CrudInfo.parseText(
        result.first.outText.isNotEmpty ? result.first.outText : newPath);
  }

  static Future<DownloadInfo> download(file, to) async {
    var result = await shell.run('$adbPath $serial pull "$file" "$to"');
    return DownloadInfo.parseText(result.first.outText);
  }

  static void rename(path, oldName, newName) async {
    move('$path$oldName', '$path$newName');
  }

  static Future<CrudInfo> delete(String file) async {
    var result = await shell.run('$adbPath $serial shell "rm -rfv $file"');
    return CrudInfo.parseText(
        result.first.outText.isNotEmpty ? result.first.outText : file);
  }

  static Future<List<Device>> listDevices() async {
    var result = await shell.run('$adbPath devices -l');
    List<Device> devices = [];
    for (var text in result.first.outLines.skip(1)) {
      if (text.isNotEmpty) devices.add(Device.fromText(text));
    }
    return devices;
  }
}
