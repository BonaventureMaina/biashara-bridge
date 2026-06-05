import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/inventory_provider.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    final name = _nameController.text.trim();
    final qtyText = _quantityController.text.trim();
    if (name.isEmpty || qtyText.isEmpty) return;
    final quantity = int.tryParse(qtyText);
    if (quantity == null) return;

    final item = InventoryItem(
      name: name,
      quantity: quantity,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    await ref.read(inventoryProvider.notifier).addItem(item);
    _nameController.clear();
    _quantityController.clear();
    _notesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Inventory'),
        actions: [
          if (inventory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.cloud_upload_outlined),
              tooltip: 'Sync to cloud (placeholder)',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sync not yet implemented')),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Add item form
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Item name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          // Inventory list
          Expanded(
            child: inventory.isEmpty
                ? const Center(child: Text('No items in inventory'))
                : ListView.builder(
                    itemCount: inventory.length,
                    itemBuilder: (context, index) {
                      final item = inventory[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: item.notes != null
                            ? Text(item.notes!)
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${item.quantity} units'),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                if (item.quantity > 1) {
                                  ref
                                      .read(inventoryProvider.notifier)
                                      .updateQuantity(index, item.quantity - 1);
                                } else {
                                  ref
                                      .read(inventoryProvider.notifier)
                                      .removeItem(index);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                ref
                                    .read(inventoryProvider.notifier)
                                    .updateQuantity(index, item.quantity + 1);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                ref
                                    .read(inventoryProvider.notifier)
                                    .removeItem(index);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
