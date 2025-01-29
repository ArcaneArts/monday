import 'package:monday/monday.dart';

class MondayColumn {
  final String id;
  final String title;
  final String description;
  final MondayColumnType type;

  MondayColumn({
    required this.id,
    required this.title,
    required this.type,
    this.description = '',
  });

  factory MondayColumn.fromJson(Map<String, dynamic> json) {
    return MondayColumn(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      type: MondayColumnTypeX.fromString(json['type'] as String),
    );
  }

  Future<void> deleteColumn(MondayAPI api, MondayBoard board) =>
      api.deleteColumn(
        boardId: board.id,
        columnId: id,
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'description': description,
    };
  }
}
