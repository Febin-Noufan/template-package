import 'package:flutter/material.dart';

/// A model class that represents a section in the template page.
/// 
/// Each section contains a title, content widget, and optional icon and height.
class Section {
  /// The title text displayed in the section header and navigation menu
  final String title;

  /// The main content widget of the section
  final Widget content;

  /// Optional icon displayed in the navigation menu
  final IconData? icon;

  /// Optional custom height for the section. Defaults   to 500 if not specified.
  final double? height;

  /// Creates a new section with the required title and content.
  /// 
  /// [title] The text to display in the section header and navigation
  /// [content] The main widget to display in the section body
  /// [icon] Optional icon shown in the navigation menu
  /// [height] Optional custom height for the section (defaults to 500)
  const Section({
    required this.title,
    required this.content,
    this.icon,
    this.height,
  });
}