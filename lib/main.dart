import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'transferencia_screen.dart';
import 'cotacao_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/cotacao': (context) => const CotacaoScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/transferencia') {
          final saldo = settings.arguments as double;

          return MaterialPageRoute(
            builder: (context) => TransferenciaScreen(
              saldo: saldo,
            ),
          );
        }

        return null;
      },
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text(
          'NR BanK',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Text(
              'Login',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            TextField(
              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: InputDecoration(
                hintText: 'CPF ou Email',

                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                ),

                filled: true,
                fillColor: const Color(0xFF1E293B),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              obscureText: true,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: InputDecoration(
                hintText: 'Senha',

                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                ),

                filled: true,
                fillColor: const Color(0xFF1E293B),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),

                  padding: const EdgeInsets.all(16),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },

                child: const Text(
                  'Entrar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}