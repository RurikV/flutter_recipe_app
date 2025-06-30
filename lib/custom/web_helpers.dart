// This file provides implementations for web/helpers.dart
// which is required by cross_file and http packages

// Export this file as web/helpers.dart
library web.helpers;

// Define the Blob class that's used by cross_file
class Blob {
  final List<dynamic> _parts;
  final String? _type;

  Blob(List<dynamic> parts, [String? type]) : _parts = parts, _type = type;

  String get type => _type ?? '';
  int get size => 0; // Simplified implementation
}

// Define the Element class that's used by cross_file
class Element {
  final String _tag;
  final Map<String, String> _attributes = {};

  Element(this._tag);

  void setAttribute(String name, String value) {
    _attributes[name] = value;
  }

  String? getAttribute(String name) {
    return _attributes[name];
  }
}

// Define the HTMLAnchorElement class that's used by cross_file
class HTMLAnchorElement extends Element {
  HTMLAnchorElement() : super('a');

  String get download => getAttribute('download') ?? '';
  set download(String value) => setAttribute('download', value);

  String get href => getAttribute('href') ?? '';
  set href(String value) => setAttribute('href', value);
}

// Helper function to create an anchor element
HTMLAnchorElement createAnchorElement(String href, String? suggestedName) {
  final anchor = HTMLAnchorElement();
  anchor.href = href;
  if (suggestedName != null) {
    anchor.download = suggestedName;
  }
  return anchor;
}

// Helper function to add an element to a container and click it
void addElementToContainerAndClick(Element container, Element element) {
  // This is a no-op in this implementation
}