import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:colorize/colorize.dart';

Future<List> generateIO(Map<String, String> files, String path) async {
  var futures = <Future>[];

  files.forEach((name, content) {
    futures.add(_createFile(path + name, content));
  });

  return Future.wait(futures);
}

String getPath(String path, String name) {
  if (!Directory(path).existsSync()) {
    throw ('Please ensure that the project path is an existing directory!');
  }
  var ppath = path + name + '/';
  _ensureDirExists(ppath);
  return ppath;
}

void _ensureDirExists(String path) {
  if (Directory(path).existsSync() == false && path.isNotEmpty) {
    Directory(path).createSync(recursive: true);
  }
}

Future _createFile(String name, String content) async {
  content = content.replaceAll('\\', '\u005C');
  dynamic path = name.split('/');
  path = path.sublist(0, path.length - 1).join('/');
  _ensureDirExists(path as String);
  await saveBytes(utf8.encode(content), name);
  color('Generated: ' + name, front: Styles.LIGHT_YELLOW);
  return;
}

Future saveBytes(List<int> bytes, String path) async {
  //_ensureDirExists(path);
  final file = File(path);
  return await file.writeAsBytes(bytes);
}

String readFile(String name) {
  var myfile = File(name);
  if (!myfile.existsSync()) return null;
  return myfile.readAsStringSync();
}
