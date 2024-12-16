class MondayUser {
  final String id;
  final String name;

  MondayUser({required this.id, required this.name});

  factory MondayUser.fromJson(Map<String, dynamic> json) {
    return MondayUser(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
