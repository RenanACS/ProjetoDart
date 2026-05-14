import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Cotacao {
  final String codigo;
  final String nome;
  final String simbolo;
  final double valor;
  final double variacao;

  Cotacao({
    required this.codigo,
    required this.nome,
    required this.simbolo,
    required this.valor,
    required this.variacao,
  });

  factory Cotacao.fromJson(String codigo, Map<String, dynamic> json) {
    return Cotacao(
      codigo: codigo,
      nome: _getNome(codigo),
      simbolo: _getSimbolo(codigo),
      valor: double.tryParse(json['bid'] ?? '0') ?? 0,
      variacao: double.tryParse(json['pctChange'] ?? '0') ?? 0,
    );
  }

  static String _getNome(String codigo) {
    const nomes = {
      'USDBRL': 'Dólar Americano',
      'EURBRL': 'Euro',
      'GBPBRL': 'Libra Esterlina',
      'BTCBRL': 'Bitcoin',
    };
    return nomes[codigo] ?? codigo;
  }

  static String _getSimbolo(String codigo) {
    const simbolos = {
      'USDBRL': '\$',
      'EURBRL': '€',
      'GBPBRL': '£',
      'BTCBRL': '₿',
    };
    return simbolos[codigo] ?? '?';
  }
}

class CotacaoScreen extends StatefulWidget {
  const CotacaoScreen({super.key});

  @override
  State<CotacaoScreen> createState() => _CotacaoScreenState();
}

class _CotacaoScreenState extends State<CotacaoScreen> {
  List<Cotacao> _cotacoes = [];
  bool _isLoading = true;
  String _erro = '';
  DateTime? _ultimaAtualizacao;

  final String _apiUrl =
      'https://economia.awesomeapi.com.br/last/USD-BRL,EUR-BRL,GBP-BRL,BTC-BRL';

  final TextEditingController _calcCtrl = TextEditingController();
  List<Map<String, String>> _resultados = [];

  static const Color bgPrimary    = Colors.white;
  static const Color bgCard       = Color(0xFFF1F5F9);
  static const Color azul         = Color(0xFF2563EB);
  static const Color textoPrimary = Colors.black;
  static const Color textoSecond  = Color(0xFF94A3B8);
  static const Color verde        = Color(0xFF22C55E);
  static const Color vermelho     = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _buscarCotacoes();
  }

  @override
  void dispose() {
    _calcCtrl.dispose();
    super.dispose();
  }

  Future<void> _buscarCotacoes() async {
    setState(() {
      _isLoading = true;
      _erro = '';
    });
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<Cotacao> lista = [];
        data.forEach((chave, valor) {
          lista.add(Cotacao.fromJson(chave, valor));
        });
        setState(() {
          _cotacoes = lista;
          _isLoading = false;
          _ultimaAtualizacao = DateTime.now();
        });
      } else {
        setState(() {
          _erro = 'Erro ao buscar cotações (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _erro = 'Sem conexão com a internet';
        _isLoading = false;
      });
    }
  }

  void _converter() {
    final double? reais = double.tryParse(_calcCtrl.text.replaceAll(',', '.'));
    if (reais == null || reais <= 0 || _cotacoes.isEmpty) return;

    final resultados = <Map<String, String>>[];

    for (final cotacao in _cotacoes) {
      final double convertido = reais / cotacao.valor;
      final String valorFormatado = cotacao.codigo == 'BTCBRL'
          ? convertido.toStringAsFixed(8)
          : convertido.toStringAsFixed(2);

      resultados.add({
        'simbolo': cotacao.simbolo,
        'nome': cotacao.nome,
        'codigo': cotacao.codigo,
        'valor': '${cotacao.simbolo} $valorFormatado',
      });
    }

    setState(() {
      _resultados = resultados;
    });
  }

  String _formatarHora(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Cotações',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: azul),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: azul),
            onPressed: _buscarCotacoes,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: azul))
          : _erro.isNotEmpty
              ? _buildErro()
              : _buildConteudo(),
    );
  }

  Widget _buildErro() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: vermelho, size: 56),
          const SizedBox(height: 16),
          Text(
            _erro,
            style: const TextStyle(color: textoSecond, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _buscarCotacoes,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: azul,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConteudo() {
    return RefreshIndicator(
      onRefresh: _buscarCotacoes,
      color: azul,
      backgroundColor: bgCard,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildConversorBanner(),

          const SizedBox(height: 16),

          // resultado da conversão
          if (_resultados.isNotEmpty) ...[
            _buildResultadosConversor(),
            const SizedBox(height: 24),
          ],

          // banner do dolar
          if (_cotacoes.isNotEmpty) _buildBannerDestaque(_cotacoes.first),

          const SizedBox(height: 24),

          // cotações do dia
          const Text(
            'Cotações do dia',
            style: TextStyle(
              color: textoPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _ultimaAtualizacao != null
                ? 'Atualizado às ${_formatarHora(_ultimaAtualizacao!)} · puxe para atualizar'
                : 'Carregando...',
            style: const TextStyle(color: textoSecond, fontSize: 13),
          ),
          const SizedBox(height: 16),

          ..._cotacoes.map((c) => _buildCotacaoCard(c)),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // conversor de moedas
  Widget _buildConversorBanner() {
    return Container(
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
          // Cabeçalho
          const Row(
            children: [
              Icon(Icons.currency_exchange, color: Colors.white70, size: 18),
              SizedBox(width: 6),
              Text(
                'Conversor de Moedas',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // escrever valor
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _calcCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: '0,00',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 22),
                prefixText: 'R\$ ',
                prefixStyle: TextStyle(
                  color: Colors.white70,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              cursorColor: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          // btn converter
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _converter,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: azul,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Converter',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // resultado das cotações
  Widget _buildResultadosConversor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resultado da conversão',
          style: TextStyle(
            color: textoPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._resultados.map(
          (r) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: azul.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      r['simbolo']!,
                      style: const TextStyle(
                        color: azul,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    r['nome']!,
                    style: const TextStyle(
                      color: textoPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  r['valor']!,
                  style: const TextStyle(
                    color: azul,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerDestaque(Cotacao cotacao) {
    final bool subiu = cotacao.variacao >= 0;
    final Color cor = subiu ? verde : vermelho;

    return Container(
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
          Row(
            children: const [
              Icon(Icons.attach_money, color: Colors.white70, size: 18),
              SizedBox(width: 6),
              Text(
                'Dólar Americano',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'R\$ ${cotacao.valor.toStringAsFixed(4)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  subiu ? Icons.trending_up : Icons.trending_down,
                  color: cor,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${subiu ? '+' : ''}${cotacao.variacao.toStringAsFixed(2)}% hoje',
                  style: TextStyle(
                    color: cor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCotacaoCard(Cotacao cotacao) {
    final bool subiu = cotacao.variacao >= 0;
    final Color cor = subiu ? verde : vermelho;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: azul.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                cotacao.simbolo,
                style: const TextStyle(
                  color: azul,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cotacao.nome,
                  style: const TextStyle(
                    color: textoPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'R\$ ${cotacao.valor.toStringAsFixed(2)} por ${cotacao.simbolo}1',
                  style: const TextStyle(color: textoSecond, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    subiu ? Icons.arrow_upward : Icons.arrow_downward,
                    color: cor,
                    size: 13,
                  ),
                  Text(
                    '${cotacao.variacao.abs().toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: cor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}