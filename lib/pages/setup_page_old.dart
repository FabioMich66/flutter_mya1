import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/config_controller.dart';
import '../models/config_model.dart';
import 'launcher_page.dart';

class SetupPage extends ConsumerStatefulWidget {
  const SetupPage({super.key});

  @override
  ConsumerState<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends ConsumerState<SetupPage> {
  final uriCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void dispose() {
    uriCtrl.dispose();
    userCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configState = ref.watch(configProvider);

    final isLoading = configState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurazione')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: uriCtrl,
              decoration: const InputDecoration(labelText: 'URL'),
            ),
            TextField(
              controller: userCtrl,
              decoration: const InputDecoration(labelText: 'User'),
            ),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),

            const SizedBox(height: 20),

            // LOADING INDICATOR
            if (isLoading)
              const CircularProgressIndicator(),

            if (!isLoading)
              ElevatedButton(
                onPressed: () async {
                  if (uriCtrl.text.trim().isEmpty ||
                      userCtrl.text.trim().isEmpty ||
                      passCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Compila tutti i campi"),
                      ),
                    );
                    return;
                  }

                  final cfg = ConfigModel(
                    uri: uriCtrl.text.trim(),
                    user: userCtrl.text.trim(),
                    password: passCtrl.text.trim(),
                  );

                  final ok = await ref
                      .read(configProvider.notifier)
                      .saveAndLogin(cfg);

                  if (!mounted) return;

                  if (ok) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LauncherPage(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Errore di login o configurazione"),
                      ),
                    );
                  }
                },
                child: const Text('Salva'),
              ),
          ],
        ),
      ),
    );
  }
}

