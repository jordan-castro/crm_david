int parseIntoInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.parse(value);
}

double parseIntoDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  return double.parse(value);
}