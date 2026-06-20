import 'dart:convert';
import 'package:intl/intl.dart';
import '../../../domain/entities/order.entity.dart';
import '../../../domain/entities/product.entity.dart';

enum ReportType {
  orders,
  revenue,
  products,
  inventory,
}

class ReportGenerator {
  static List<int> generateCSV(ReportType type, List<dynamic> data) {
    final csvBuffer = StringBuffer();
    final headers = _getHeaders(type);
    
    // Write headers
    csvBuffer.writeln(headers.map((h) => '"${h.replaceAll('"', '""')}"').join(','));

    // Write rows
    final rows = _getRows(type, data);
    for (final row in rows) {
      csvBuffer.writeln(row.map((cell) => '"${cell.toString().replaceAll('"', '""')}"').join(','));
    }

    return utf8.encode(csvBuffer.toString());
  }

  static List<int> generateExcel(ReportType type, List<dynamic> data) {
    final headers = _getHeaders(type);
    final rows = _getRows(type, data);

    final excelXml = StringBuffer();
    excelXml.writeln('<?xml version="1.0"?>');
    excelXml.writeln('<?mso-application progid="Excel.Sheet"?>');
    excelXml.writeln('<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"');
    excelXml.writeln(' xmlns:o="urn:schemas-microsoft-com:office:office"');
    excelXml.writeln(' xmlns:x="urn:schemas-microsoft-com:office:excel"');
    excelXml.writeln(' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"');
    excelXml.writeln(' xmlns:html="http://www.w3.org/TR/REC-html40">');
    
    excelXml.writeln(' <Worksheet ss:Name="Report">');
    excelXml.writeln('  <Table>');
    
    // Header Row
    excelXml.writeln('   <Row>');
    for (final header in headers) {
      excelXml.writeln('    <Cell><Data ss:Type="String">${_escapeXml(header)}</Data></Cell>');
    }
    excelXml.writeln('   </Row>');

    // Data Rows
    for (final row in rows) {
      excelXml.writeln('   <Row>');
      for (final cell in row) {
        final valStr = cell.toString();
        final isNum = double.tryParse(valStr) != null;
        final typeAttr = isNum ? 'Number' : 'String';
        excelXml.writeln('    <Cell><Data ss:Type="$typeAttr">${_escapeXml(valStr)}</Data></Cell>');
      }
      excelXml.writeln('   </Row>');
    }

    excelXml.writeln('  </Table>');
    excelXml.writeln(' </Worksheet>');
    excelXml.writeln('</Workbook>');

    return utf8.encode(excelXml.toString());
  }

  static List<int> generatePDF(ReportType type, List<dynamic> data) {
    final headers = _getHeaders(type);
    final rows = _getRows(type, data);

    final title = _getReportTitle(type);
    final streamContent = StringBuffer();
    
    // Title
    streamContent.writeln('BT');
    streamContent.writeln('/F1 16 Tf');
    streamContent.writeln('50 780 Td');
    streamContent.writeln('(${_escapePdf(title)}) Tj');
    streamContent.writeln('ET');

    // Date Generated
    final genDate = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    streamContent.writeln('BT');
    streamContent.writeln('/F1 9 Tf');
    streamContent.writeln('50 760 Td');
    streamContent.writeln('(Generated on: ${_escapePdf(genDate)}) Tj');
    streamContent.writeln('ET');

    // Column Headers
    double startY = 720;
    streamContent.writeln('BT');
    streamContent.writeln('/F1 10 Tf');
    streamContent.writeln('50 $startY Td');
    
    // Draw columns headers inline with tabs
    final headerLine = headers.join('    |    ');
    streamContent.writeln('(${_escapePdf(headerLine)}) Tj');
    streamContent.writeln('ET');

    // Separator line
    startY -= 10;
    streamContent.writeln('BT');
    streamContent.writeln('/F1 10 Tf');
    streamContent.writeln('50 $startY Td');
    streamContent.writeln('(${'-' * (headers.length * 15)}) Tj');
    streamContent.writeln('ET');

    // Data rows
    startY -= 20;
    for (final row in rows.take(30)) { // limit preview to 30 rows in single page PDF for simplicity
      streamContent.writeln('BT');
      streamContent.writeln('/F1 9 Tf');
      streamContent.writeln('50 $startY Td');
      
      final rowLine = row.map((e) {
        final str = e.toString();
        return str.length > 15 ? '${str.substring(0, 12)}...' : str;
      }).join('    |    ');
      
      streamContent.writeln('(${_escapePdf(rowLine)}) Tj');
      streamContent.writeln('ET');
      startY -= 18;
    }

    if (rows.length > 30) {
      streamContent.writeln('BT');
      streamContent.writeln('/F1 9 Tf');
      streamContent.writeln('50 $startY Td');
      streamContent.writeln('(... and ${rows.length - 30} more rows) Tj');
      streamContent.writeln('ET');
    }

    final contentsString = streamContent.toString();
    final contentsBytes = utf8.encode(contentsString);
    final contentsLength = contentsBytes.length;

    // Compile minimal valid PDF syntax
    final pdfBuffer = StringBuffer();
    pdfBuffer.writeln('%PDF-1.4');
    pdfBuffer.writeln('1 0 obj');
    pdfBuffer.writeln('<< /Type /Catalog /Pages 2 0 R >>');
    pdfBuffer.writeln('endobj');
    pdfBuffer.writeln('2 0 obj');
    pdfBuffer.writeln('<< /Type /Pages /Kids [3 0 R] /Count 1 >>');
    pdfBuffer.writeln('endobj');
    pdfBuffer.writeln('3 0 obj');
    pdfBuffer.writeln('<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595.275 841.89] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>');
    pdfBuffer.writeln('endobj');
    pdfBuffer.writeln('4 0 obj');
    pdfBuffer.writeln('<< /Length $contentsLength >>');
    pdfBuffer.writeln('stream');
    
    // Write header/stream part as bytes
    final pdfHeaderBytes = utf8.encode(pdfBuffer.toString());
    
    final pdfFooterBuffer = StringBuffer();
    pdfFooterBuffer.writeln();
    pdfFooterBuffer.writeln('endstream');
    pdfFooterBuffer.writeln('endobj');
    pdfFooterBuffer.writeln('5 0 obj');
    pdfFooterBuffer.writeln('<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>');
    pdfFooterBuffer.writeln('endobj');
    pdfFooterBuffer.writeln('xref');
    pdfFooterBuffer.writeln('0 6');
    pdfFooterBuffer.writeln('0000000000 65535 f ');
    pdfFooterBuffer.writeln('0000000009 00000 n ');
    pdfFooterBuffer.writeln('0000000058 00000 n ');
    pdfFooterBuffer.writeln('0000000115 00000 n ');
    pdfFooterBuffer.writeln('0000000244 00000 n ');
    pdfFooterBuffer.writeln('0000000320 00000 n ');
    pdfFooterBuffer.writeln('trailer');
    pdfFooterBuffer.writeln('<< /Root 1 0 R /Size 6 >>');
    pdfFooterBuffer.writeln('%%EOF');

    final pdfFooterBytes = utf8.encode(pdfFooterBuffer.toString());

    // Concat all byte arrays
    final totalBytes = <int>[];
    totalBytes.addAll(pdfHeaderBytes);
    totalBytes.addAll(contentsBytes);
    totalBytes.addAll(pdfFooterBytes);

    return totalBytes;
  }

  static String _getReportTitle(ReportType type) {
    switch (type) {
      case ReportType.orders: return 'Orders Report';
      case ReportType.revenue: return 'Revenue Report';
      case ReportType.products: return 'Products Report';
      case ReportType.inventory: return 'Inventory Report';
    }
  }

  static List<String> _getHeaders(ReportType type) {
    switch (type) {
      case ReportType.orders:
        return ['Order Number', 'Customer Name', 'Phone', 'Address', 'Date', 'Subtotal', 'Delivery Fee', 'Total', 'Status'];
      case ReportType.revenue:
        return ['Date', 'Delivered Orders Count', 'Subtotal', 'Delivery Fee', 'Net Revenue'];
      case ReportType.products:
        return ['Product ID', 'Name (AR)', 'Name (EN)', 'Category', 'Price', 'Weight', 'Weight Unit', 'Active', 'Stock'];
      case ReportType.inventory:
        return ['Product Name (AR)', 'Product Name (EN)', 'Current Stock', 'Reserved Stock', 'Available Stock', 'Minimum Stock', 'Status'];
    }
  }

  static List<List<dynamic>> _getRows(ReportType type, List<dynamic> data) {
    switch (type) {
      case ReportType.orders:
        final list = data.cast<OrderEntity>();
        return list.map((order) => [
          order.orderNumber,
          order.customerName,
          order.phone,
          order.address,
          DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt),
          order.subtotal.toStringAsFixed(2),
          order.deliveryFee.toStringAsFixed(2),
          order.total.toStringAsFixed(2),
          order.status,
        ]).toList();
      case ReportType.revenue:
        final orders = data.cast<OrderEntity>().where((o) => o.status == 'Delivered').toList();
        // Group by Date yyyy-MM-dd
        final groups = <String, List<OrderEntity>>{};
        for (final o in orders) {
          final dayStr = DateFormat('yyyy-MM-dd').format(o.createdAt);
          groups.putIfAbsent(dayStr, () => []).add(o);
        }
        final sortedKeys = groups.keys.toList()..sort((a, b) => b.compareTo(a));
        return sortedKeys.map((dayStr) {
          final groupOrders = groups[dayStr]!;
          final subtotal = groupOrders.fold<double>(0.0, (sum, o) => sum + o.subtotal);
          final fee = groupOrders.fold<double>(0.0, (sum, o) => sum + o.deliveryFee);
          final total = groupOrders.fold<double>(0.0, (sum, o) => sum + o.total);
          return [
            dayStr,
            groupOrders.length,
            subtotal.toStringAsFixed(2),
            fee.toStringAsFixed(2),
            total.toStringAsFixed(2),
          ];
        }).toList();
      case ReportType.products:
        final list = data.cast<ProductEntity>();
        return list.map((product) => [
          product.id,
          product.nameAr,
          product.nameEn,
          product.categoryId,
          product.price.toStringAsFixed(2),
          product.weight.toStringAsFixed(2),
          product.weightUnitId,
          product.isAvailable ? 'Active' : 'Inactive',
          product.availableStock,
        ]).toList();
      case ReportType.inventory:
        final list = data.cast<ProductEntity>();
        return list.map((product) => [
          product.nameAr,
          product.nameEn,
          product.currentStock,
          product.reservedStock,
          product.availableStock,
          product.minimumStock,
          product.availableStock <= 0 ? 'Out of Stock' : (product.availableStock <= product.minimumStock ? 'Low Stock' : 'Healthy'),
        ]).toList();
    }
  }

  static String _escapeXml(String str) {
    return str
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  static String _escapePdf(String str) {
    return str
        .replaceAll('(', '\\(')
        .replaceAll(')', '\\)');
  }
}
