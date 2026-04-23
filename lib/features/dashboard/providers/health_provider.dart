// Re-export from shared — health data providers are app-wide state, not
// dashboard-specific. Import from shared/providers/health_providers.dart directly
// for new code; this shim maintains backward compatibility within the dashboard.
export 'package:kynos/shared/providers/health_providers.dart';
