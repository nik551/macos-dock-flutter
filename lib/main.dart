import 'dart:developer';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  int? _dragIndex;
  int? _targetIndex;
  bool _isDragging = false;
  int? _hoveredIndex;

  double _getScale(int index) {
    if (_hoveredIndex == null) return 1.0;
    final distance = (index - _hoveredIndex!).abs();
    if (distance == 0) return 1.1;
    if (distance == 1) return 1.05;
    return 1.0;
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
        children: buildDraggables(),
      ),
    );
  }

  List<Widget> buildDraggables() {
    return List.generate(_items.length, (index) {
      final item = _items[index];
      return Draggable<int>(
        data: index,
        onDragStarted: () {
          setState(() {
            _dragIndex = index;
            _isDragging = true;
          });
        },
        onDragEnd: (_) {
          setState(() {
            _isDragging = false;
            _dragIndex = null;
            _targetIndex = null;
          });
        },
        onDraggableCanceled: (_, __) {
          setState(() {
            _isDragging = false;
            _dragIndex = null;
            _targetIndex = null;
          });
        },
        feedback: widget.builder(item),
        childWhenDragging: SizedBox(
          width: 0,
          height: 48,
          child: SizedBox.shrink(),
        ),
        child: DragTarget<int>(
          onWillAcceptWithDetails: (draggedIndex) {
            if (_isDragging) {
              setState(() {
                _targetIndex = index;
              });
              return draggedIndex.data != index;
            }
            return false;
          },
          onAcceptWithDetails: (draggedIndex) {
            setState(() {
              final item = _items.removeAt(draggedIndex.data);
              _items.insert(index, item);
              _dragIndex = null;
              _targetIndex = null;
              _isDragging = false;
            });
          },
          onLeave: (data) {
            setState(() {
              _isDragging = true;
              _targetIndex = null;
            });
          },
          builder: (context, candidateData, rejectedData) {
            bool leftRight = _dragIndex != null && _dragIndex! < index;
            return MouseRegion(
              onEnter: (_) => setState(() => _hoveredIndex = index),
              onExit: (_) => setState(() => _hoveredIndex = null),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                margin: EdgeInsets.only(
                  left: _targetIndex == index && !leftRight ? 48 : 0,
                  right: _targetIndex == index && leftRight ? 48 : 0,
                ),
                transform: Matrix4.identity()
                  ..scale(_getScale(index))
                  ..translate(0.0, _hoveredIndex == index ? -4.0 : 0.0),
                child: widget.builder(item),
              ),
            );
          },
        ),
      );
    });
  }
}
