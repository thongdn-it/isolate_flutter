import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_image_compress/isolate_image_compress.dart';

Future<void> main() async {
  test('compress image to less than or equal 1.5 MB', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    File file = File('test_resources/compress-test.jpg');
    final uint8 = await file.readAsBytes();
    debugPrint('isolate_image_compress begin - : ${uint8.length}');
    final data = await uint8.compress(maxSize: 1572864); // 1.5 MB
    debugPrint('isolate_image_compress end - : ${data?.length}');
    expect(uint8.length != data?.length, true);
    expect((data?.length ?? 15728640) <= 1572864, true);
  });
}
