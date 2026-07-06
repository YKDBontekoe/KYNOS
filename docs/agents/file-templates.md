# File Templates

Copy-paste scaffolds for new KYNOS files. Replace `<name>` placeholders.

## Feature page

`lib/features/<name>/presentation/pages/<name>_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kynos/core/theme/spacing.dart' as tokens;
import 'package:kynos/core/theme/theme.dart';
import 'package:kynos/shared/widgets/widgets.dart';

class <Name>Page extends ConsumerWidget {
  const <Name>Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.kynosTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(tokens.Spacing.lg),
          children: [
            Text('<Name>', style: theme.pageTitleStyle),
            const Gap(tokens.Spacing.md),
            const KynosCard(child: Text('Content')),
          ],
        ),
      ),
    );
  }
}
```

## Feature provider

`lib/features/<name>/providers/<name>_provider.dart`

```dart
import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part '<name>_provider.g.dart';

@riverpod
class <Name> extends _$<Name> {
  @override
  FutureOr<void> build() {}
}
```

## Repository interface

`lib/domain/repositories/<name>_repository.dart`

```dart
import 'package:kynos/core/errors/failures.dart';

abstract interface class <Name>Repository {
  Future<({String? value, Failure? failure})> doSomething();
}
```

## Use-case

`lib/domain/usecases/<name>/<action>_usecase.dart`

```dart
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/repositories/<name>_repository.dart';

class <Action>UseCase {
  const <Action>UseCase(this._repository);

  final <Name>Repository _repository;

  Future<({String? value, Failure? failure})> call() {
    return _repository.doSomething();
  }
}
```

## Infrastructure repository

`lib/infrastructure/<area>/<name>_repository_impl.dart`

```dart
import 'package:kynos/core/errors/failures.dart';
import 'package:kynos/domain/repositories/<name>_repository.dart';

class <Name>RepositoryImpl implements <Name>Repository {
  @override
  Future<({String? value, Failure? failure})> doSomething() async {
    try {
      // platform integration
      return (value: 'ok', failure: null);
    } on Object catch (e) {
      return (value: null, failure: StorageFailure(e.toString()));
    }
  }
}
```

## Shared DI provider

`lib/shared/providers/<name>_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/repositories/<name>_repository.dart';
import 'package:kynos/infrastructure/<area>/<name>_repository_impl.dart';

final <name>RepositoryProvider = Provider<<Name>Repository>((ref) {
  return <Name>RepositoryImpl();
});
```

## Use-case test

`test/domain/usecases/<name>/<action>_usecase_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/domain/usecases/<name>/<action>_usecase.dart';
import 'package:mocktail/mocktail.dart';

class Mock<Name>Repository extends Mock implements <Name>Repository {}

void main() {
  late Mock<Name>Repository repository;
  late <Action>UseCase useCase;

  setUp(() {
    repository = Mock<Name>Repository();
    useCase = <Action>UseCase(repository);
  });

  test('returns value on success', () async {
    when(() => repository.doSomething())
        .thenAnswer((_) async => (value: 'ok', failure: null));

    final result = await useCase();

    expect(result.value, 'ok');
    expect(result.failure, isNull);
  });
}
```

## Widget smoke test

`test/features/<name>/presentation/pages/<name>_page_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kynos/features/<name>/presentation/pages/<name>_page.dart';

void main() {
  testWidgets('<Name>Page renders', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: <Name>Page())),
    );
    expect(find.text('<Name>'), findsOneWidget);
  });
}
```

After creating providers, run:

```bash
dart run build_runner build --delete-conflicting-outputs
dart run tool/generate_codemap.dart
```
