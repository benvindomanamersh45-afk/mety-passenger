import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadVehicles();
  }

  // ===== MÉTODO PRINCIPAL DE LOCALIZAÇÃO =====
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _locationError = '';
    });

    try {
      // 1. Verificar se o GPS está ligado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'GPS desativado';
          _isGettingLocation = false;
        });
        _showLocationDialog('Ative o GPS para continuar');
        return;
      }

      // 2. Verificar permissões
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Permissão negada';
            _isGettingLocation = false;
          });
          _showLocationDialog('Permissão de localização necessária');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Permissão negada permanentemente';
          _isGettingLocation = false;
        });
        _showLocationDialog('Habilite a permissão de localização nas configurações');
        return;
      }

      // 3. Tentar obter localização com múltiplas tentativas
      Position? position = await _getLocationWithRetry();
      
      if (position == null) {
        setState(() {
          _locationError = 'Não foi possível obter localização';
          _isGettingLocation = false;
        });
        _showErrorSnackbar('Não foi possível obter sua localização. Tente novamente.');
        return;
      }

      // 4. CONFIGURAR LOCALIZAÇÃO NO MAPA (SUCESSO!)
      final location = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _currentLocation = location;
        _isGettingLocation = false;
        
        // Adicionar marcador no mapa
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('origin'),
            position: location,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(
              title: 'Sua localização',
              snippet: 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}',
            ),
          ),
        );
      });

      // 5. Buscar endereço (com fallback para coordenadas se falhar)
      _getAddressSafely(position.latitude, position.longitude).then((address) {
        if (mounted && _originController.text.isEmpty) {
          _originController.text = address;
        }
      });

      // 6. Centralizar o mapa
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(location, 16),
        );
      }
      
    } catch (e) {
      print('❌ Erro na localização: $e');
      setState(() {
        _locationError = 'Erro: $e';
        _isGettingLocation = false;
      });
      _showErrorSnackbar('Erro ao obter localização: $e');
    }
  }

  // ===== MÉTODO COM MÚLTIPLAS TENTATIVAS =====
  Future<Position?> _getLocationWithRetry() async {
    // Tentativa 1: Alta precisão
    try {
      print('📍 Tentativa 1: Obtendo localização com alta precisão...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
      print('✅ Localização obtida: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('⚠️ Falha na tentativa 1: $e');
    }

    // Tentativa 2: Precisão média
    try {
      print('📍 Tentativa 2: Obtendo localização com precisão média...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );
      print('✅ Localização obtida: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('⚠️ Falha na tentativa 2: $e');
    }

    // Tentativa 3: Última posição conhecida (cached)
    try {
      print('📍 Tentativa 3: Usando última posição conhecida...');
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        print('✅ Última posição: ${position.latitude}, ${position.longitude}');
        return position;
      }
    } catch (e) {
      print('⚠️ Falha na tentativa 3: $e');
    }

    print('❌ Todas as tentativas falharam');
    return null;
  }

  // ===== BUSCAR ENDEREÇO COM FALLBACK SEGURO =====
  Future<String> _getAddressSafely(double latitude, double longitude) async {
    // Fallback padrão: mostrar coordenadas
    String fallback = '📍 ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
    
    try {
      print('📍 Buscando endereço para: $latitude, $longitude');
      
      // Tentar converter coordenadas em endereço
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        List<String> parts = [];
        
        // Coletar partes do endereço (ignorando nulos)
        if (place.street != null && place.street!.isNotEmpty) parts.add(place.street!);
        if (place.subLocality != null && place.subLocality!.isNotEmpty) parts.add(place.subLocality!);
        if (place.locality != null && place.locality!.isNotEmpty) parts.add(place.locality!);
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) parts.add(place.administrativeArea!);
        
        if (parts.isNotEmpty) {
          String address = parts.join(', ');
          print('✅ Endereço encontrado: $address');
          return address;
        }
      }
      
      print('⚠️ Nenhum endereço encontrado, usando coordenadas');
      return fallback;
      
    } catch (e) {
      print('❌ Erro ao buscar endereço: $e');
      // Se não tem internet ou geocoding falhou, retorna coordenadas
      return fallback;
    }
  }

  Future<void> _loadVehicles() async {
    setState(() => _loadingVehicles = true);
    try {
      final vehicles = await ApiClient.getAvailableVehicles();
      
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
      setState(() => _loadingVehicles = false);
      _loadMockVehicles();
    }
  }

  void _loadMockVehicles() {
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
        maxPassengers: 4,
      ),
      Vehicle(
        id: 2,
        plateNumber: 'LD-00-02-BB',
        brand: 'Toyota',
        model: 'Corolla',
        year: 2021,
        color: 'Preto',
        category: 'COMFORT',
        status: 'AVAILABLE',
        maxPassengers: 4,
      ),
      Vehicle(
        id: 3,
        plateNumber: 'LD-00-03-CC',
        brand: 'Mercedes',
        model: 'C180',
        year: 2022,
        color: 'Branco',
        category: 'PREMIUM',
        status: 'AVAILABLE',
        maxPassengers: 3,
      ),
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
      _showErrorSnackbar('Localização não disponível');
      return;
    }

    setState(() => _isSolicitando = true);

    try {
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
                const Text(
                  'Solicitando viagem...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
      );

      double latitude = double.parse(_currentLocation!.latitude.toStringAsFixed(6));
      double longitude = double.parse(_currentLocation!.longitude.toStringAsFixed(6));

      Map<String, dynamic> tripData = {
        'pickup_address': _originController.text,
        'destination_address': _destinationController.text,
        'category': _selectedVehicle!.category,
        'pickup_latitude': latitude,
        'pickup_longitude': longitude,
      };
      
      if (_referenceController.text.isNotEmpty) {
        tripData['pickup_reference'] = _referenceController.text;
      }

      print('📝 Enviando dados: $tripData');
      
      final trip = await ApiClient.requestTrip(tripData);
      
      if (mounted) {
        Navigator.pop(context);
      }
      
      if (trip != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Viagem solicitada com sucesso!'),
            backgroundColor: AppColors.metyGreen,
            duration: Duration(seconds: 2),
          ),
        );
        
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        });
      } else if (mounted) {
        _showErrorSnackbar('Erro ao solicitar viagem');
        setState(() => _isSolicitando = false);
      }
      
    } catch (e) {
      if (mounted) {
        try {
          Navigator.pop(context);
        } catch (_) {}
      }
      
      print('❌ Erro detalhado: $e');
      if (mounted) {
        _showErrorSnackbar('Erro ao solicitar viagem');
      }
      setState(() => _isSolicitando = false);
    }
  }

  void _showLocationDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Localização Necessária',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('VOLTAR', style: TextStyle(color: AppColors.metyBlue)),
          ),
          if (message.contains('GPS') || message.contains('configurações'))
            TextButton(
              onPressed: () async {
                await Geolocator.openLocationSettings();
                Navigator.pop(context);
              },
              child: const Text('ABRIR CONFIGURAÇÕES', style: TextStyle(color: AppColors.metyBlue)),
            ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.metyOrange,
        behavior: SnackBarBehavior.floating,
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
          // Mapa (mostra quando tem localização)
          if (_currentLocation != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation!,
                zoom: 15,
              ),
              markers: _markers,
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
            ),
          
          // Loading de localização
          if (_isGettingLocation)
            Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.metyBlue),
                    SizedBox(height: 20),
                    Text(
                      'Obtendo sua localização...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          
          // Erro de localização
          if (!_isGettingLocation && _currentLocation == null)
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off, size: 80, color: Colors.white.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    const Text(
                      'Não foi possível obter sua localização',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _locationError.isNotEmpty ? _locationError : 'Verifique o GPS e tente novamente',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _refreshLocation,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('TENTAR NOVAMENTE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.metyBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Botão centralizar mapa
          if (_currentLocation != null)
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  if (_mapController != null && _currentLocation != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.newLatLngZoom(_currentLocation!, 16),
                    );
                  }
                },
                backgroundColor: AppColors.metyBlue,
                mini: true,
                child: const Icon(Icons.my_location),
              ),
            ),
          
          // Formulário inferior (sempre visível)
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
                  topRight: Radius.circular(25),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ORIGEM
                    GlassCard(
                      padding: const EdgeInsets.all(12),
                      borderRadius: 15,
                      child: Row(
                        children: [
                          const Icon(Icons.circle, color: AppColors.metyBlue, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('ORIGEM', style: TextStyle(fontSize: 10, color: AppColors.metyBlue)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _originController.text.isEmpty 
                                            ? (_isGettingLocation ? 'Obtendo localização...' : 'Aguardando localização...')
                                            : _originController.text,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    if (_currentLocation != null)
                                      const Icon(Icons.gps_fixed, color: AppColors.metyGreen, size: 16),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // PONTO DE REFERÊNCIA
                    GlassCard(
                      padding: const EdgeInsets.all(12),
                      borderRadius: 15,
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: AppColors.metyOrange, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('PONTO DE REFERÊNCIA (OPCIONAL)', 
                                  style: TextStyle(fontSize: 10, color: AppColors.metyOrange)),
                                TextField(
                                  controller: _referenceController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText: 'Ex: Próximo ao mercado, igreja, escola...',
                                    hintStyle: TextStyle(color: Colors.white38),
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
                    
                    // DESTINO
                    GlassCard(
                      padding: const EdgeInsets.all(12),
                      borderRadius: 15,
                      child: Row(
                        children: [
                          const Icon(Icons.flag, color: AppColors.metyGreen, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('DESTINO', style: TextStyle(fontSize: 10, color: AppColors.metyGreen)),
                                TextField(
                                  controller: _destinationController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText: 'Digite o endereço de destino',
                                    hintStyle: TextStyle(color: Colors.white38),
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
                    
                    // VEÍCULOS
                    const Text('VEÍCULOS DISPONÍVEIS', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 10),
                    
                    _loadingVehicles
                        ? const Center(child: CircularProgressIndicator(color: AppColors.metyBlue))
                        : vehiclesToShow.isEmpty
                            ? const Center(
                                child: Text(
                                  'Nenhum veículo disponível',
                                  style: TextStyle(color: Colors.white38),
                                ),
                              )
                            : SizedBox(
                                height: 100,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: vehiclesToShow.length,
                                  separatorBuilder: (context, index) => const SizedBox(width: 10),
                                  itemBuilder: (context, index) {
                                    final vehicle = vehiclesToShow[index];
                                    bool isSelected = _selectedVehicle == vehicle;
                                    Color vehicleColor = vehicle.category == 'ECONOMIC'
                                        ? AppColors.metyBlue
                                        : vehicle.category == 'COMFORT'
                                            ? AppColors.metyGreen
                                            : AppColors.metyOrange;
                                    
                                    return GestureDetector(
                                      onTap: () => setState(() => _selectedVehicle = vehicle),
                                      child: Container(
                                        width: 110,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isSelected ? vehicleColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: isSelected ? vehicleColor : Colors.white24),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.directions_car_rounded, color: vehicleColor, size: 28),
                                            const SizedBox(height: 4),
                                            Text(
                                              vehicle.category == 'ECONOMIC' ? 'ECONÓMICO' :
                                              vehicle.category == 'COMFORT' ? 'CONFORTO' : 'PREMIUM',
                                              style: TextStyle(color: vehicleColor, fontWeight: FontWeight.bold, fontSize: 10),
                                            ),
                                            Text('${vehicle.maxPassengers} lugares', style: const TextStyle(fontSize: 8, color: Colors.white54)),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: vehicleColor.withOpacity(0.2), 
                                                borderRadius: BorderRadius.circular(6)
                                              ),
                                              child: Text(
                                                '${_fixedPrices[vehicle.category]} Kz',
                                                style: TextStyle(color: vehicleColor, fontWeight: FontWeight.bold, fontSize: 10),
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
                    
                    // PREÇO
                    if (_selectedVehicle != null)
                      GlassCard(
                        padding: const EdgeInsets.all(12),
                        borderRadius: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('PREÇO FIXO', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text(
                              '${_fixedPrices[_selectedVehicle!.category]} Kz',
                              style: const TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold, 
                                color: AppColors.metyGreen
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 15),
                    
                    // BOTÃO SOLICITAR
                    GradientButton(
                      text: _isSolicitando ? 'SOLICITANDO...' : 'SOLICITAR VIAGEM',
                      onPressed: (_isSolicitando || _loadingVehicles || _currentLocation == null) ? null : _requestRide,
                      gradient: AppGradients.mety,
                      fullWidth: true,
                      type: null,
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // MENSAGEM DE STATUS DA LOCALIZAÇÃO
                    if (_isGettingLocation)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.metyBlue),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Obtendo localização...',
                              style: TextStyle(fontSize: 11, color: AppColors.white.withOpacity(0.6)),
                            ),
                          ],
                        ),
                      ),
                    if (!_isGettingLocation && _currentLocation == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.metyOrange),
                            const SizedBox(width: 8),
                            Text(
                              'Localização não disponível. Ative o GPS.',
                              style: TextStyle(fontSize: 11, color: AppColors.metyOrange.withOpacity(0.8)),
                            ),
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

  @override
  void dispose() {
    _originController.dispose();
    _referenceController.dispose();
    _destinationController.dispose();
    super.dispose();
  }
}