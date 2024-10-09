import 'package:process_run/process_run.dart';

class CompressPictures {
  /// 通过jar来压缩图片
  static Future<void> compress({
    required String apiKey,
    required String imgInputPath,
    required String imgOutputPath,
    String? proxy,
  }) async {
    var shell = Shell();
    await shell.run(
        '''java -jar _doc/CompressPicturesByTiny.jar key=$apiKey in=$imgInputPath out=$imgOutputPath ${proxy?.isNotEmpty == true ? "proxy=$proxy" : ""}''');
  }
}

// main() async {
//   String apiKey = '2fc7jNp5vZ2rBCl9kRDLZ8fRmH24wLbr'; // 替换为你的 API 密钥
//   String imagePath = "/Users/zhangwu/Downloads/漫画小说/Netoon.png"; // 替换为你的图片路径
//   await CompressPictures.compress(
//       apiKey: apiKey, imgInputPath: imagePath, imgOutputPath: "/Users/zhangwu/Downloads/Netoon_PPP.png", proxy: "http://127.0.0.1:4780");
// }
