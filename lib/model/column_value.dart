import 'package:monday/monday.dart';

class MondayColumnValue {
  final MondayColumn column;
  final dynamic value;

  MondayColumnValue({required this.column, required this.value});

  Map<String, dynamic> toMap() => {column.id: value};
}
