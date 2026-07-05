/// Converts Apple Health export units into KYNOS canonical units.
double? toMeters(double? value, String? unit) {
  if (value == null) {
    return null;
  }

  switch (unit?.toLowerCase()) {
    case 'km':
      return value * 1000;
    case 'mi':
      return value * 1609.344;
    case 'm':
    case 'meter':
    case 'meters':
      return value;
    case 'cm':
      return value / 100;
    default:
      return value;
  }
}

double? toKilocalories(double? value, String? unit) {
  if (value == null) {
    return null;
  }

  switch (unit?.toLowerCase()) {
    case 'kj':
      return value / 4.184;
    case 'kcal':
    case 'cal':
      return value;
    default:
      return value;
  }
}

double? toMinutes(double? value, String? unit) {
  if (value == null) {
    return null;
  }

  switch (unit?.toLowerCase()) {
    case 's':
    case 'sec':
      return value / 60;
    case 'hr':
    case 'h':
      return value * 60;
    case 'min':
    default:
      return value;
  }
}

double? toBloodOxygenPercent(double? value) {
  if (value == null) {
    return null;
  }
  return value <= 1 ? value * 100 : value;
}
