import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:monday/monday.dart';

class MondayAPI {
  final String apiToken;
  final String _endpoint = 'https://api.monday.com/v2';

  MondayAPI(this.apiToken);

  Future<MondayBoard> getBoard(String boardId) async {
    final intBoardId = int.tryParse(boardId);
    if (intBoardId == null) {
      throw Exception('Board ID must be numeric. Given: $boardId');
    }

    final query = '''
    query {
      boards(ids: [$intBoardId]) {
        id
        name
        description
        state
        owner {
          id
          name
        }
        columns {
          id
          title
          type
        }
      }
    }
  ''';

    final responseJson = await postQuery(query);
    final boardsJson = responseJson['data']['boards'] as List<dynamic>;
    if (boardsJson.isEmpty) {
      throw Exception('Board not found: $boardId');
    }

    return MondayBoard.fromJson(boardsJson.first as Map<String, dynamic>);
  }

  Future<List<MondayBoard>> listBoards() async {
    Map<String, dynamic> responseJson = await postQuery('''
      query {
        boards {
          id
          name
          description
          state
          owner {
            id
            name
          }
          columns {
            id
            title
            type
          }
        }
      }
      ''');

    return (responseJson['data']['boards'] as List<dynamic>).map((json) {
      return MondayBoard.fromJson(json as Map<String, dynamic>);
    }).toList();
  }

  Future<void> deleteBoard(MondayBoard board) async {
    final intBoardId = int.tryParse(board.id);
    if (intBoardId == null) {
      throw Exception('Board ID must be numeric. Given: ${board.id}');
    }

    final mutation = '''
    mutation {
      delete_board(
        board_id: $intBoardId,
      ) {
        id
      }
    }
  ''';

    await postQuery(mutation);
  }

  Future<MondayBoard> createBoard(MondayBoard board) async {
    final mutation = '''
      mutation {
        create_board(
          board_name: "${board.name}",
          board_kind: private
        ) {
          id
          name
          state
          owner {
            id
            name
          }
        }
      }
    ''';

    final responseJson = await postQuery(mutation);
    final createdBoardJson =
        responseJson['data']['create_board'] as Map<String, dynamic>;
    final createdBoardId = createdBoardJson['id'] as String;

    for (var col in board.columns) {
      print('Creating column ${col.title} type ${col.type}');
      await createColumn(
        boardId: createdBoardId,
        title: col.title,
        type: col.type,
      );
      print("Created Column ${col.title}");
    }

    final newBoard = await getBoard(createdBoardId);
    return newBoard;
  }

  Future<void> deleteColumn(
      {required String boardId, required String columnId}) async {
    final intBoardId = int.tryParse(boardId);
    if (intBoardId == null) {
      throw Exception('Board ID must be numeric. Given: $boardId');
    }

    final mutation = '''
    mutation {
      delete_column(
        board_id: $intBoardId,
        column_id: "$columnId"
      ) {
        id
      }
    }
  ''';

    await postQuery(mutation);
  }

  Future<MondayColumn> createColumn({
    required String boardId,
    required String title,
    required MondayColumnType type,
  }) async {
    int intBoardId = int.parse(boardId);

    final mutation = '''
      mutation {
        create_column (
          board_id: $intBoardId,
          title: "$title",
          column_type: ${type.name}
        ) {
          id
          title
          type
        }
      }
    ''';

    Map<String, dynamic> responseJson = await postQuery(mutation);
    final columnJson =
        responseJson['data']['create_column'] as Map<String, dynamic>;
    return MondayColumn.fromJson(columnJson);
  }

  Future<Map<String, dynamic>> postQuery(String query) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': apiToken,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'query': query}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch data from Monday API: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data.containsKey('errors')) {
      throw Exception('GraphQL Error: ${data['errors']}. Request was $query');
    }

    return data;
  }
}
