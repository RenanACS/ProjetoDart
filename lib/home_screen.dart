import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? _fotoPerfil;
  final _picker = ImagePicker();

  Future<void> _selecionarFoto(ImageSource source) async {
    final foto = await _picker.pickImage(source: source, imageQuality: 80);
    if (foto != null) setState(() => _fotoPerfil = foto);
  }

  void _mostrarOpcoesFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF94A3B8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Foto de perfil',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF2563EB)),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.pop(ctx);
                _selecionarFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF2563EB)),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(ctx);
                _selecionarFoto(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'NR BanK',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _mostrarOpcoesFoto,
              child: CircleAvatar(
                backgroundColor: const Color(0xFF2563EB),
                backgroundImage: _fotoPerfil != null
                    ? FileImage(File(_fotoPerfil!.path))
                    : null,
                child: _fotoPerfil == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Olá, Natâny',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bem-vindo (a) ao seu banco',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saldo disponível',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        Icon(Icons.visibility, color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'R\$ 6.430,77',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _actionButton(context, Icons.pix, 'Pix', null),
                        _actionButton(context, Icons.qr_code, 'Boleto', null),
                        _actionButton(context, Icons.send, 'Transferir', '/transferencia'),
                        _actionButton(context, Icons.currency_exchange, 'Cotação', '/cotacao'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              const Text(
                'Últimas movimentações',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _transactionCard(
                'PIX recebido',
                'Hoje • 10:30',
                '+ R\$ 400,00',
                Icons.arrow_downward,
                const Color(0xFF22C55E),
              ),
              const SizedBox(height: 16),
              _transactionCard(
                'Pagamento boleto',
                'Hoje • 09:15',
                '- R\$ 120,00',
                Icons.arrow_upward,
                const Color(0xFFEF4444),
              ),
              const SizedBox(height: 16),
              _transactionCard(
                'Transferência enviada',
                'Ontem • 18:00',
                '- R\$ 80,00',
                Icons.swap_horiz,
                const Color(0xFFEF4444),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'Cartões'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Invest.'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config.'),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String text, String? rota) {
    return GestureDetector(
      onTap: rota == null
          ? null
          : () {
              if (rota == '/transferencia') {
                Navigator.pushNamed(context, rota, arguments: 6430.77);
              } else {
                Navigator.pushNamed(context, rota);
              }
            },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionCard(
    String title,
    String date,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  date,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
