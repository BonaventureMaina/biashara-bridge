import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InventoryItem {
  final String name;
  final int quantity;
  final String? notes;

  InventoryItem({required this.name, required this.quantity, this.notes});

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'notes': notes ?? '',
      };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        name: json['name'] as String,
        quantity: json['quantity'] as int,
        notes: json['notes'] as String?,
      );
}

class InventoryNotifier extends StateNotifier<List<InventoryItem>> {
  InventoryNotifier() : super([]) {
    _loadFromStorage();
  }

  static const _storageKey = 'biashara_inventory';

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final List<dynamic> decoded = json.decode(raw);
      state = decoded.map((e) => InventoryItem.fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> addItem(InventoryItem item) async {
    state = [...state, item];
    await _saveToStorage();
  }

  Future<void> removeItem(int index) async {
    if (index >= 0 && index < state.length) {
      state = [
        ...state.sublist(0, index),
        ...state.sublist(index + 1),
      ];
      await _saveToStorage();
    }
  }

  Future<void> updateQuantity(int index, int newQuantity) async {
    if (index >= 0 && index < state.length) {
      final updated = InventoryItem(
        name: state[index].name,
        quantity: newQuantity,
        notes: state[index].notes,
      );
      state = [
        ...state.sublist(0, index),
        updated,
        ...state.sublist(index + 1),
      ];
      await _saveToStorage();
    }
  }
}

final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, List<InventoryItem>>((ref) {
  return InventoryNotifier();
});
