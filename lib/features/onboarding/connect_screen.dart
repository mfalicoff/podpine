import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../providers.dart';

class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController();
  final _keyController = TextEditingController();
  bool _obscureKey = true;

  @override
  void dispose() {
    _serverController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(appControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: FocusTraversalGroup(
                policy: OrderedTraversalPolicy(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: PodpineTheme.pine,
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: const Icon(
                          Icons.park_rounded,
                          color: Color(0xFFF3C969),
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      context.l10n.onboardingTitle,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      context.l10n.onboardingBody,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(1),
                            child: TextFormField(
                              controller: _serverController,
                              keyboardType: TextInputType.url,
                              autocorrect: false,
                              decoration: InputDecoration(
                                labelText: context.l10n.pinepodsServer,
                                hintText: context.l10n.serverHint,
                                prefixIcon: const Icon(Icons.dns_outlined),
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? context.l10n.serverRequired
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 14),
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(2),
                            child: TextFormField(
                              controller: _keyController,
                              obscureText: _obscureKey,
                              autocorrect: false,
                              enableSuggestions: false,
                              decoration: InputDecoration(
                                labelText: context.l10n.apiKey,
                                hintText: context.l10n.apiKeyHint,
                                prefixIcon: const Icon(Icons.key_outlined),
                                suffixIcon: IconButton(
                                  tooltip: _obscureKey
                                      ? context.l10n.showApiKey
                                      : context.l10n.hideApiKey,
                                  onPressed: () => setState(
                                    () => _obscureKey = !_obscureKey,
                                  ),
                                  icon: Icon(
                                    _obscureKey
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? context.l10n.apiKeyRequired
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (app.error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        app.error!,
                        style: const TextStyle(color: Color(0xFFAE3926)),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(3),
                      child: FilledButton(
                        onPressed: app.busy ? null : _connect,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: app.busy
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(context.l10n.connectSecurely),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(4),
                      child: OutlinedButton(
                        onPressed: app.busy ? null : app.enterDemo,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(context.l10n.exploreDemo),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            context.l10n.secureStorageExplanation,
                            style: TextStyle(
                              fontFamily: 'sans-serif',
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref
          .read(appControllerProvider)
          .connect(_serverController.text, _keyController.text);
    } catch (_) {
      // The controller exposes a user-facing error next to the form.
    }
  }
}
