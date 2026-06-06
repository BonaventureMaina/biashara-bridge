import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'inventory_provider_stub.dart' if (dart.library.io) 'inventory_provider_io.dart';

class InventoryItem {
  final String name;
  final int quantity;
  final String? notes;
  InventoryItem({required this.name, required this.quantity, this.notes});
  Map<String, dynamic> toJson() => {'name': name, 'quantity': quantity, 'notes': notes ?? ''};
  factory InventoryItem.fromJson(Map<String, dynamic> json) =>
      InventoryItem(name: json['name'], quantity: json['quantity'], notes: json['notes']);
}

class InventoryNotifier extends StateNotifier<List<InventoryItem>> {
  InventoryNotifier() : super([]) { _loadFromStorage(); }

  static const _storageKey = 'biashara_inventory';

  void _loadFromStorage() {
    try {
      final raw = html.window.localStorage[_storageKey];
      if (raw != null) {
        final List<dynamic> decoded = json.decode(raw);
        state = decoded.map((e) => InventoryItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
  }

  void _saveToStorage() {
    try {
      html.window.localStorage[_storageKey] = json.encode(state.map((e) => e.toJson()).toList());
    } catch (_) {}
  }

  Future<void> addItem(InventoryItem item) async { state = [...state, item]; _saveToStorage(); }
  Future<void> removeItem(int index) async {
    if (index >= 0 && index < state.length) {
      state = [...state.sublist(0, index), ...state.sublist(index + 1)];
      _saveToStorage();
    }
  }
  Future<void> updateQuantity(int index, int newQuantity) async {
    if (index >= 0 && index < state.length) {
      state = [...state.sublist(0, index),
        InventoryItem(name: state[index].name, quantity: newQuantity, notes: state[index].notes),
        ...state.sublist(index + 1)];
      _saveToStorage();
    }
  }
}

final inventoryProvider = StateNotifierProvider<InventoryNotifier, List<InventoryItem>>((ref) => InventoryNotifier());
