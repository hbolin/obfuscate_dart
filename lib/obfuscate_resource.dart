import 'dart:io';
import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:obfuscate_dart/src/read_directory_files.dart';
import 'package:path/path.dart' as path;
import 'package:collection/collection.dart';

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
  static void obfuscateImagesConfigDartFile(String projectPath, String imagesConfigDartFilePath, List<ObfuscateResourceResult> obfuscateResourceResultList) {
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

  static void replaceImagesDartConfigToString(
      String projectPath, List<OldImagesToDartConfigResult> oldImagesToDartConfigResultList, List<ObfuscateResourceResult> obfuscateResourceResultList) {
    var libPath = projectPath.endsWith("/") ? "${projectPath}lib" : "$projectPath/lib";

    // check
    for (var value in oldImagesToDartConfigResultList) {
      if (obfuscateResourceResultList.firstWhereOrNull((e) => value.oldFile.path == e.oldFile.path) == null) {
        throw "该文件未被匹配，请检查：${value.oldFile.path}";
      }
    }

    List<DirectoryUnderFiles> directoryUnderFiles = readDirectoryFiles(libPath);
    for (var directoryUnderFile in directoryUnderFiles) {
      for (var file in directoryUnderFile.files) {
        // 查找关键字
        while (true) {
          var fileContent = file.readAsStringSync();
          var findResult = oldImagesToDartConfigResultList.firstWhereOrNull((e) {
            RegExp regExp = RegExp(r'\b' + e.replaceKeyWord + r'\b');
            Iterable<Match> matches = regExp.allMatches(fileContent);
            return matches.isNotEmpty;
          });
          if (findResult == null) {
            break;
          }
          var findMapResult = obfuscateResourceResultList.firstWhereOrNull((e) => findResult.oldFile.path == e.oldFile.path);
          var newFilePath = findMapResult!.newFile.path.replaceFirst(projectPath.endsWith("/") ? projectPath : "$projectPath/", "");
          fileContent = fileContent.replaceFirst(findResult.replaceKeyWord, '''"$newFilePath"''');
          file.writeAsStringSync(fileContent);
        }
      }
    }
  }

  static List<OldImagesToDartConfigResult> oldImagesToDartConfig(String imageDirectoryPath, String imagesConfigClassName) {
    List<OldImagesToDartConfigResult> result = [];
    _oldImagesToDartConfig(Directory(imageDirectoryPath), imagesConfigClassName, null, result);
    return result;
  }

  static void _oldImagesToDartConfig(Directory directory, String rootClassName, String? prefix, List<OldImagesToDartConfigResult> result) {
    var temps = directory.listSync();
    var childDirectories = temps.where((element) => FileSystemEntity.isDirectorySync(element.path));
    var childFiles = temps.where((element) => FileSystemEntity.isFileSync(element.path));
    childFiles = childFiles.where((element) => !element.path.endsWith(".DS_Store"));

    if (prefix == null) {
      for (var element in childFiles) {
        result.add(OldImagesToDartConfigResult(
            replaceKeyWord: "$rootClassName.${File(element.path).fileNameWithoutExtension.toLowerCase().replaceAll("-", "_").replaceAll(" ", "_")}",
            oldFile: File(element.path)));
      }
    } else {
      for (var element in childFiles) {
        result.add(OldImagesToDartConfigResult(
            replaceKeyWord: "$prefix.${File(element.path).fileNameWithoutExtension.toLowerCase().replaceAll("-", "_").replaceAll(" ", "_")}",
            oldFile: File(element.path)));
      }
    }

    for (var element in childDirectories) {
      prefix = prefix?.isNotEmpty == true
          ? "$prefix.${Directory(element.path).directoryName.toLowerCaseFirstLetter()}"
          : "$rootClassName.${Directory(element.path).directoryName.toLowerCaseFirstLetter()}";
      _oldImagesToDartConfig(Directory(element.path), rootClassName, prefix, result);
    }
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

class OldImagesToDartConfigResult {
  final String replaceKeyWord;
  final File oldFile;

  OldImagesToDartConfigResult({
    required this.replaceKeyWord,
    required this.oldFile,
  });
}

// main() {
//   String projectPath = "/Users/zhangwu/development/workspace/flutter/dy-app-v1";
//
//   List<OldImagesToDartConfigResult> oldImagesToDartConfigResultList = ObfuscateResource.oldImagesToDartConfig("$projectPath/assets/images", "AppImageAsset");
//
//   List<ObfuscateResourceResult> obfuscateResourceResultList = ObfuscateResource.obfuscateResourceName("$projectPath/assets/images");
//   // obfuscateResourceResultList.map((e) => "${e.oldFile.path} -> ${e.newFile.path}").toList().forEach(print);
//
//   ObfuscateResource.obfuscateImagesConfigDartFile(projectPath, "$projectPath/lib/v2/config/app_image_asset.dart", obfuscateResourceResultList);
//
//   ObfuscateResource.replaceImagesDartConfigToString(projectPath, oldImagesToDartConfigResultList, obfuscateResourceResultList);
// }
