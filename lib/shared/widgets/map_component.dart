import 'package:flutter/material.dart';
import 'package:metty_pro/core/constants/theme/app_colors.dart';
import 'package:metty_pro/core/constants/theme/app_gradients.dart';
//import 'package:metty_pro/core/theme/app_colors.dart' hide AppColors;
//import 'package:metty_pro/core/theme/app_gradients.dart' hide AppGradients;
import 'package:metty_pro/features/auth/passenger/presentation/widgets/glass_card.dart';
//import 'package:metty_pro/features/passenger/widgets/glass_card.dart';

class MapMarker {
  final String id;
  final String title;
  final String subtitle;
  final double latitude;
  final double longitude;
  final Color color;
  final IconData icon;
  final bool isSelected;

  const MapMarker({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
    this.color = AppColors.primaryRed,
    this.icon = Icons.location_on_rounded,
    this.isSelected = false,
  });
}

class PremiumMap extends StatefulWidget {
  final List<MapMarker> markers;
  final Function(MapMarker)? onMarkerTap;
  final bool showControls;
  final bool interactive;
  final double initialZoom;
  final LatLng? center;
  final String? selectedMunicipality;

  const PremiumMap({
    super.key,
    this.markers = const [],
    this.onMarkerTap,
    this.showControls = true,
    this.interactive = true,
    this.initialZoom = 12.0,
    this.center,
    this.selectedMunicipality,
  });

  @override
  State<PremiumMap> createState() => _PremiumMapState();
}

class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);
}

class _PremiumMapState extends State<PremiumMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _zoomLevel = 12.0;
  LatLng _viewCenter = const LatLng(-9.6600, 20.3900); // Saurimo, Lunda Sul
  MapMarker? _selectedMarker;

  final Map<String, LatLng> _municipalities = {
    'Saurimo': const LatLng(-9.6600, 20.3900),
    'Cassengo': const LatLng(-9.5833, 20.5167),
    'Muangueji': const LatLng(-9.7167, 20.4333),
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    if (widget.center != null) {
      _viewCenter = widget.center!;
    } else if (widget.selectedMunicipality != null &&
        _municipalities.containsKey(widget.selectedMunicipality)) {
      _viewCenter = _municipalities[widget.selectedMunicipality]!;
    }

    _zoomLevel = widget.initialZoom;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + 1).clamp(8.0, 18.0);
    });
    _controller.forward(from: 0);
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - 1).clamp(8.0, 18.0);
    });
    _controller.forward(from: 0);
  }

  void _centerOnLocation(LatLng location) {
    setState(() {
      _viewCenter = location;
    });
  }

  void _selectMunicipality(String municipality) {
    if (_municipalities.containsKey(municipality)) {
      _centerOnLocation(_municipalities[municipality]!);
      setState(() {
        _zoomLevel = 13.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Mapa de fundo (simulação)
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.darkGray.withOpacity(0.9),
                AppColors.black,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: CustomPaint(
            painter: _MapPainter(
              center: _viewCenter,
              zoom: _zoomLevel,
              markers: widget.markers,
              selectedMarker: _selectedMarker,
            ),
          ),
        ),

        // Controles do mapa
        if (widget.showControls) ...[
          // Controles de zoom
          Positioned(
            right: 16,
            bottom: 100,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              borderRadius: 15,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _zoomIn,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.white.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 1,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.white.withOpacity(0.1),
                  ),
                  GestureDetector(
                    onTap: _zoomOut,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.white.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.remove_rounded,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botão de localização atual
          Positioned(
            right: 16,
            bottom: 180,
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              borderRadius: 15,
              child: GestureDetector(
                onTap: () {
                  // TODO: Implementar localização atual
                },
                child: Icon(
                  Icons.my_location_rounded,
                  color: AppColors.primaryRed,
                  size: 24,
                ),
              ),
            ),
          ),
        ],

        // Marcadores
        ...widget.markers.map((marker) {
          final markerPosition = _calculateMarkerPosition(marker, size);

          return Positioned(
            left: markerPosition.dx - 20,
            top: markerPosition.dy - 40,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMarker = marker;
                });
                widget.onMarkerTap?.call(marker);
              },
              child: _buildMarker(marker),
            ),
          );
        }).toList(),

        // Informações do município selecionado
        if (_selectedMarker != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildMarkerInfo(_selectedMarker!),
          ),

        // Seletor de municípios
        if (widget.showControls)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildMunicipalitySelector(),
          ),
      ],
    );
  }

  Widget _buildMarker(MapMarker marker) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: marker.isSelected ? AppGradients.premium : null,
            color: marker.isSelected ? null : marker.color.withOpacity(0.9),
            shape: BoxShape.circle,
            border: Border.all(
              color: marker.isSelected ? Colors.transparent : AppColors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: marker.color.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            marker.icon,
            color: marker.isSelected ? AppColors.black : AppColors.white,
            size: 20,
          ),
        ),
        if (marker.isSelected)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppColors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              marker.title,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMarkerInfo(MapMarker marker) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: marker.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: marker.color),
            ),
            child: Icon(
              marker.icon,
              color: marker.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  marker.title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  marker.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedMarker = null;
              });
            },
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMunicipalitySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _municipalities.entries.map((entry) {
          final isSelected = widget.selectedMunicipality == entry.key;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              borderRadius: 20,
              child: GestureDetector(
                onTap: () => _selectMunicipality(entry.key),
                child: Text(
                  entry.key.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppColors.primaryGold
                        : AppColors.white.withOpacity(0.7),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Offset _calculateMarkerPosition(MapMarker marker, Size containerSize) {
    final scale = _zoomLevel / 12.0;
    final centerX = containerSize.width / 2;
    final centerY = containerSize.height / 2;

    final dx = (marker.longitude - _viewCenter.longitude) * 10000 * scale;
    final dy = (marker.latitude - _viewCenter.latitude) * -10000 * scale;

    return Offset(centerX + dx, centerY + dy);
  }
}

class _MapPainter extends CustomPainter {
  final LatLng center;
  final double zoom;
  final List<MapMarker> markers;
  final MapMarker? selectedMarker;

  _MapPainter({
    required this.center,
    required this.zoom,
    required this.markers,
    this.selectedMarker,
  });

  @override
  void paint(Canvas canvas, Size size) {

    final fillPaint = Paint()
      ..color = AppColors.darkGray
      ..style = PaintingStyle.fill;

    // Desenhar ruas
    final streetPaint = Paint()
      ..color = AppColors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Desenhar o "mapa"
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, fillPaint);

    // Desenhar ruas principais
    for (double i = 50; i < size.width; i += 80) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), streetPaint);
    }
    for (double i = 50; i < size.height; i += 80) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), streetPaint);
    }

    // Desenhar rio (Saurimo tem rios)
    final riverPaint = Paint()
      ..color = AppColors.info.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.4, size.width * 0.7,
          size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.5, size.width * 0.6,
          size.height * 0.7);

    canvas.drawPath(riverPath, riverPaint);

    // Desenhar áreas verdes (parques)
    final parkPaint = Paint()
      ..color = AppColors.success.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.2, size.height * 0.8),
        width: 100,
        height: 60,
      ),
      parkPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.8, size.height * 0.2),
        width: 80,
        height: 80,
      ),
      parkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Componente de seleção de localização
class LocationPicker extends StatefulWidget {
  final ValueChanged<MapMarker> onLocationSelected;
  final MapMarker? initialLocation;

  const LocationPicker({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  MapMarker? _selectedLocation;
  final List<MapMarker> _popularLocations = [
    const MapMarker(
      id: 'airport',
      title: 'Aeroporto Saurimo',
      subtitle: 'Aeroporto Internacional de Saurimo',
      latitude: -9.6500,
      longitude: 20.4300,
      color: AppColors.saurimo,
      icon: Icons.flight_takeoff_rounded,
    ),
    const MapMarker(
      id: 'market',
      title: 'Mercado Municipal',
      subtitle: 'Mercado Central de Saurimo',
      latitude: -9.6550,
      longitude: 20.3950,
      color: AppColors.cassengo,
      icon: Icons.store_rounded,
    ),
    const MapMarker(
      id: 'hotel',
      title: 'Hotel Chik',
      subtitle: 'Hotel 4 estrelas',
      latitude: -9.6700,
      longitude: 20.4000,
      color: AppColors.muangueji,
      icon: Icons.hotel_rounded,
    ),
    const MapMarker(
      id: 'hospital',
      title: 'Hospital Provincial',
      subtitle: 'Hospital Geral de Saurimo',
      latitude: -9.6450,
      longitude: 20.4100,
      color: AppColors.primaryRed,
      icon: Icons.local_hospital_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mapa
        SizedBox(
          height: 300,
          child: PremiumMap(
            markers: _popularLocations
                .map((loc) => MapMarker(
                      id: loc.id,
                      title: loc.title,
                      subtitle: loc.subtitle,
                      latitude: loc.latitude,
                      longitude: loc.longitude,
                      color: loc.color,
                      icon: loc.icon,
                      isSelected: _selectedLocation?.id == loc.id,
                    ))
                .toList(),
            onMarkerTap: (marker) {
              setState(() {
                _selectedLocation = marker;
              });
              widget.onLocationSelected(marker);
            },
            showControls: true,
            interactive: true,
          ),
        ),

        const SizedBox(height: 16),

        // Localizações populares
        _buildPopularLocations(),
      ],
    );
  }

  Widget _buildPopularLocations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOCALIZAÇÕES POPULARES',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.white.withOpacity(0.6),
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _popularLocations.map((location) {
            final isSelected = _selectedLocation?.id == location.id;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedLocation = location;
                });
                widget.onLocationSelected(location);
              },
              child: GlassCard(
                padding: const EdgeInsets.all(12),
                borderRadius: 15,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? location.color
                            : location.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? location.color
                              : location.color.withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        location.icon,
                        color: isSelected ? AppColors.white : location.color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                isSelected ? location.color : AppColors.white,
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            location.subtitle,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.white.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
