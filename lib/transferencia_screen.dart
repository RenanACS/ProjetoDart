import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class TransferenciaScreen extends StatefulWidget {
  final double saldo;

  const TransferenciaScreen({super.key, required this.saldo});

  @override
  State<TransferenciaScreen> createState() => _TransferenciaScreenState();
}

class _TransferenciaScreenState extends State<TransferenciaScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _destinCtrl    = TextEditingController();
  final _valorCtrl     = TextEditingController();
  final _descricaoCtrl = TextEditingController();

  bool _processando  = false;
  bool _saldoVisivel = true;

  static const Color bgPrimary   = Colors.white;
  static const Color bgCard      = Color(0xFFF1F5F9);
  static const Color azul        = Color(0xFF2563EB);
  static const Color textoPrimary = Colors.black;
  static const Color textoSecond  = Color(0xFF94A3B8);
  static const Color verde        = Color(0xFF22C55E);
  static const Color vermelho     = Color(0xFFEF4444);

  @override
  void dispose() {
    _destinCtrl.dispose();
    _valorCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmarTransferencia() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Confirmar transferência?',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _linhaResumo('Para', _destinCtrl.text),
            const SizedBox(height: 8),
            _linhaResumo(
              'Valor',
              'R\$ ${double.parse(_valorCtrl.text.replaceAll(',', '.')).toStringAsFixed(2)}',
            ),
            if (_descricaoCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              _linhaResumo('Descrição', _descricaoCtrl.text),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: textoSecond)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: azul,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _processando = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _processando = false);

    if (!mounted) return;

    final valor = double.parse(_valorCtrl.text.replaceAll(',', '.'));
    final destinatario = _destinCtrl.text;
    final descricao = _descricaoCtrl.text;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: verde, size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Transferência realizada!',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _linhaResumo('Para', destinatario),
            const SizedBox(height: 8),
            _linhaResumo('Valor', 'R\$ ${valor.toStringAsFixed(2)}'),
            if (descricao.isNotEmpty) ...[
              const SizedBox(height: 8),
              _linhaResumo('Descrição', descricao),
            ],
          ],
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () => _compartilharComprovante(destinatario, valor, descricao),
            icon: const Icon(Icons.share, color: azul),
            label: const Text('Compartilhar', style: TextStyle(color: azul)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: azul),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: azul,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Concluir'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    Navigator.pop(context, {
      'sucesso': true,
      'valor': valor,
      'destinatario': destinatario,
    });
  }

  void _compartilharComprovante(String destinatario, double valor, String descricao) {
    final agora = DateTime.now();
    final data =
        '${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year} '
        '${agora.hour.toString().padLeft(2, '0')}:${agora.minute.toString().padLeft(2, '0')}';

    final texto = 'Comprovante de Transferência - NR BanK\n'
        'Para: $destinatario\n'
        'Valor: R\$ ${valor.toStringAsFixed(2)}\n'
        '${descricao.isNotEmpty ? 'Descrição: $descricao\n' : ''}'
        'Data: $data';

    SharePlus.instance.share(ShareParams(text: texto));
  }

  Widget _linhaResumo(String label, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: const TextStyle(color: textoSecond, fontSize: 14)),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(
              color: textoPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
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
          'Transferência',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: azul),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Card de saldo — igual ao da Home
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Saldo disponível',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _saldoVisivel = !_saldoVisivel),
                          child: Icon(
                            _saldoVisivel
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _saldoVisivel
                          ? 'R\$ ${widget.saldo.toStringAsFixed(2)}'
                          : 'R\$ ••••••',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _labelCampo('DESTINATÁRIO'),
              const SizedBox(height: 8),
              _buildInput(
                controller: _destinCtrl,
                hint: 'CPF, e-mail ou chave Pix',
                icone: Icons.person_outline,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe o destinatário' : null,
              ),

              const SizedBox(height: 20),

              _labelCampo('VALOR (R\$)'),
              const SizedBox(height: 8),
              _buildInput(
                controller: _valorCtrl,
                hint: '0,00',
                icone: Icons.attach_money,
                tipoTeclado:
                    const TextInputType.numberWithOptions(decimal: true),
                formatadores: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o valor';
                  final valor = double.tryParse(v.replaceAll(',', '.')) ?? 0;
                  if (valor <= 0) return 'Valor deve ser maior que zero';
                  if (valor > widget.saldo) return 'Saldo insuficiente';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              _labelCampo('DESCRIÇÃO (opcional)'),
              const SizedBox(height: 8),
              _buildInput(
                controller: _descricaoCtrl,
                hint: 'Ex: Aluguel, jantar...',
                icone: Icons.notes,
                maxLength: 80,
              ),

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _processando ? null : _confirmarTransferencia,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: azul,
                    disabledBackgroundColor: bgCard,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _processando
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Transferir agora',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: textoSecond),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: textoSecond, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _labelCampo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        color: textoSecond,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icone,
    TextInputType? tipoTeclado,
    List<TextInputFormatter>? formatadores,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: textoPrimary),
      keyboardType: tipoTeclado,
      inputFormatters: formatadores,
      validator: validator,
      maxLength: maxLength,
      buildCounter: maxLength != null
          ? (_, {required currentLength, required isFocused, maxLength}) =>
              Text(
                '$currentLength/$maxLength',
                style: const TextStyle(color: textoSecond, fontSize: 11),
              )
          : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: textoSecond),
        prefixIcon: Icon(icone, color: textoSecond, size: 20),
        filled: true,
        fillColor: bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: azul, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: vermelho),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: vermelho, width: 2),
        ),
      ),
    );
  }
}