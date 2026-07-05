import 'package:kynos/infrastructure/ai/gemma/ai_isolate_messages.dart';

/// Fits multivariate regression coefficients for stride length prediction.
({double b0, double b1, double b2}) trainRegression(
  List<AiRegressionSample> samples,
) {
  if (samples.length < 3) {
    throw StateError(
      'At least 3 samples are required for multivariate regression.',
    );
  }

  double s1 = 0;
  double sc = 0;
  double sp = 0;
  double scc = 0;
  double spp = 0;
  double scp = 0;

  double sy = 0;
  double scy = 0;
  double spy = 0;

  for (final sample in samples) {
    final c = sample.cadenceSpm;
    final p = sample.powerWatts;
    final y = sample.strideLengthMeters;

    s1 += 1;
    sc += c;
    sp += p;
    scc += c * c;
    spp += p * p;
    scp += c * p;

    sy += y;
    scy += c * y;
    spy += p * y;
  }

  // Small ridge term for numerical stability on highly-correlated run data.
  const ridge = 1e-6;
  final matrix = <List<double>>[
    <double>[s1 + ridge, sc, sp],
    <double>[sc, scc + ridge, scp],
    <double>[sp, scp, spp + ridge],
  ];
  final vector = <double>[sy, scy, spy];

  return solve3x3(matrix, vector);
}

/// Solves a 3×3 linear system via Gaussian elimination.
({double b0, double b1, double b2}) solve3x3(
  List<List<double>> a,
  List<double> b,
) {
  final m = List<List<double>>.generate(
    3,
    (r) => <double>[a[r][0], a[r][1], a[r][2], b[r]],
  );

  for (var col = 0; col < 3; col++) {
    var pivotRow = col;
    var pivotSize = m[col][col].abs();
    for (var row = col + 1; row < 3; row++) {
      final size = m[row][col].abs();
      if (size > pivotSize) {
        pivotSize = size;
        pivotRow = row;
      }
    }

    if (pivotSize < 1e-12) {
      throw StateError('Regression matrix is singular.');
    }

    if (pivotRow != col) {
      final temp = m[col];
      m[col] = m[pivotRow];
      m[pivotRow] = temp;
    }

    final pivot = m[col][col];
    for (var j = col; j < 4; j++) {
      m[col][j] = m[col][j] / pivot;
    }

    for (var row = 0; row < 3; row++) {
      if (row == col) continue;
      final factor = m[row][col];
      for (var j = col; j < 4; j++) {
        m[row][j] = m[row][j] - (factor * m[col][j]);
      }
    }
  }

  return (b0: m[0][3], b1: m[1][3], b2: m[2][3]);
}
