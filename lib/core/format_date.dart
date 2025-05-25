String formatDateAmPm(DateTime date) {
  return "${date.day}/${date.month}/${date.year}, ${date.hour > 12 ? date.hour - 12 : date.hour}:${date.minute} ${date.hour > 12 ? "p.m." : "a.m."}";
}
