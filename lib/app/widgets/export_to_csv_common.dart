import 'dart:html' as html;
import 'dart:convert';

class ExportToCsv {
  static const String _commaDelimiter = ',';
  static const String _lineSeparator = '\n';

  void exportToCSV(
      List<String> header,
      List<List<String>> data, {
        String? fileName,
      }) {
    try {
      final csvContent = _generateCSVContent(header, data);

      // Create blob
      final bytes = utf8.encode(csvContent);
      final blob = html.Blob([bytes], 'text/csv;charset=utf-8;');

      // Create download link
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName ?? 'export_${DateTime.now().millisecondsSinceEpoch}.csv')
        ..click();

      // Clean up
      html.Url.revokeObjectUrl(url);

      print('CSV file downloaded successfully');
    } catch (e) {
      print('Error exporting CSV file: $e');
    }
  }

  String _generateCSVContent(List<String> header, List<List<String>> data) {
    final csvContent = StringBuffer();

    // Write header
    csvContent.write(header.map(_escapeSpecialCharacters).join(_commaDelimiter));
    csvContent.write(_lineSeparator);

    for (var row in data) {
      csvContent.write(row.map(_escapeSpecialCharacters).join(_commaDelimiter));
      csvContent.write(_lineSeparator);
    }

    return csvContent.toString();
  }


  String _escapeSpecialCharacters(String field) {
    String result = field;

    if (field.contains('"')) {
      result = field.replaceAll('"', '""');
    }

    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      result = '"$result"';
    }

    return result;
  }
}
