class Vehicle {
  final int id;
  final String plateNumber;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String category;
  final String status;
  final int maxPassengers;
  final String? driverName;
  final double? currentLatitude;
  final double? currentLongitude;

  Vehicle({
    required this.id,
    required this.plateNumber,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.category,
    required this.status,
    required this.maxPassengers,
    this.driverName,
    this.currentLatitude,
    this.currentLongitude,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? 0,
      plateNumber: json['plate_number'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      color: json['color'] ?? '',
      category: json['category'] ?? 'ECONOMIC',
      status: json['status'] ?? 'AVAILABLE',
      maxPassengers: json['max_passengers'] ?? 4,
      driverName: json['driver_name'],
      currentLatitude: json['current_latitude']?.toDouble(),
      currentLongitude: json['current_longitude']?.toDouble(),
    );
  }

  String get categoryDisplay {
    switch (category) {
      case 'ECONOMIC':
        return 'Econômico';
      case 'COMFORT':
        return 'Conforto';
      case 'PREMIUM':
        return 'Premium';
      default:
        return category;
    }
  }

  String get statusDisplay {
    switch (status) {
      case 'AVAILABLE':
        return 'Disponível';
      case 'BUSY':
        return 'Ocupado';
      case 'MAINTENANCE':
        return 'Manutenção';
      case 'INACTIVE':
        return 'Inativo';
      default:
        return status;
    }
  }
  
  String get fullName => '$brand $model';
}
