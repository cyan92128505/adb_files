import 'dart:math';

import 'package:adb_files/api/repository.dart';
import 'package:adb_files/models/crud_info.dart';
import 'package:adb_files/models/file.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'device.dart';

class AppStateManager with ChangeNotifier {
  final Map<String, List<String>> _pages = {};
  bool _isLoading = true;
  List<AdbFile> _files = [];
  Device? _active;

  List<String> get pages => _active != null ? _pages[_active!.serial]! : [];
  bool get isLoading => _isLoading;
  List<AdbFile> get files => _files;

  AppStateManager({Device? device}) {
    _active = device;
    go('/sdcard/');
  }

  void setDevice(Device? device) {
    _active = device;
    if (_active != null) {
      if (_pages[_active!.serial] == null) {
        _pages[_active!.serial] = [];
        go('/sdcard/');
      } else {
        refresh();
      }
    }
  }

  String generateRandomString(int len) {
    var r = Random();
    return String.fromCharCodes(
        List.generate(len, (index) => r.nextInt(33) + 89));
  }

  void go(String path) async {
    loading();
    _pages[_active?.serial]?.add(path);
    refresh();
  }

  void refresh() async {
    loading();
    _files = await Repository.directories(name: _pages[_active?.serial]?.last);
    _isLoading = false;
    notifyListeners();
  }

  void pop() async {
    loading();
    _pages[_active?.serial]?.removeLast();
    refresh();
  }

  void loading() {
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }
  }

  bool fileExistsAlready(AdbFile? file) {
    return _files.indexWhere((AdbFile _file) => _file.name == file?.name) > -1;
  }
}

class MoveCopyManager with ChangeNotifier {
  AdbFile? _file;
  bool _isMove = false;
  bool _isCopy = false;
  CrudInfo? _info;
  bool get isMove => _isMove;
  bool get isCopy => _isCopy;
  AdbFile? get file => _file;
  CrudInfo? get info => _info;
  bool _fileExists = false;
  bool get existsAlready => _fileExists;

  void select(AdbFile file, isCopy) {
    _file = file;
    _isMove = !isCopy;
    _isCopy = isCopy;
    _info = null;
    notifyListeners();
  }

  void move(AdbFile file) {
    _file = file;
    _isMove = true;
    _isCopy = false;
    _info = null;
    notifyListeners();
  }

  void copy(AdbFile file) {
    _file = file;
    _isCopy = true;
    _isMove = false;
    _info = null;
    notifyListeners();
  }

  void paste(path, {merge = false, replace = false}) async {
    if (_file != null) {
      if (replace && _file!.isDirectory) {
        await Repository.delete(p.join(path, _file?.name));
      }

      if (_isCopy) {
        _info = await Repository.copy(_file?.fullPath, path);
      } else if (_isMove) {
        _info = await Repository.move(
            _file!.fullPath, p.join(path, _file!.name),
            merge: merge && _file!.isDirectory);
        if (merge && _file!.isDirectory) {
          await Repository.delete(_file!.fullPath);
        }
      }
    }

    _isMove = false;
    _isCopy = false;
    _fileExists = false;
    _file = null;
    notifyListeners();
  }

  void fileExists() {
    _fileExists = true;
    notifyListeners();
  }

  void cancel() {
    _isMove = false;
    _isCopy = false;
    _fileExists = false;
    _file = null;
    _info = null;
    notifyListeners();
  }
}

class DeviceManager with ChangeNotifier {
  List<Device> _devices = [];
  Device? _active;
  Device? get active => _active;
  List<Device> get devices => _devices;

  DeviceManager() {
    list();
  }

  Future<List<Device>> list() async {
    _devices = await Repository.listDevices();
    select(_devices.first);
    return _devices;
  }

  void select(Device device) {
    _active = device;
    Repository.setDevice(device);
    notifyListeners();
  }
}
