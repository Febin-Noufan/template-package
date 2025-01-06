import 'package:flutter/material.dart';
import 'package:template_package/section.dart';

/// A template page widget that provides a responsive layout with a collapsible
/// navigation menu and scrollable sections.
/// 
/// The template includes a side navigation menu that can be pinned or collapsed,
/// and automatically expands on hover. Each section is displayed in a scrollable
/// container with a header.
class TemplatePage extends StatefulWidget {
  /// List of sections to display in the template
  final List<Section> sections;

  /// Title displayed in the app bar
  final String title;

  /// Optional background color for the main content area
  final Color? backgroundColor;

  /// Optional color for the navigation menu
  final Color? menuColor;

  /// Width of the expanded navigation menu
  final double menuWidth;

  /// Width of the collapsed navigation menu
  final double collapsedMenuWidth;

  /// Creates a new template page with the required sections.
  /// 
  /// [sections] The list of sections to display
  /// [title] The text to show in the app bar (defaults to 'Template')
  /// [backgroundColor] Optional color for the main content area
  /// [menuColor] Optional color for the navigation menu
  /// [menuWidth] Width of expanded menu (defaults to 220)
  /// [collapsedMenuWidth] Width of collapsed menu (defaults to 70)
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
  /// Controller for handling scroll animations
  final ScrollController _scrollController = ScrollController();

  /// Whether the navigation menu is pinned open
  bool _isPinned = false;

  /// Whether the navigation menu is being hovered over
  bool _isHovered = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Toggles the pinned state of the navigation menu
  void _togglePin() => setState(() => _isPinned = !_isPinned);

  /// Updates the hover state of the navigation menu
  void _setHover(bool value) =>
      setState(() => _isHovered = !_isPinned && value);

  /// Scrolls to the specified section index with animation
  /// 
  /// Calculates the offset based on section heights and animates to that position
  void _scrollToSection(int index) {
    double offset = 0.0;

    // Calculate the offset dynamically based on the heights of sections
    for (int i = 0; i < index; i++) {
      offset += widget.sections[i].height ?? 500; // Default height is 500
    }

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

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
                children: [
                  for (var section in widget.sections)
                    _SectionWidget(
                      section: section,
                      defaultHeight: 500,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A collapsible navigation menu that displays section titles and icons
class _NavigationMenu extends StatelessWidget {
  /// List of sections to display in the menu
  final List<Section> sections;

  /// Whether the menu is pinned open
  final bool isPinned;

  /// Whether the menu is being hovered over
  final bool isHovered;

  /// Callback when the pin button is pressed
  final VoidCallback onPinPressed;

  /// Callback when hover state changes
  final ValueChanged<bool> onHoverChange;

  /// Callback when a section is selected
  final ValueChanged<int> onSectionSelected;

  /// Width of the menu when expanded
  final double expandedWidth;

  /// Width of the menu when collapsed
  final double collapsedWidth;

  /// Optional background color for the menu
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
                icon: Icon(isPinned ? Icons.lock : Icons.lock_open),
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

/// A navigation menu item that displays a section's icon and title
class _NavigationItem extends StatelessWidget {
  /// The section to display
  final Section section;

  /// Whether the navigation menu is expanded
  final bool isExpanded;

  /// Callback when the item is tapped
  final VoidCallback onTap;

  const _NavigationItem({
    Key? key,
    required this.section,
    required this.isExpanded,
    required this.onTap,
  }) : super(key: key);

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

/// A widget that displays a section's content with a header
class _SectionWidget extends StatelessWidget {
  /// The section to display
  final Section section;

  /// Default height to use if section doesn't specify one
  final double defaultHeight;

  const _SectionWidget({
    Key? key,
    required this.section,
    this.defaultHeight = 500,
  }) : super(key: key);

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