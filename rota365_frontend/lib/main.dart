import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:api_compartilhado/api_compartilhado.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const Rota365App());
}

class Rota365App extends StatelessWidget {
  const Rota365App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UsuarioProvider>(
          create: (_) => UsuarioProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Rota365',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF1B2A6B),
          scaffoldBackgroundColor: const Color(0xFFF4F5F7),
        ),

        initialRoute: '/',

        routes: {
          '/': (_) => const Rota365HomePlaceholder(),
        },
      ),
    );
  }
}

class Rota365HomePlaceholder extends StatelessWidget {
  const Rota365HomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = context.watch<UsuarioProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rota365'),
      ),
      body: Center(
        child: usuarioProvider.temUsuarioLogado
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bem-vindo, ${usuarioProvider.usuarioLogado?.nome ?? ''}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UsuarioProvider>().logout();
                    },
                    child: const Text('Sair'),
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: usuarioProvider.isLoading
                    ? null
                    : () async {
                        await context.read<UsuarioProvider>().login(
                              username: 'admin',
                              senha: '123456',
                            );
                      },
                child: usuarioProvider.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Testar Login'),
              ),
      ),
    );
  }
}