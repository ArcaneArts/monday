import 'package:monday/monday.dart';

class MondayBoard {
  final String id;
  final String name;
  final String? description;
  final MondayBoardState state;
  final MondayUser? owner;
  final List<MondayColumn> columns;

  MondayBoard({
    required this.id,
    required this.name,
    this.description,
    required this.state,
    this.owner,
    required this.columns,
  });

  factory MondayBoard.fromJson(Map<String, dynamic> json) {
    final ownerJson = json['owner'];
    final columnsJson = json['columns'] as List<dynamic>? ?? [];
    return MondayBoard(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      state: MondayBoardState.values.firstWhere((i) => json['state'] == i.name,
          orElse: () {
        print("Unknown Board State: ${json['state']}");
        return MondayBoardState.all;
      }),
      owner: ownerJson != null ? MondayUser.fromJson(ownerJson) : null,
      columns: columnsJson
          .map((c) => MondayColumn.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'state': state.name,
      'owner': owner?.toJson(),
      'columns': columns.map((col) => col.toJson()).toList(),
    };
  }

  Future<void> deleteBoard(MondayAPI api) => api.deleteBoard(this);

  Future<void> deleteColumn(MondayAPI api, MondayColumn column) =>
      api.deleteColumn(boardId: this.id, columnId: column.id);

  Future<MondayColumn> addColumn(MondayAPI api, MondayColumn column) =>
      api.createColumn(
        boardId: id,
        title: column.title,
        type: column.type,
      );
}
