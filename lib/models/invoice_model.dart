import 'dart:convert';

class InvoiceItem {
  final String id;
  final String productName;
  final double price;
  final double gstRate; // e.g., 5, 12, 18, 28
  final int quantity;
  final double cgst;
  final double sgst;
  final double total;

  InvoiceItem({
    required this.id,
    required this.productName,
    required this.price,
    required this.gstRate,
    required this.quantity,
    required this.cgst,
    required this.sgst,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'price': price,
      'gstRate': gstRate,
      'quantity': quantity,
      'cgst': cgst,
      'sgst': sgst,
      'total': total,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      id: map['id'] ?? '',
      productName: map['productName'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      gstRate: map['gstRate']?.toDouble() ?? 0.0,
      quantity: map['quantity']?.toInt() ?? 0,
      cgst: map['cgst']?.toDouble() ?? 0.0,
      sgst: map['sgst']?.toDouble() ?? 0.0,
      total: map['total']?.toDouble() ?? 0.0,
    );
  }
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final DateTime date;
  final String billedTo;
  final List<InvoiceItem> items;
  final double subtotal; // price * qty without tax
  final double totalCgst;
  final double totalSgst;
  final double grandTotal;
  final String status;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    required this.billedTo,
    required this.items,
    required this.subtotal,
    required this.totalCgst,
    required this.totalSgst,
    required this.grandTotal,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'date': date.toIso8601String(),
      'billedTo': billedTo,
      'items': items.map((x) => x.toMap()).toList(),
      'subtotal': subtotal,
      'totalCgst': totalCgst,
      'totalSgst': totalSgst,
      'grandTotal': grandTotal,
      'status': status,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      date: DateTime.parse(map['date']),
      billedTo: map['billedTo'] ?? '',
      items: List<InvoiceItem>.from(map['items']?.map((x) => InvoiceItem.fromMap(x))),
      subtotal: map['subtotal']?.toDouble() ?? 0.0,
      totalCgst: map['totalCgst']?.toDouble() ?? 0.0,
      totalSgst: map['totalSgst']?.toDouble() ?? 0.0,
      grandTotal: map['grandTotal']?.toDouble() ?? 0.0,
      status: map['status'] ?? 'PENDING',
    );
  }

  String toJson() => json.encode(toMap());

  factory Invoice.fromJson(String source) => Invoice.fromMap(json.decode(source));
}
