import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:metty_pro/core/theme/app_colors.dart';
import 'package:metty_pro/core/theme/app_gradients.dart';
import 'package:metty_pro/features/auth/passenger/presentation/widgets/glass_card.dart';
import 'package:metty_pro/features/passenger/widgets/gradient_button.dart';
import 'package:metty_pro/core/api/api_client.dart';
import 'package:metty_pro/core/models/vehicle_model.dart';
import 'package:geocoding/geocoding.dart';

class RideRequestMapScreen extends StatefulWidget {
  const RideRequestMapScreen({super.key});

  @override
  State<RideRequestMapScreen> createState() => _RideRequestMapScreenState();
}

class _RideRequestMapScreenState extends State<RideRequestMapScreen> {
  // Controladores
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  // Mapa
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  Set<Marker> _markers = {};

  // Veículos
  List<Vehicle> _vehicles = [];
  List<Vehicle> _uniqueVehicles = [];
  Vehicle? _selectedVehicle;
  bool _loadingVehicles = true;
  bool _isSolicitando = false;

  // Estados de localização
  bool _isGettingLocation = true;
  String _locationError = '';

  // Preços fixos
  final Map<String, double> _fixedPrices = {
    'ECONOMIC': 2600,
    'COMFORT': 3800,
    'PREMIUM': 6800,
  };

  // ===== NOTIFICAÇÕES =====
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Timer? _statusPollingTimer;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    Future.delayed(const Duration(milliseconds: 500), () {
      _getCurrentLocation();
      _loadVehicles();
    });
  }

  @override
  void dispose() {
    _statusPollingTimer?.cancel();
    _originController.dispose();
    _referenceController.dispose();
    _destinationController.dispose();
    if (_mapController != null) {
      _mapController!.dispose();
    }
    super.dispose();
  }

  // ===== INICIALIZAR NOTIFICAÇÕES =====
  Future<void> _initNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(settings);
  }

  // ===== MOSTRAR NOTIFICAÇÃO =====
  Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'mety_passenger_channel',
      'METY Viagens',
      channelDescription: 'Status da sua viagem',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const details = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(0, title, body, details);
  }

  // ===== POLLING PARA VERIFICAR STATUS DA VIAGEM =====
  void _startStatusPolling(int tripId) {
    _statusPollingTimer?.cancel();
    _statusPollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final trip = await ApiClient.get('/trips/$tripId/');
        if (trip != null && mounted) {
          if (trip['status'] == 'ACCEPTED') {
            _statusPollingTimer?.cancel();
            _showNotification(
              '🚗 Motorista a caminho!',
              'Sua viagem foi aceita. O motorista está indo até você.',
            );
          }
        }
      } catch (e) {
        // Ignora erros no polling
      }
    });
  }

  // ===== MÉTODO PRINCIPAL DE LOCALIZAÇÃO =====
  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      _isGettingLocation = true;
      _locationError = '';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _locationError = 'GPS desativado';
          _isGettingLocation = false;
        });
        _showLocationDialog('Ative o GPS para continuar');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          setState(() {
            _locationError = 'Permissão negada';
            _isGettingLocation = false;
          });
          _showLocationDialog('Permissão de localização necessária');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _locationError = 'Permissão negada permanentemente';
          _isGettingLocation = false;
        });
        _showLocationDialog(
            'Habilite a permissão de localização nas configurações');
        return;
      }

      Position? position = await _getLocationWithRetry();

      if (!mounted) return;

      if (position == null) {
        setState(() {
          _locationError = 'Não foi possível obter localização';
          _isGettingLocation = false;
        });
        _showErrorSnackbar(
            'Não foi possível obter sua localização. Tente novamente.');
        return;
      }

      final location = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = location;
        _isGettingLocation = false;

        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('origin'),
            position: location,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(
              title: 'Sua localização',
              snippet:
                  'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}',
            ),
          ),
        );
      });

      final address =
          await _getAddressSafely(position.latitude, position.longitude);
      if (mounted) {
        _originController.text = address;
      }

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(location, 16),
        );
      }
    } catch (e) {
      print('❌ Erro na localização: $e');
      if (!mounted) return;
      setState(() {
        _locationError = 'Erro: $e';
        _isGettingLocation = false;
      });
      _showErrorSnackbar('Erro ao obter localização: $e');
    }
  }

  Future<Position?> _getLocationWithRetry() async {
    try {
      print('📍 Tentativa 1: Obtendo localização com alta precisão...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
      print(
          '✅ Localização obtida: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('⚠️ Falha na tentativa 1: $e');
    }

    try {
      print('📍 Tentativa 2: Obtendo localização com precisão média...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );
      print(
          '✅ Localização obtida: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('⚠️ Falha na tentativa 2: $e');
    }

    try {
      print('📍 Tentativa 3: Usando última posição conhecida...');
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        print(
            '✅ Última posição: ${position.latitude}, ${position.longitude}');
        return position;
      }
    } catch (e) {
      print('⚠️ Falha na tentativa 3: $e');
    }

    print('❌ Todas as tentativas falharam');
    return null;
  }

  Future<String> _getAddressSafely(double latitude, double longitude) async {
    try {
      print('📍 Buscando endereço para: $latitude, $longitude');

      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        List<String> parts = [];

        if (place.street != null && place.street!.isNotEmpty)
          parts.add(place.street!);
        if (place.subLocality != null && place.subLocality!.isNotEmpty)
          parts.add(place.subLocality!);
        if (place.locality != null && place.locality!.isNotEmpty)
          parts.add(place.locality!);
        if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.isNotEmpty)
          parts.add(place.subAdministrativeArea!);
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty)
          parts.add(place.administrativeArea!);

        if (parts.isNotEmpty) {
          String address = parts.join(', ');
          print('✅ Endereço encontrado: $address');
          return address;
        }

        if (place.locality != null && place.locality!.isNotEmpty) {
          String locality = place.locality!;
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            locality = '${place.subLocality!}, $locality';
          }
          print('✅ Localidade encontrada: $locality');
          return locality;
        }
      }

      print('⚠️ Nenhum endereço encontrado, usando coordenadas');
      return '📍 ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    } catch (e) {
      print('❌ Erro ao buscar endereço: $e');
      return '📍 ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    }
  }

  Future<void> _loadVehicles() async {
    if (!mounted) return;
    setState(() => _loadingVehicles = true);
    try {
      final vehicles = await ApiClient.getAvailableVehicles();

      if (!mounted) return;

      if (vehicles.isEmpty) {
        _loadMockVehicles();
        return;
      }

      final Map<String, Vehicle> uniqueMap = {};
      for (var v in vehicles) {
        if (!uniqueMap.containsKey(v.category)) {
          uniqueMap[v.category] = v;
        }
      }

      setState(() {
        _vehicles = vehicles;
        _uniqueVehicles = uniqueMap.values.toList();
        _loadingVehicles = false;
      });

      print('✅ Veículos carregados: ${vehicles.length}');
    } catch (e) {
      print('Erro ao carregar veículos: $e');
      if (!mounted) return;
      setState(() => _loadingVehicles = false);
      _loadMockVehicles();
    }
  }

  void _loadMockVehicles() {
    if (!mounted) return;
    final mockVehicles = [
      Vehicle(
          id: 1,
          plateNumber: 'LD-00-01-AA',
          brand: 'Toyota',
          model: 'Yaris',
          year: 2020,
          color: 'Prata',
          category: 'ECONOMIC',
          status: 'AVAILABLE',
          maxPassengers: 4),
      Vehicle(
          id: 2,
          plateNumber: 'LD-00-02-BB',
          brand: 'Toyota',
          model: 'Corolla',
          year: 2021,
          color: 'Preto',
          category: 'COMFORT',
          status: 'AVAILABLE',
          maxPassengers: 4),
      Vehicle(
          id: 3,
          plateNumber: 'LD-00-03-CC',
          brand: 'Mercedes',
          model: 'C180',
          year: 2022,
          color: 'Branco',
          category: 'PREMIUM',
          status: 'AVAILABLE',
          maxPassengers: 3),
    ];
    setState(() {
      _uniqueVehicles = mockVehicles;
      _loadingVehicles = false;
    });
  }

  Future<void> _requestRide() async {
    if (_selectedVehicle == null) {
      _showErrorSnackbar('Selecione um veículo');
      return;
    }

    if (_destinationController.text.isEmpty) {
      _showErrorSnackbar('Digite o destino');
      return;
    }

    if (_currentLocation == null) {
      _showErrorSnackbar(
          'Localização não disponível. Ative o GPS e tente novamente.');
      return;
    }

    setState(() => _isSolicitando = true);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.metyPurple),
              const SizedBox(height: 20),
              const Text('Solicitando viagem...',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        );
      },
    );

    try {
      double latitude =
          double.parse(_currentLocation!.latitude.toStringAsFixed(6));
      double longitude =
          double.parse(_currentLocation!.longitude.toStringAsFixed(6));

      Map<String, dynamic> tripData = {
        'pickup_address': _originController.text.isNotEmpty
            ? _originController.text
            : 'Localização atual',
        'destination_address': _destinationController.text.trim(),
        'category': _selectedVehicle!.category,
        'pickup_latitude': latitude,
        'pickup_longitude': longitude,
      };

      if (_referenceController.text.isNotEmpty) {
        tripData['pickup_reference'] = _referenceController.text.trim();
      }

      print('📝 Enviando dados da viagem: $tripData');

      final trip = await ApiClient.requestTrip(tripData);

      if (!mounted) return;

      Navigator.pop(context);

      if (trip != null) {
        // ===== INICIAR POLLING PARA VERIFICAR STATUS =====
        _startStatusPolling(trip['id']);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Viagem solicitada com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        });
      } else {
        _showErrorSnackbar(
            'Erro ao solicitar viagem. Verifique sua conexão e tente novamente.');
        setState(() => _isSolicitando = false);
      }
    } catch (e) {
      print('❌ Erro detalhado ao solicitar viagem: $e');

      if (!mounted) return;

      try {
        Navigator.pop(context);
      } catch (_) {}

      String errorMsg = 'Erro ao solicitar viagem';
      if (e.toString().contains('SocketException') ||
          e.toString().contains('timeout')) {
        errorMsg = 'Sem conexão com o servidor. Verifique sua internet.';
      } else if (e.toString().contains('400')) {
        errorMsg = 'Dados inválidos. Verifique as informações.';
      }

      _showErrorSnackbar(errorMsg);
      setState(() => _isSolicitando = false);
    }
  }

  void _showLocationDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Localização Necessária',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('VOLTAR', style: TextStyle(color: AppColors.metyBlue)),
          ),
          if (message.contains('GPS') || message.contains('configurações'))
            TextButton(
              onPressed: () async {
                await Geolocator.openLocationSettings();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('ABRIR CONFIGURAÇÕES',
                  style: TextStyle(color: AppColors.metyBlue)),
            ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _refreshLocation() async {
    await _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesToShow = _uniqueVehicles;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text('SOLICITAR VIAGEM'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _refreshLocation,
            tooltip: 'Atualizar localização',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_currentLocation != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: _currentLocation!, zoom: 15),
              markers: _markers,
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
            ),
          if (_isGettingLocation)
            Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.metyBlue),
                    SizedBox(height: 20),
                    Text('Obtendo sua localização...',
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          if (!_isGettingLocation && _currentLocation == null)
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off,
                        size: 80, color: Colors.white.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    const Text('Não foi possível obter sua localização',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                        _locationError.isNotEmpty
                            ? _locationError
                            : 'Verifique o GPS e tente novamente',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _refreshLocation,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('TENTAR NOVAMENTE'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.metyBlue),
                    ),
                  ],
                ),
              ),
            ),
          if (_currentLocation != null)
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  if (_mapController != null && _currentLocation != null) {
                    _mapController!.animateCamera(
                        CameraUpdate.newLatLngZoom(_currentLocation!, 16));
                  }
                },
                backgroundColor: AppColors.metyBlue,
                mini: true,
                child: const Icon(Icons.my_location),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: isSmallScreen ? 380 : 420,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(12),
                      borderRadius: 15,
                      child: Row(
                        children: [
                          const Icon(Icons.circle,
                              color: AppColors.metyBlue, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('ORIGEM',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.metyBlue)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _originController.text.isEmpty
                                            ? (_isGettingLocation
                                                ? 'Obtendo localização...'
                                                : 'Aguardando localização...')
                                            : _originController.text,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                    if (_currentLocation != null)
                                      const Icon(Icons.gps_fixed,
                                          color: AppColors.metyGreen,
                                          size: 16),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    GlassCard(
                      padding: const EdgeInsets.all(12),
                      borderRadius: 15,
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              color: AppColors.metyOrange, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('PONTO DE REFERÊNCIA (OPCIONAL)',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.metyOrange)),
                                TextField(
                                  controller: _referenceController,
                                  style:
                                      const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Ex: Próximo ao mercado, igreja, escola...',
                                    hintStyle: TextStyle(
                                        color: Colors.white38),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    GlassCard(
                      padding: const EdgeInsets.all(12),
                      borderRadius: 15,
                      child: Row(
                        children: [
                          const Icon(Icons.flag,
                              color: AppColors.metyGreen, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('DESTINO',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.metyGreen)),
                                TextField(
                                  controller: _destinationController,
                                  style:
                                      const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Digite o endereço de destino',
                                    hintStyle: TextStyle(
                                        color: Colors.white38),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('VEÍCULOS DISPONÍVEIS',
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 10),
                    if (_loadingVehicles)
                      const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.metyBlue))
                    else if (vehiclesToShow.isEmpty)
                      const Center(
                          child: Text('Nenhum veículo disponível',
                              style: TextStyle(color: Colors.white38)))
                    else
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: vehiclesToShow.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final vehicle = vehiclesToShow[index];
                            bool isSelected =
                                _selectedVehicle == vehicle;
                            Color vehicleColor = vehicle.category ==
                                    'ECONOMIC'
                                ? AppColors.metyBlue
                                : vehicle.category == 'COMFORT'
                                    ? AppColors.metyGreen
                                    : AppColors.metyOrange;
                            return GestureDetector(
                              onTap: () => setState(
                                  () => _selectedVehicle = vehicle),
                              child: Container(
                                width: 110,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? vehicleColor.withOpacity(0.2)
                                      : Colors.white.withOpacity(0.05),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                      color: isSelected
                                          ? vehicleColor
                                          : Colors.white24),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                        Icons.directions_car_rounded,
                                        color: vehicleColor,
                                        size: 28),
                                    const SizedBox(height: 4),
                                    Text(
                                      vehicle.category == 'ECONOMIC'
                                          ? 'ECONÓMICO'
                                          : vehicle.category ==
                                                  'COMFORT'
                                              ? 'CONFORTO'
                                              : 'PREMIUM',
                                      style: TextStyle(
                                          color: vehicleColor,
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: 10),
                                    ),
                                    Text(
                                        '${vehicle.maxPassengers} lugares',
                                        style: const TextStyle(
                                            fontSize: 8,
                                            color: Colors.white54)),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2),
                                      decoration: BoxDecoration(
                                        color: vehicleColor
                                            .withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${_fixedPrices[vehicle.category]} Kz',
                                        style: TextStyle(
                                            color: vehicleColor,
                                            fontWeight:
                                                FontWeight.bold,
                                            fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 15),
                    if (_selectedVehicle != null)
                      GlassCard(
                        padding: const EdgeInsets.all(12),
                        borderRadius: 12,
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('PREÇO FIXO',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12)),
                            Text(
                              '${_fixedPrices[_selectedVehicle!.category]} Kz',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.metyGreen),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 15),
                    GradientButton(
                      text: _isSolicitando
                          ? 'SOLICITANDO...'
                          : 'SOLICITAR VIAGEM',
                      onPressed: (_isSolicitando ||
                              _loadingVehicles ||
                              _currentLocation == null)
                          ? null
                          : _requestRide,
                      gradient: AppGradients.mety,
                      fullWidth: true,
                      type: null,
                    ),
                    const SizedBox(height: 10),
                    if (_isGettingLocation)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.metyBlue)),
                            const SizedBox(width: 8),
                            Text('Obtendo localização...',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.white
                                        .withOpacity(0.6))),
                          ],
                        ),
                      ),
                    if (!_isGettingLocation &&
                        _currentLocation == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                size: 14,
                                color: AppColors.metyOrange),
                            const SizedBox(width: 8),
                            Text(
                                'Localização não disponível. Ative o GPS.',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.metyOrange
                                        .withOpacity(0.8))),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}