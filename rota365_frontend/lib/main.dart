import 'app_imports.dart';

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
          '/': (_) => const UsuarioListScreen(),

          '/usuarios': (_) => const UsuarioListScreen(),
          '/usuarios/detalhes': (_) => const DetalhesUsuarioScreen(),

          // Rota principal do formulário
          '/usuarios/form': (_) => const UsuarioFormScreen(),

          // Alias para não quebrar o botão que já criámos na lista
          '/usuarios/novo': (_) => const UsuarioFormScreen(),
        },
      ),
    );
  }
}