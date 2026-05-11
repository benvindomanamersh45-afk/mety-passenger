class Trip {
  final int id;
  final String passengerName;
  final String? driverName;
  final String pickupAddress;
  final String destinationAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final String category;
  final String status;
  final double price;
  final double? distanceKm;
  final int? estimatedDuration;
  final int? passengerRating;
  final String? passengerComment;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  Trip({
    required this.id,
    required this.passengerName,
    this.driverName,
    required this.pickupAddress,
    required this.destinationAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
    required this.category,
    required this.status,
    required this.price,
    this.distanceKm,
    this.estimatedDuration,
    this.passengerRating,
    this.passengerComment,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    print('📦 Trip.fromJson: $json');
    
    return Trip(
      id: json['id'] ?? 0,
      passengerName: json['passenger_name'] ?? 'Desconhecido',
      driverName: json['driver_name'],
      pickupAddress: json['pickup_address'] ?? '',
      destinationAddress: json['destination_address'] ?? '',
      pickupLatitude: json['pickup_latitude']?.toDouble(),
      pickupLongitude: json['pickup_longitude']?.toDouble(),
      destinationLatitude: json['destination_latitude']?.toDouble(),
      destinationLongitude: json['destination_longitude']?.toDouble(),
      category: json['category'] ?? 'ECONOMIC',
      status: json['status'] ?? 'REQUESTED',
      price: (json['price'] ?? 0.0).toDouble(),
      distanceKm: json['distance_km']?.toDouble(),
      estimatedDuration: json['estimated_duration'],
      passengerRating: json['passenger_rating'],
      passengerComment: json['passenger_comment'],
      createdAt: DateTime.parse(json['requested_at'] ?? DateTime.now().toIso8601String()),
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passenger_name': passengerName,
      'driver_name': driverName,
      'pickup_address': pickupAddress,
      'destination_address': destinationAddress,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'destination_latitude': destinationLatitude,
      'destination_longitude': destinationLongitude,
      'category': category,
      'status': status,
      'price': price,
      'distance_km': distanceKm,
      'estimated_duration': estimatedDuration,
      'passenger_rating': passengerRating,
      'passenger_comment': passengerComment,
      'requested_at': createdAt.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
  
  String get statusDisplay {
    switch (status) {
      case 'REQUESTED': return 'Solicitada';
      case 'ACCEPTED': return 'Aceita';
      case 'ARRIVED': return 'Motorista chegou';
      case 'STARTED': return 'Em andamento';
      case 'COMPLETED': return 'Concluída';
      case 'CANCELLED': return 'Cancelada';
      default: return status;
    }
  }
  
  String get categoryDisplay {
    switch (category) {
      case 'ECONOMIC': return 'Econômico';
      case 'COMFORT': return 'Conforto';
      case 'PREMIUM': return 'Premium';
      default: return category;
    }
  }

  get rating => null;
}
