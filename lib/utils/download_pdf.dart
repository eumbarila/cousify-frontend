import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

Future<void> downloadPdfFile({
  required String url,
  required String filename,
}) async {
  try {
    final dio = Dio();

    final response = await dio.get<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
      ),
    );

    final pdfBytes = response.data;
    if (pdfBytes == null) throw Exception("No PDF bytes downloaded");

    final savedPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save PDF',
      fileName: filename,
      bytes: Uint8List.fromList(pdfBytes),
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (savedPath == null) {
      return;
    }

  } catch (e) {
    rethrow;
  }
}
