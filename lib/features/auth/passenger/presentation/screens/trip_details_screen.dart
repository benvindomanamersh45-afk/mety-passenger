import 'package:flutter/material.dart';
import 'package:metty_pro/core/theme/app_colors.dart';
import 'package:metty_pro/core/theme/app_gradients.dart';
import 'package:metty_pro/features/auth/passenger/presentation/screens/rate_trip_screen.dart';
import 'package:metty_pro/features/auth/passenger/presentation/widgets/glass_card.dart';
import 'package:metty_pro/features/passenger/widgets/gradient_button.dart';
import 'package:metty_pro/core/models/trip_model.dart';

class TripDetailsScreen extends StatelessWidget {
  final Trip trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'DETALHES DA VIAGEM',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Status
            GlassCard(
              padding: EdgeInsets.all(20),
              borderRadius: 20,
              child: Column(
                children: [
                  Icon(
                    trip.status == 'COMPLETED' ? Icons.check_circle : 
                    trip.status == 'CANCELLED' ? Icons.cancel : 
                    Icons.access_time,
                    color: trip.status == 'COMPLETED' ? AppColors.metyGreen :
                           trip.status == 'CANCELLED' ? AppColors.metyOrange :
                           AppColors.metyBlue,
                    size: 60,
                  ),
                  SizedBox(height: 12),
                  Text(
                    trip.statusDisplay,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: trip.status == 'COMPLETED' ? AppColors.metyGreen :
                             trip.status == 'CANCELLED' ? AppColors.metyOrange :
                             AppColors.metyBlue,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Rota
            GlassCard(
              padding: EdgeInsets.all(20),
              borderRadius: 20,
              child: Column(
                children: [
                  _buildRoutePoint(
                    icon: Icons.circle,
                    color: AppColors.metyBlue,
                    title: 'ORIGEM',
                    address: trip.pickupAddress,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Container(
                      width: 2,
                      height: 30,
                      color: AppColors.white.withOpacity(0.2),
                    ),
                  ),
                  _buildRoutePoint(
                    icon: Icons.flag,
                    color: AppColors.metyGreen,
                    title: 'DESTINO',
                    address: trip.destinationAddress,
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Informações
            GlassCard(
              padding: EdgeInsets.all(20),
              borderRadius: 20,
              child: Column(
                children: [
                  _buildInfoRow('Data', '${trip.createdAt.day}/${trip.createdAt.month}/${trip.createdAt.year}'),
                  _buildInfoRow('Categoria', trip.categoryDisplay),
                  _buildInfoRow('Preço', '${trip.price.toStringAsFixed(0)} Kz'),
                  if (trip.driverName != null) _buildInfoRow('Motorista', trip.driverName!),
                  if (trip.distanceKm != null) _buildInfoRow('Distância', '${trip.distanceKm!.toStringAsFixed(1)} km'),
                  if (trip.estimatedDuration != null) _buildInfoRow('Duração', '${trip.estimatedDuration} min'),
                  if (trip.passengerRating != null) 
                    _buildInfoRow('Avaliação', '⭐ ${trip.passengerRating}/5'),
                  if (trip.passengerComment != null && trip.passengerComment!.isNotEmpty) 
                    _buildInfoRow('Comentário', trip.passengerComment!),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Ações
            if (trip.status == 'REQUESTED')
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: GradientButton(
                  text: 'CANCELAR VIAGEM',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Funcionalidade em desenvolvimento'),
                        backgroundColor: AppColors.metyOrange,
                      ),
                    );
                  },
                  gradient: LinearGradient(colors: [AppColors.metyOrange, AppColors.metyOrange]),
                  fullWidth: true,
                  type: null,
                ),
              ),

            if (trip.status == 'COMPLETED' && trip.passengerRating == null)
              GradientButton(
                text: 'AVALIAR VIAGEM',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RateTripScreen(trip: trip),
                    ),
                  );
                },
                gradient: AppGradients.mety,
                fullWidth: true,
                type: null,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutePoint({
    required IconData icon,
    required Color color,
    required String title,
    required String address,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.white.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 4),
              Text(
                address,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.white.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
