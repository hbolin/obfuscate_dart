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

  /// 图片资源dart文件中的图片资源的路径，替换成新的文件路径
  static void obfuscateImagesConfigDartFile(List<ObfuscateResourceResult> obfuscateResourceResultList, String projectPath, String imagesConfigDartFilePath) {
    assert(projectPath.isNotEmpty);
    assert(imagesConfigDartFilePath.isNotEmpty);

    var imagesConfigDartFile = File(imagesConfigDartFilePath);
    var imagesConfigDartContent = imagesConfigDartFile.readAsStringSync();

    // print(obfuscateResourceResultList.first.oldFile.path.replaceFirst(projectPath.endsWith("/") ? projectPath : "$projectPath/", ""));
    if (!imagesConfigDartContent
        .contains(obfuscateResourceResultList.first.oldFile.path.replaceFirst(projectPath.endsWith("/") ? projectPath : "$projectPath/", ""))) {
      throw "项目路径配置错误，请重新配置：$projectPath";
    }

    for (var value in obfuscateResourceResultList) {
      var oldFilePath = value.oldFile.path.replaceFirst(projectPath.endsWith("/") ? projectPath : "$projectPath/", "");
      var newFilePath = value.newFile.path.replaceFirst(projectPath.endsWith("/") ? projectPath : "$projectPath/", "");
      if (!imagesConfigDartContent.contains(oldFilePath)) {
        throw "项目路径配置错误，请重新配置：$projectPath";
      }
      imagesConfigDartContent = imagesConfigDartContent.replaceFirst(oldFilePath, newFilePath);
    }

    imagesConfigDartFile.writeAsStringSync(imagesConfigDartContent);
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

  List<ObfuscateResourceResult> obfuscateResourceResultList = ObfuscateResource.obfuscateResourceName("$projectPath/assets/images");
  obfuscateResourceResultList.map((e) => "${e.oldFile.path} -> ${e.newFile.path}").toList().forEach(print);

  ObfuscateResource.obfuscateImagesConfigDartFile(obfuscateResourceResultList, projectPath, "$projectPath/lib/v2/config/app_image_asset.dart");
}
