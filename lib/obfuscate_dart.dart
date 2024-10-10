library obfuscate_dart;

import 'dart:io';
import 'dart:math';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart' as AnalyzerUtilities; // ignore: library_prefixes
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:dart_format/dart_format.dart';

/// A Calculator.
class ObfuscateDart {
  /// [interval] 调整的间隔,最好是1-5之间的随机数
  static void obfuscateMethod(String classPath, int interval) {
    var classFile = File(classPath);
    var classString = classFile.readAsStringSync();
    String unformattedText = _confusionMethod(classString, interval);

    final Config configAll = Config.all();
    final Formatter formatter = Formatter(configAll);
    final String formattedText = formatter.format(unformattedText);

    // print(formattedText);
    classFile.writeAsStringSync(formattedText);
  }

  /// [interval] 调整的间隔,最好是1-5之间的随机数
  static String _confusionMethod(String s, int interval) {
    if (interval < 1) {
      throw "调整的间隔要大于0";
    }
    final String sWithoutCarriageReturns = s.replaceAll('\r', '');
    final ParseStringResult parseResult = AnalyzerUtilities.parseString(content: sWithoutCarriageReturns, throwIfDiagnostics: false);
    var outString = "";
    for (var directive in parseResult.unit.directives) {
      outString += directive.toSource();
    }
    for (var declaration in parseResult.unit.declarations) {
      if (declaration is ClassDeclarationImpl) {
        var rawString = declaration.toSource();
        List<String> methodStringList = [];
        for (var value in declaration.members) {
          if (value is MethodDeclarationImpl) {
            methodStringList.add(value.toSource());
          }
        }
        if (methodStringList.length > 1) {
          String swapPosition(String tempString, List<String> methodStringList, int position_1, int position_2) {
            var placeholder = '______PLACE_HOLDER_TEMP_METHOD______';
            String swappedCode = tempString
                .replaceFirst(methodStringList[position_1], placeholder)
                .replaceFirst(methodStringList[position_2], methodStringList[position_1])
                .replaceFirst(placeholder, methodStringList[position_2]);
            return swappedCode;
          }

          String resultTemp = rawString;
          for (int i = 0; i < methodStringList.length; i++) {
            if ((i + interval) < methodStringList.length) {
              resultTemp = swapPosition(resultTemp, methodStringList, i, i + interval);
            }
          }
          outString += resultTemp;
        } else {
          outString += rawString;
        }
      } else {
        outString += declaration.toSource();
      }
    }
    return outString;
  }
}

// main() {
//   String projectPath = "/Users/zhangwu/development/workspace/flutter/dy-app-v1/lib";
//   _obfuscateDart(Directory(projectPath));
//
//   // String classPath = "/Users/zhangwu/development/workspace/flutter/dy-app-v1/lib/v2/core/error/core_error.dart";
//   // ObfuscateDart.obfuscateMethod(classPath, 2);
// }

void _obfuscateDart(Directory directory) {
  for (var value in directory.listSync()) {
    if (FileSystemEntity.isFileSync(value.path) && value.path.endsWith(".dart")) {
      ObfuscateDart.obfuscateMethod(value.path, Random().nextInt(3) + 1);
    } else if (FileSystemEntity.isDirectorySync(value.path)) {
      _obfuscateDart(Directory(value.path));
    }
  }
}
