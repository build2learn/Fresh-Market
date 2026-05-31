enum SettingType {
  string('string'),
  number('number'),
  bool('bool'),
  json('json');

  final String value;
  const SettingType(this.value);

  static SettingType fromString(String value) {
    return SettingType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => SettingType.string,
    );
  }
}
