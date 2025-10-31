// lib/features/invoices/data/services/invoice_docx_export_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:docx_template/docx_template.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class InvoiceDocxExportService {
  Future<String> exportInvoice(Map<String, dynamic> invoiceData) async {
    try {
      final templateBytes = await rootBundle.load('assets/templates/invoice_template.docx');
      final docx = await DocxTemplate.fromBytes(templateBytes.buffer.asUint8List());

      final content = _prepareInvoiceContent(invoiceData);
      final generatedBytes = await docx.generate(content);

      if (generatedBytes == null) {
        throw Exception('DOCX oluşturulamadı');
      }

      final uint8ListBytes = Uint8List.fromList(generatedBytes);
      return await _saveFile(uint8ListBytes, invoiceData);
    } catch (e) {
      throw Exception('Invoice DOCX export hatası: $e');
    }
  }

  Content _prepareInvoiceContent(Map<String, dynamic> invoiceData) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    final content = Content();

    content
      ..add(TextContent('invoice_number', invoiceData['invoice_number'] ?? 'N/A'))
      ..add(TextContent('invoice_date', invoiceData['invoice_date'] != null
          ? dateFormat.format(DateTime.parse(invoiceData['invoice_date']))
          : dateFormat.format(DateTime.now())))
      ..add(TextContent('customer_name', invoiceData['customer_name'] ?? 'N/A'))
      ..add(TextContent('customer_phone', invoiceData['customer_phone'] ?? 'N/A'))
      ..add(TextContent('customer_email', invoiceData['customer_email'] ?? 'N/A'))
      ..add(TextContent('total', currencyFormat.format(_parseDouble(invoiceData['total']))))
      ..add(TextContent('paid_amount', currencyFormat.format(_parseDouble(invoiceData['paid_amount']))))
      ..add(TextContent('remaining_amount', currencyFormat.format(_parseDouble(invoiceData['remaining_amount']))))
      ..add(TextContent('notes', invoiceData['notes'] ?? 'Ek not bulunmamaktadır.'));

    // Fatura kalemleri - Liste olarak
    if (invoiceData['items'] != null && invoiceData['items'] is List) {
      final items = (invoiceData['items'] as List).map((item) {
        return PlainContent('item')
          ..add(TextContent('description', item['description'] ?? 'N/A'))
          ..add(TextContent('quantity', item['quantity']?.toString() ?? '1'))
          ..add(TextContent('unit_price', currencyFormat.format(_parseDouble(item['unit_price']))))
          ..add(TextContent('subtotal', currencyFormat.format(_parseDouble(item['subtotal']))));
      }).toList();

      content.add(ListContent('items', items));
    }

    return content;
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<String> _saveFile(Uint8List bytes, Map<String, dynamic> invoiceData) async {
    final directory = await getTemporaryDirectory();
    final invoiceNumber = invoiceData['invoice_number'] ?? 'FATURA';
    final fileName = 'Fatura_${invoiceNumber}_${DateTime.now().millisecondsSinceEpoch}.docx';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }

  Future<String> saveToDownloads(Uint8List bytes, Map<String, dynamic> invoiceData) async {
    Directory? directory;

    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = await getDownloadsDirectory();
    }

    if (directory == null) {
      throw Exception('Kayıt dizini bulunamadı');
    }

    final invoiceNumber = invoiceData['invoice_number'] ?? 'FATURA';
    final fileName = 'Fatura_$invoiceNumber.docx';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }
}