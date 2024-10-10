import 'dart:io';
import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:obfuscate_dart/src/read_directory_files.dart';
import 'package:path/path.dart' as path;

class ObfuscateResource {
  /// 将原本的资源文件，取别的名字
  static List<ObfuscateResourceResult> obfuscateResourceName(String resourcePath) {
    List<ObfuscateResourceResult> obfuscateResourceResultList = [];

    List<DirectoryUnderFiles> directoryUnderFiles = readDirectoryFiles(resourcePath);

    for (var directoryUnderFile in directoryUnderFiles) {
      for (var file in directoryUnderFile.files) {
        var newFileName = generateWordPairs().take(Random().nextInt(5) + 1).join("_");
        // print(path.extension(file.path));
        var newPath = file.path.replaceFirst(file.fileName, newFileName + path.extension(file.path));
        // print(newPath);
        var newFile = file.renameSync(newPath);
        obfuscateResourceResultList.add(ObfuscateResourceResult(oldFile: file, newFile: newFile));
      }
    }

    return obfuscateResourceResultList;
  }
}

class ObfuscateResourceResult {
  final File oldFile;
  final File newFile;

  ObfuscateResourceResult({
    required this.oldFile,
    required this.newFile,
  });
}

main() {
  String projectPath = "/Users/zhangwu/development/workspace/flutter/dy-app-v1";

  List<ObfuscateResourceResult> obfuscateResourceResultList = ObfuscateResource.obfuscateResourceName("$projectPath/assets");
  obfuscateResourceResultList.map((e) => "${e.oldFile.path} -> ${e.newFile.path}").toList().forEach(print);
}
