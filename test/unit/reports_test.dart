import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:fresh_market/core/utils/file_saver/file_saver.dart';
import 'package:fresh_market/core/utils/file_saver/file_saver_stub.dart';
import 'package:fresh_market/core/utils/report_generator/report_generator.dart';
import 'package:fresh_market/domain/entities/order.entity.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';

void main() {
  group('Reports & Exports Unit Tests', () {
    test('Verify FileSaver stub integration and test buffers', () async {
      final dummyBytes = [1, 2, 3, 4, 5];
      await FileSaver.saveFile(dummyBytes, 'test_export.csv', 'text/csv');

      expect(lastSavedBytes, dummyBytes);
      expect(lastSavedFileName, 'test_export.csv');
      expect(lastSavedMimeType, 'text/csv');
    });

    test('Verify CSV Report generation headers and data parsing', () {
      final now = DateTime.now();
      final testOrders = [
        OrderEntity(
          id: 'ord_1',
          orderNumber: 'ORD-99991',
          customerId: 'cust_1',
          customerName: 'Alice Smith',
          phone: '010123',
          address: 'Cairo Street',
          subtotal: 150,
          deliveryFee: 15,
          total: 165,
          status: 'Delivered',
          createdAt: now,
          userId: 'cust_1',
          userEmail: 'alice@test.com',
          totalAmount: 165,
          updatedAt: now,
          items: const [],
        ),
      ];

      final bytes = ReportGenerator.generateCSV(ReportType.orders, testOrders);
      expect(bytes.isNotEmpty, true);

      final csvString = utf8.decode(bytes);
      expect(csvString.contains('Order Number'), true);
      expect(csvString.contains('Customer Name'), true);
      expect(csvString.contains('ORD-99991'), true);
      expect(csvString.contains('Alice Smith'), true);
      expect(csvString.contains('Cairo Street'), true);
    });

    test('Verify Excel XML Report generation sheets structure', () {
      final testProducts = [
        ProductEntity(
          id: 'prod_1',
          nameAr: 'تفاح أحمر',
          nameEn: 'Red Apple',
          descriptionAr: 'وصف تفاح',
          descriptionEn: 'Apple description',
          price: 45,
          imageUrl: 'url',
          categoryId: 'cat_fruits',
          weight: 1,
          weightUnitId: 'kg',
          currentStock: 100,
          reservedStock: 10,
          availableStock: 90,
          minimumStock: 15,
          reorderLevel: 20,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final bytes = ReportGenerator.generateExcel(ReportType.products, testProducts);
      expect(bytes.isNotEmpty, true);

      final xmlString = utf8.decode(bytes);
      expect(xmlString.contains('<?xml version="1.0"?>'), true);
      expect(xmlString.contains('<Workbook'), true);
      expect(xmlString.contains('<Worksheet ss:Name="Report">'), true);
      expect(xmlString.contains('Red Apple'), true);
      expect(xmlString.contains('cat_fruits'), true);
    });

    test('Verify PDF Report compiles syntactically and starts with standard header', () {
      final testProducts = [
        ProductEntity(
          id: 'prod_1',
          nameAr: 'تفاح أحمر',
          nameEn: 'Red Apple',
          descriptionAr: 'وصف تفاح',
          descriptionEn: 'Apple description',
          price: 45,
          imageUrl: 'url',
          categoryId: 'cat_fruits',
          weight: 1,
          weightUnitId: 'kg',
          currentStock: 100,
          reservedStock: 10,
          availableStock: 90,
          minimumStock: 15,
          reorderLevel: 20,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final bytes = ReportGenerator.generatePDF(ReportType.inventory, testProducts);
      expect(bytes.isNotEmpty, true);

      final pdfString = utf8.decode(bytes, allowMalformed: true);
      expect(pdfString.startsWith('%PDF-1.4'), true);
      expect(pdfString.contains('/Catalog'), true);
      expect(pdfString.contains('%%EOF'), true);
    });
  });
}
