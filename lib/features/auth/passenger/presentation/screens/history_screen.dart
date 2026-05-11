import 'package:flutter/material.dart';
import 'package:metty_pro/core/theme/app_colors.dart';
import 'package:metty_pro/core/theme/app_gradients.dart';
import 'package:metty_pro/features/auth/passenger/presentation/widgets/glass_card.dart';
import 'package:metty_pro/features/passenger/widgets/gradient_button.dart';
import 'package:metty_pro/core/api/api_client.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _viagens = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Método direto e simples
      print('🔍 Buscando histórico...');
      final response = await ApiClient.get('/trips/history/');
      
      print('📦 Resposta: $response');
      
      if (response is List) {
        setState(() {
          _viagens = response;
          _isLoading = false;
        });
        print('✅ Encontradas ${response.length} viagens');
      } else {
        setState(() {
          _errorMessage = 'Formato de resposta inválido';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erro: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatarData(String dataStr) {
    try {
      if (dataStr.isEmpty) return 'Data não disponível';
      DateTime data = DateTime.parse(dataStr);
      return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
    } catch (e) {
      return dataStr;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'COMPLETED': return 'Concluída';
      case 'CANCELLED': return 'Cancelada';
      case 'REQUESTED': return 'Solicitada';
      case 'ACCEPTED': return 'Aceita';
      case 'STARTED': return 'Em andamento';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED': return Colors.green;
      case 'CANCELLED': return Colors.red;
      case 'REQUESTED': return Colors.orange;
      case 'ACCEPTED': return Colors.blue;
      case 'STARTED': return Colors.purple;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text('MINHAS VIAGENS'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _carregarHistorico,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.metyBlue),
                  SizedBox(height: 16),
                  Text('Carregando histórico...', style: TextStyle(color: Colors.white70)),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 60),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao carregar',
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _carregarHistorico,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.metyBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          ),
                          child: const Text('TENTAR NOVAMENTE'),
                        ),
                      ],
                    ),
                  ),
                )
              : _viagens.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 80, color: Colors.white24),
                          const SizedBox(height: 16),
                          const Text(
                            'Nenhuma viagem encontrada',
                            style: TextStyle(fontSize: 18, color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Suas viagens aparecerão aqui',
                            style: TextStyle(color: Colors.white38),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _carregarHistorico,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.metyBlue,
                            ),
                            child: const Text('ATUALIZAR'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _viagens.length,
                      itemBuilder: (context, index) {
                        final v = _viagens[index];
                        final statusColor = _getStatusColor(v['status'] ?? '');
                        
                        return GlassCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          borderRadius: 15,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status e data
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: statusColor),
                                    ),
                                    child: Text(
                                      _getStatusText(v['status'] ?? ''),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatarData(v['requested_at'] ?? ''),
                                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Origem
                              Row(
                                children: [
                                  const Icon(Icons.circle, color: AppColors.metyBlue, size: 12),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      v['pickup_address'] ?? 'Origem não informada',
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              
                              // Linha conectora
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Container(
                                  width: 2,
                                  height: 20,
                                  color: Colors.white24,
                                ),
                              ),
                              const SizedBox(height: 4),
                              
                              // Destino
                              Row(
                                children: [
                                  const Icon(Icons.flag, color: AppColors.metyGreen, size: 12),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      v['destination_address'] ?? 'Destino não informado',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Preço e categoria
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.directions_car, color: AppColors.metyOrange, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        v['category'] ?? 'ECONOMIC',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${v['price'] ?? 0} Kz',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.metyGreen,
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Motorista (se houver)
                              if (v['driver_name'] != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 14, color: Colors.white54),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Motorista: ${v['driver_name']}',
                                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
