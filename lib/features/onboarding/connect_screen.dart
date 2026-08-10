import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                    'Your podcasts,\nwherever you listen.',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Connect Podpine to your Pinepods server. Your library stays available when the server doesn’t.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _serverController,
                          keyboardType: TextInputType.url,
                          autocorrect: false,
                          decoration: const InputDecoration(
                            labelText: 'Pinepods server',
                            hintText: 'https://podcasts.example.com',
                            prefixIcon: Icon(Icons.dns_outlined),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Enter your server URL'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _keyController,
                          obscureText: _obscureKey,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: InputDecoration(
                            labelText: 'API key',
                            hintText: 'Paste a key from Pinepods settings',
                            prefixIcon: const Icon(Icons.key_outlined),
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscureKey = !_obscureKey),
                              icon: Icon(
                                _obscureKey
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Enter an API key'
                              : null,
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
                  FilledButton(
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
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Connect securely'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: app.busy ? null : app.enterDemo,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Explore with a demo library'),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 16,
                        color: Colors.black45,
                      ),
                      SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          'Your key is stored in this device’s secure storage.',
                          style: TextStyle(
                            fontFamily: 'sans-serif',
                            fontSize: 12,
                            color: Colors.black45,
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
