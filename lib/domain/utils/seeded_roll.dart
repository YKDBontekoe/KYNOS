/// Deterministic 32-bit roll safe for VM and JavaScript (no >53-bit intermediates).
int seededRoll(int seed) {
  var x = seed & 0xffffffff;
  x = _imul32(x, 0x9e3779b1);
  x ^= x >> 16;
  x = _imul32(x, 0x85ebca6b);
  x ^= x >> 13;
  x = _imul32(x, 0xc2b2ae35);
  x ^= x >> 16;
  return x & 0x7fffffff;
}

int _imul32(int a, int b) {
  final lo = (a & 0xffff) * (b & 0xffff);
  final mid = (a >> 16) * (b & 0xffff) + (lo >> 16);
  return ((mid & 0xffff) << 16) | (lo & 0xffff);
}
