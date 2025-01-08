
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> {
  late final List<T> _items = widget.items.toList();
  bool _isDragging = false;


  Widget _buildDraggableItem(T item, int index) {
    return Draggable<int>(
      data: index,
      onDragStarted: () {
        setState(() {
          _isDragging = true;
        });
      },
      onDragEnd: (_) {
        setState(() {
          _isDragging = false;
        });
      },
       onDraggableCanceled: (_, __) {
        setState(() {
          _isDragging = false;
        });
      },

      feedback: Material(
        color: Colors.transparent,
        child: widget.builder(item),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: widget.builder(item),
      ),
      child: DragTarget<int>(
        onWillAcceptWithDetails: (data) => data != index,
        onAcceptWithDetails: (draggedIndex) {
          setState(() {
            final draggedItem = _items[draggedIndex.data];
            final newItems = List<T>.from(_items);
            newItems.removeAt(draggedIndex.data);
            newItems.insert(index, draggedItem);
            _items.clear();
            _items.addAll(newItems);
          });
        },
        builder: (context, candidateData, rejectedData) {
          return widget.builder(item);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < _items.length; i++) 
            _buildDraggableItem(_items[i], i),
        ],
      ),
    );
  }
}