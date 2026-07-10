import 'dart:io';

const minimumOverall = 39.0;
const minimumDomain = 57.0;

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('Usage: dart run tool/check_coverage.dart <lcov.info>');
    exitCode = 64;
    return;
  }

  final file = File(args.single);
  if (!file.existsSync()) {
    stderr.writeln('Coverage file not found: ${file.path}');
    exitCode = 66;
    return;
  }

  var totalLines = 0;
  var totalHit = 0;
  var domainLines = 0;
  var domainHit = 0;
  var isDomainFile = false;

  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      isDomainFile = line.substring(3).contains('lib/domain/');
    } else if (line.startsWith('LF:')) {
      final lines = int.parse(line.substring(3));
      totalLines += lines;
      if (isDomainFile) domainLines += lines;
    } else if (line.startsWith('LH:')) {
      final hit = int.parse(line.substring(3));
      totalHit += hit;
      if (isDomainFile) domainHit += hit;
    }
  }

  final overall = _percentage(totalHit, totalLines);
  final domain = _percentage(domainHit, domainLines);
  stdout.writeln('Coverage: ${overall.toStringAsFixed(2)}% overall, '
      '${domain.toStringAsFixed(2)}% domain');

  if (overall < minimumOverall || domain < minimumDomain) {
    stderr.writeln('Coverage is below the required baseline: '
        '${minimumOverall.toStringAsFixed(0)}% overall and '
        '${minimumDomain.toStringAsFixed(0)}% domain.');
    exitCode = 1;
  }
}

double _percentage(int hit, int lines) => lines == 0 ? 0 : hit * 100 / lines;
