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

    print("🔵 [SetupPage] build() → isLoading: $isLoading");

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

            if (isLoading)
              const CircularProgressIndicator(),

            if (!isLoading)
              ElevatedButton(
                onPressed: () async {
                  print("🟡 [SetupPage] Bottone SALVA premuto");

                  if (uriCtrl.text.trim().isEmpty ||
                      userCtrl.text.trim().isEmpty ||
                      passCtrl.text.trim().isEmpty) {
                    print("🔴 [SetupPage] Campi vuoti → blocco salvataggio");
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

                  print("🟡 [SetupPage] Config inserita: ${cfg.toJson()}");
                  print("🟡 [SetupPage] Chiamo saveAndLogin()...");

                  final ok = await ref
                      .read(configProvider.notifier)
                      .saveAndLogin(cfg);

                  print("🟢 [SetupPage] saveAndLogin() ha restituito: $ok");

                  if (!mounted) {
                    print("🔴 [SetupPage] Widget non più montato → stop");
                    return;
                  }

                  if (ok) {
                    print("🟢 [SetupPage] Login OK → navigo a LauncherPage");

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LauncherPage(),
                      ),
                    );
                  } else {
                    print("🔴 [SetupPage] Login FALLITO → mostro snackbar");

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
