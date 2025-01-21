import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:template_package/section.dart';

class TemplatePage extends StatefulWidget {
  final List<Section> sections;
  final String title;
  final Color? backgroundColor;
  final Color? menuColor;
  final double menuWidth;
  final double collapsedMenuWidth;

  const TemplatePage({
    super.key,
    required this.sections,
    this.title = 'Template',
    this.backgroundColor,
    this.menuColor,
    this.menuWidth = 220,
    this.collapsedMenuWidth = 70,
  });

  @override
  _TemplatePageState createState() => _TemplatePageState();
}

class _TemplatePageState extends State<TemplatePage> {
  final ScrollController _scrollController = ScrollController();
  late final FocusNode _focusNode;
  bool _isPinned = false;
  bool _isHovered = false;

  //DateTime? _lastEscapePressTime;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _togglePin() => setState(() => _isPinned = !_isPinned);

  void _setHover(bool value) => setState(() => _isHovered = !_isPinned && value);

  void _scrollToSection(int index) {
    double offset = 0.0;

    for (int i = 0; i < index; i++) {
      offset += widget.sections[i].height ?? 500;
    }

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  // void _handleKeyEvent(RawKeyEvent event) {
  //   if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
  //     final now = DateTime.now();
  //     if (_lastEscapePressTime == null ||
  //         now.difference(_lastEscapePressTime!) > const Duration(milliseconds: 300)) {
  //       _lastEscapePressTime = now; // First press or timeout
  //     } else {
  //       if (Navigator.canPop(context)) {
  //         Navigator.pop(context); // Double press detected
  //       }
  //       _lastEscapePressTime = null;
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? Colors.white,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: widget.menuColor ?? const Color(0xFFF4ECEC),
        title: Text(widget.title),
        elevation: 5,
      ),
      body: Row(
        children: [
          _NavigationMenu(
            sections: widget.sections,
            isPinned: _isPinned,
            isHovered: _isHovered,
            onPinPressed: _togglePin,
            onHoverChange: _setHover,
            onSectionSelected: _scrollToSection,
            expandedWidth: widget.menuWidth,
            collapsedWidth: widget.collapsedMenuWidth,
            backgroundColor: widget.menuColor,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: widget.sections.map((section) {
                  return _SectionWidget(
                    section: section,
                    defaultHeight: 500,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationMenu extends StatelessWidget {
  final List<Section> sections;
  final bool isPinned;
  final bool isHovered;
  final VoidCallback onPinPressed;
  final ValueChanged<bool> onHoverChange;
  final ValueChanged<int> onSectionSelected;
  final double expandedWidth;
  final double collapsedWidth;
  final Color? backgroundColor;

  const _NavigationMenu({
    required this.sections,
    required this.isPinned,
    required this.isHovered,
    required this.onPinPressed,
    required this.onHoverChange,
    required this.onSectionSelected,
    required this.expandedWidth,
    required this.collapsedWidth,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = isPinned || isHovered;

    return MouseRegion(
      onEnter: (_) => onHoverChange(true),
      onExit: (_) => onHoverChange(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isExpanded ? expandedWidth : collapsedWidth,
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFFF4ECEC),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: IconButton(
                icon: Icon(isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                onPressed: onPinPressed,
              ),
            ),
            const Divider(color: Colors.black12, thickness: 1),
            Expanded(
              child: ListView.builder(
                itemCount: sections.length,
                itemBuilder: (context, index) => _NavigationItem(
                  section: sections[index],
                  isExpanded: isExpanded,
                  onTap: () => onSectionSelected(index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final Section section;
  final bool isExpanded;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.section,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      child: Row(
        children: [
          Icon(section.icon ?? Icons.circle, size: 12),
          const SizedBox(width: 10),
          if (isExpanded)
            Expanded(
              child: Text(
                section.title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  final Section section;
  final double defaultHeight;

  const _SectionWidget({
    required this.section,
    this.defaultHeight = 500,
  });

  @override
  Widget build(BuildContext context) {
    final height = section.height ?? defaultHeight;

    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFFD0CDCD),
            height: 40,
            padding: const EdgeInsets.only(left: 40),
            alignment: Alignment.centerLeft,
            child: Text(section.title),
          ),
          Expanded(child: section.content),
        ],
      ),
    );
  }
}
