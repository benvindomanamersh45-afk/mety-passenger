class User {
  final int id;
  final String phone;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String userType;
  final String municipality;
  final double rating;
  final int totalTrips;
  final bool isVerified;
  final bool isActive;
  final String? birthDate;

  User({
    required this.id,
    required this.phone,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.userType,
    required this.municipality,
    required this.rating,
    required this.totalTrips,
    required this.isVerified,
    required this.isActive,
    this.birthDate,
  });

  User copyWith({
    int? id,
    String? phone,
    String? email,
    String? firstName,
    String? lastName,
    String? fullName,
    String? userType,
    String? municipality,
    double? rating,
    int? totalTrips,
    bool? isVerified,
    bool? isActive,
    String? birthDate,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      userType: userType ?? this.userType,
      municipality: municipality ?? this.municipality,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      birthDate: birthDate ?? this.birthDate,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    print('📦 User.fromJson: JSON recebido: $json');
    
    // VALIDAÇÃO: Verificar se JSON é nulo
    if (json == null) {
      throw Exception('JSON é nulo');
    }

    // FUNÇÃO AUXILIAR PARA CONVERTER RATING PARA DOUBLE
    double parseRating(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        // Tentar converter string para double
        try {
          return double.parse(value);
        } catch (e) {
          print('⚠️ Erro ao converter rating "$value" para double: $e');
          return 0.0;
        }
      }
      return 0.0;
    }

    // FUNÇÃO AUXILIAR PARA CONVERTER TOTAL_TRIPS PARA INT
    int parseTotalTrips(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          print('⚠️ Erro ao converter total_trips "$value" para int: $e');
          return 0;
        }
      }
      return 0;
    }

    // EXTRAIR VALORES COM CONVERSÃO SEGURA
    final id = json['id'];
    final phone = json['phone'] ?? '';
    final email = json['email'] ?? '';
    final firstName = json['first_name'] ?? '';
    final lastName = json['last_name'] ?? '';
    final fullName = json['full_name'] ?? 
        '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim();
    final userType = json['user_type'] ?? 'PASSENGER';
    final municipality = json['municipality'] ?? 'Saurimo';
    
    // CONVERSÕES ESPECIAIS
    final rating = parseRating(json['rating']);
    final totalTrips = parseTotalTrips(json['total_trips']);
    final isVerified = json['is_verified'] ?? false;
    final isActive = json['is_active'] ?? true;
    final birthDate = json['birth_date'];

    print('✅ Valores convertidos:');
    print('   - id: $id');
    print('   - phone: $phone');
    print('   - email: $email');
    print('   - firstName: $firstName');
    print('   - lastName: $lastName');
    print('   - fullName: $fullName');
    print('   - userType: $userType');
    print('   - municipality: $municipality');
    print('   - rating: $rating (${rating.runtimeType})');
    print('   - totalTrips: $totalTrips (${totalTrips.runtimeType})');
    print('   - isVerified: $isVerified');
    print('   - isActive: $isActive');

    final user = User(
      id: id ?? 0,
      phone: phone,
      email: email,
      firstName: firstName,
      lastName: lastName,
      fullName: fullName,
      userType: userType,
      municipality: municipality,
      rating: rating,
      totalTrips: totalTrips,
      isVerified: isVerified,
      isActive: isActive,
      birthDate: birthDate,
    );

    print('✅ User.fromJson: Usuário criado com sucesso: ${user.fullName}');
    return user;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'user_type': userType,
      'municipality': municipality,
      'rating': rating,
      'total_trips': totalTrips,
      'is_verified': isVerified,
      'is_active': isActive,
      'birth_date': birthDate,
    };
  }
}
