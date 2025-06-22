import 'package:flutter/material.dart';
import 'package:material_symbols_icons/get.dart';

import '../../style/app_color.dart';

class IconSelector extends StatefulWidget {
  const IconSelector({
    super.key,
    required this.changeIcon,
    required this.codePoint,
  });

  final int codePoint;
  final void Function(int) changeIcon;

  @override
  State<IconSelector> createState() => _IconSelectorState();
}

class _IconSelectorState extends State<IconSelector> {
  List<String> _iconNames = [];
  late int _selectedCodePoint = widget.codePoint;
  final SymbolStyle _symbolStyle = SymbolStyle.outlined; // 'outlined', 'rounded', 'sharp'
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadIcons();
    _searchController.addListener(_filterIcons);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadIcons() {
    setState(() {
      _iconNames = SymbolsGet.values.toList(); // Get all icon names
      _iconNames.sort(); // Sort them alphabetically
    });
  }

  void _filterIcons() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _iconNames = SymbolsGet.values.toList();
      } else {
        _iconNames = SymbolsGet.values
            .where((name) => name.toLowerCase().contains(query))
            .toList();
      }
      _iconNames.sort();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Icons',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Expanded(
            child: _iconNames.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
              padding: const EdgeInsets.all(10.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6, // Adjust as needed
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 1.0,
              ),
              itemCount: _iconNames.length,
              itemBuilder: (context, index) {
                final iconName = _iconNames[index];
                final iconData = SymbolsGet.get(iconName, _symbolStyle);

                int codePoint = SymbolsGet.get(iconName, SymbolStyle.outlined).codePoint;

                return Card(
                  color: _selectedCodePoint == codePoint
                      ? AppColor.tertiary
                      : AppColor.primary,
                  elevation: 2.0,
                  child: InkWell(
                    onTap: () {
                      widget.changeIcon(iconData.codePoint);
                      setState(() {
                        _selectedCodePoint = codePoint;
                      });
                    },
                    child: Icon(iconData, size: 30.0),
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