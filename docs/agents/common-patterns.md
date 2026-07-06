# Common Patterns

Concise snippets for recurring KYNOS patterns. See [file-templates.md](file-templates.md) for full scaffolds.

## Riverpod feature provider

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_feature_provider.g.dart';

@riverpod
class MyFeature extends _$MyFeature {
  @override
  FutureOr<MyState> build() async {
    final useCase = ref.watch(myUseCaseProvider);
    final result = await useCase();
    if (result.failure != null) {
      throw result.failure!;
    }
    return MyState(data: result.value);
  }
}
```

Run `dart run build_runner build --delete-conflicting-outputs` after adding `@riverpod`.

## AsyncValue in UI

```dart
final state = ref.watch(myFeatureProvider);

return state.when(
  data: (data) => MyContent(data: data),
  loading: () => const KynosSkeleton(),
  error: (error, _) => KynosCard(child: Text(error.toString())),
);
```

## Repository return type

```dart
Future<({HealthSummary? summary, Failure? failure})> getToday();
```

Never throw across layer boundaries — return `Failure` in the record.

## Route registration

In `lib/app/router.dart`:

```dart
// Add to Routes class:
static const myFeature = '/my-feature';

// Add GoRoute in routerProvider:
GoRoute(
  path: Routes.myFeature,
  builder: (context, state) => const MyFeaturePage(),
),
```

## DI provider in shared/providers

```dart
final myRepositoryProvider = Provider<MyRepository>((ref) {
  return MyRepositoryImpl(
    healthStore: ref.watch(healthStoreProvider),
  );
});
```

Features import `shared/providers/` — never `infrastructure/`.

## Invalidate related providers

After mutating health data:

```dart
invalidateHealthProviders(ref);  // from health_providers.dart
```

## Design system spacing

```dart
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;

const Gap(tokens.Spacing.md),
```

Never use `Gap(16)` or raw `SizedBox` for semantic spacing.
