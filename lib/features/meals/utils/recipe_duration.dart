Duration parseRecipeDuration(String time_label) {
  final match = RegExp(r'(\d+)').firstMatch(time_label);
  final minutes = match != null ? int.parse(match.group(1)!) : 10;
  return Duration(minutes: minutes.clamp(1, 180));
}
