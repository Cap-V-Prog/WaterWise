extension DateUtils on DateTime {
  String toShortDateString() {
    return "${this.day.toString().padLeft(2, '0')}/${this.month.toString().padLeft(2, '0')}/${this.year}";
  }
}
