import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  List<int> _codePoints = [];
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

  List<int> _getCodePoints(List<String> iconNames) {
    Set<int> codePoints = {};
    for (String iconName in iconNames) {
      codePoints.add(SymbolsGet.get(iconName, _symbolStyle).codePoint);
    }
    return codePoints.toList();
  }

  void _loadIcons() {
    List<String> iconNames = SymbolsGet.values.toSet().toList();
    iconNames.sort();
    setState(() {
      _codePoints = _getCodePoints(iconNames);
    });
  }

  void _filterIcons() {
    final query = _searchController.text.toLowerCase();
    List<String> iconNames;
    if (query.isEmpty) {
      iconNames = SymbolsGet.values.toList();
    } else {
      iconNames = SymbolsGet.values
          .where((name) => name.toLowerCase().contains(query))
          .toSet()
          .toList();
    }
    iconNames.sort();
    setState(() {
      _codePoints = _getCodePoints(iconNames);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
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
            child: _codePoints.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
              padding: EdgeInsets.all(10.0.h),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6, // Adjust as needed
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 1.0,
              ),
              itemCount: _codePoints.length,
              itemBuilder: (context, index) {
                final codePoint = _codePoints[index];
                final iconData = IconData(codePoint, fontFamily: 'MaterialSymbolsOutlined');

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