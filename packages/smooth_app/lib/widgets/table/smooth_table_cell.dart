/// Represents the data in a single cell in this table.
class SmoothTableCell {
  SmoothTableCell({
    required this.text,
    required this.isHeader,
    required this.leftAlign,
  });

  final String text;
  final bool isHeader;
  final bool leftAlign;
}
