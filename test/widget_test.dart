import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:podpine/app_controller.dart';
import 'package:podpine/core/database/app_database.dart';
import 'package:podpine/core/storage/credential_store.dart';
import 'package:podpine/features/onboarding/connect_screen.dart';
import 'package:podpine/providers.dart';

void main() {
  testWidgets('shows Pinepods onboarding on first launch', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final app = AppController(
      database,
      const CredentialStore(FlutterSecureStorage()),
    )..initialized = true;
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appControllerProvider.overrideWith((ref) => app)],
        child: const MaterialApp(home: ConnectScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Your podcasts,\nwherever you listen.'), findsOneWidget);
    expect(find.text('Connect securely'), findsOneWidget);
    expect(find.text('Explore with a demo library'), findsOneWidget);
  });
}
