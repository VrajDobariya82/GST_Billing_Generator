import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/invoice_model.dart';
import 'dart:convert';
import 'dart:math';

class BillingProvider extends ChangeNotifier {
  List<Invoice> _invoices = [];
  List<InvoiceItem> _currentItems = [];

  List<Invoice> get invoices => _invoices;
  List<InvoiceItem> get currentItems => _currentItems;

  BillingProvider() {
    _loadInvoices();
  }

  // Generate an automatic invoice number
  String generateInvoiceNumber() {
    final rand = Random();
    int randomId = rand.nextInt(9000) + 1000;
    return 'INV-${DateTime.now().year}-$randomId';
  }

  // Load invoices from SharedPreferences
  Future<void> _loadInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final String? invoicesJson = prefs.getString('invoices');
    if (invoicesJson != null) {
      final List<dynamic> decoded = json.decode(invoicesJson);
      _invoices = decoded.map((v) => Invoice.fromJson(v)).toList();
      notifyListeners();
    }
  }

  // Save invoices to SharedPreferences
  Future<void> _saveInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_invoices.map((inv) => inv.toJson()).toList());
    await prefs.setString('invoices', encoded);
  }

  void addItem(String name, double price, double gstRate, int quantity) {
    // CGST = (Price × GST %) / 2
    // SGST = (Price × GST %) / 2
    // Total = Price + CGST + SGST (Wait, total is per item * qty)
    
    // Per item tax amount
    double perItemGst = price * (gstRate / 100.0);
    double perItemCgst = perItemGst / 2;
    double perItemSgst = perItemGst / 2;
    double perItemTotal = price + perItemGst;

    final item = InvoiceItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productName: name,
      price: price, // price per unit (without tax)
      gstRate: gstRate,
      quantity: quantity,
      cgst: perItemCgst * quantity,
      sgst: perItemSgst * quantity,
      total: perItemTotal * quantity,
    );
    _currentItems.add(item);
    notifyListeners();
  }

  void removeItem(String id) {
    _currentItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  double get currentSubtotal {
    return _currentItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get currentTotalCgst {
    return _currentItems.fold(0.0, (sum, item) => sum + item.cgst);
  }

  double get currentTotalSgst {
    return _currentItems.fold(0.0, (sum, item) => sum + item.sgst);
  }

  double get currentGrandTotal {
    return _currentItems.fold(0.0, (sum, item) => sum + item.total);
  }

  Future<void> generateInvoice(String billedTo) async {
    if (_currentItems.isEmpty) return;

    final invoice = Invoice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      invoiceNumber: generateInvoiceNumber(),
      date: DateTime.now(),
      billedTo: billedTo,
      items: List.from(_currentItems),
      subtotal: currentSubtotal,
      totalCgst: currentTotalCgst,
      totalSgst: currentTotalSgst,
      grandTotal: currentGrandTotal,
      status: 'PENDING',
    );

    _invoices.insert(0, invoice);
    await _saveInvoices();
    
    _currentItems.clear();
    notifyListeners();
  }
  
  void clearCurrentItems() {
    _currentItems.clear();
    notifyListeners();
  }

  // Dashboard Stats
  int get activeClientsCount {
    // Count distinct billedTo
    return _invoices.map((e) => e.billedTo).toSet().length;
  }

  double get pendingGstTotal {
    // In design we see pending GST
    return _invoices.where((inv) => inv.status == 'PENDING').fold(0.0, (sum, inv) => sum + inv.totalCgst + inv.totalSgst);
  }
}
