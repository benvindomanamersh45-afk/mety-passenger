import 'package:flutter/material.dart';
import 'package:metty_pro/core/theme/app_colors.dart';
import 'package:metty_pro/core/theme/app_gradients.dart';
import 'package:metty_pro/features/auth/passenger/presentation/widgets/glass_card.dart';
import 'package:metty_pro/features/passenger/widgets/gradient_button.dart';
import 'package:metty_pro/core/api/api_client.dart';
import 'package:metty_pro/core/models/trip_model.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  List<Trip> _availableTrips = [];
  bool _isLoading = true;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableTrips();
  }

  Future<void> _loadAvailableTrips() async {
    setState(() => _isLoading = true);
    try {
      final trips = await ApiClient.getPendingTrips();
      setState(() {
        _availableTrips = trips;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar viagens: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptTrip(Trip trip) async {
    try {
      // TODO: Implementar aceitar viagem
      print('Aceitar viagem ${trip.id}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Funcionalidade em desenvolvimento'),
          backgroundColor: AppColors.metyOrange,
        ),
      );
    } catch (e) {
      print('Erro: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'MOTORISTA',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Row(
            children: [
              Text(
                _isOnline ? 'ONLINE' : 'OFFLINE',
                style: TextStyle(
                  color: _isOnline ? AppColors.metyGreen : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: _isOnline,
                onChanged: (value) {
                  setState(() => _isOnline = value);
                },
                activeColor: AppColors.metyGreen,
                inactiveThumbColor: Colors.red,
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Status indicator
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8),
            color: _isOnline 
                ? AppColors.metyGreen.withOpacity(0.1) 
                : Colors.red.withOpacity(0.1),
            child: Center(
              child: Text(
                _isOnline 
                    ? '✅ Você está ONLINE - Viagens disponíveis' 
                    : '⛔ Você está OFFLINE - Ative para receber viagens',
                style: TextStyle(
                  color: _isOnline ? AppColors.metyGreen : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.metyBlue))
                : _availableTrips.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.timer_rounded,
                                size: 80,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Nenhuma viagem disponível',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'As viagens solicitadas aparecerão aqui',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _loadAvailableTrips,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.metyBlue,
                                ),
                                child: Text('ATUALIZAR'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _availableTrips.length,
                        itemBuilder: (context, index) {
                          final trip = _availableTrips[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12), // ← MARGEM AQUI
                            child: GlassCard(
                              padding: EdgeInsets.all(16),
                              borderRadius: 15,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Passageiro
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: AppColors.metyBlue.withOpacity(0.2),
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: AppColors.metyBlue,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'PASSAGEIRO',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: AppColors.metyBlue,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                            Text(
                                              trip.passengerName,
                                              style: TextStyle(
                                                color: AppColors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.metyOrange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.metyOrange),
                                        ),
                                        child: Text(
                                          '${trip.estimatedDuration ?? 5} min',
                                          style: TextStyle(
                                            color: AppColors.metyOrange,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  SizedBox(height: 16),
                                  
                                  // Rota
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          Icon(Icons.circle, color: AppColors.metyBlue, size: 12),
                                          Container(
                                            width: 2,
                                            height: 30,
                                            color: AppColors.white.withOpacity(0.2),
                                          ),
                                          Icon(Icons.flag, color: AppColors.metyGreen, size: 12),
                                        ],
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'ORIGEM',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: AppColors.metyBlue,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              trip.pickupAddress,
                                              style: TextStyle(
                                                color: AppColors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              'DESTINO',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: AppColors.metyGreen,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              trip.destinationAddress,
                                              style: TextStyle(
                                                color: AppColors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  SizedBox(height: 16),
                                  
                                  // Detalhes e botão
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'PREÇO',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.white.withOpacity(0.6),
                                            ),
                                          ),
                                          Text(
                                            '${trip.price.toStringAsFixed(0)} Kz',
                                            style: TextStyle(
                                              color: AppColors.metyGreen,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                      GradientButton(
                                        text: 'ACEITAR',
                                        onPressed: () => _acceptTrip(trip),
                                        gradient: AppGradients.mety,
                                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        fullWidth: false,
                                        type: null,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
