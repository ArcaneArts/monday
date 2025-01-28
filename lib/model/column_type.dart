enum MondayColumnType {
  button,
  checkbox,
  color_picker,
  board_relation,
  country,
  creation_log,
  date,
  dependency,
  dropdown,
  email,
  file,
  formula,
  hour,
  item_id,
  last_updated,
  link,
  location,
  long_text,
  mirror,
  doc,
  name, // UNSUPPORTED THROUGH API
  numbers,
  people,
  phone,
  rating,
  status,
  tags,
  text,
  timeline,
  time_tracking,
  vote,
  week,
  world_clock,
  unknown
}

extension MondayColumnTypeX on MondayColumnType {
  static MondayColumnType fromString(String typeStr) {
    try {
      return MondayColumnType.values.firstWhere((e) => e.name == typeStr);
    } catch (_) {
      return MondayColumnType.unknown;
    }
  }
}
