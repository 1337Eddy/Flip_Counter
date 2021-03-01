import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class CounterStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    //print(path);
    return File('$path/counter.txt');
  }

  Future<List<String>> readTraining() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();
      LineSplitter ls = new LineSplitter();
      List<String> lines = ls.convert(contents);
      return lines;
    } catch (e) {
      return [""];
    }
  }

  Future<File> writeTraining(String text) async {
    final file = await _localFile;
    List<String> lines = await readTraining();
    lines.add(text);
    // Write the file
    return file.writeAsString('$lines');
  }
}
