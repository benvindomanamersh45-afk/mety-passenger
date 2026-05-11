import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trip_model.dart';
import '../models/user_model.dart';
import '../models/vehicle_model.dart';

class ApiClient {
  // ALTERADO: apontando para o backend hospedado no PythonAnywhere
  static const String baseUrl = 'https://benvindomana.pythonanywhere.com/api';
  static String? _cachedToken;
  
  static Future<Map<String, String>> _getHeaders() async {
    if (_cachedToken == null) {
      final prefs = await SharedPreferences.getInstance();
      _cachedToken = prefs.getString('access_token');
      print('🔑 Token recuperado: $_cachedToken');
    }
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_cachedToken != null) 'Authorization': 'Bearer $_cachedToken',
    };
  }
  
  static void _clearToken() {
    _cachedToken = null;
  }
  
  // ===== GET =====
  static Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      print('📡 GET $baseUrl$endpoint');
      
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));
      
      print('📡 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        print('⚠️ Token expirado, tentando renovar...');
        final refreshed = await refreshToken();
        if (refreshed) {
          return await get(endpoint);
        } else {
          await logout();
          return null;
        }
      } else {
        print('❌ Erro GET: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Erro GET: $e');
      return null;
    }
  }
  
  // ===== POST =====
  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl$endpoint';
      
      print('📡 POST $url');
      print('📦 Dados: $data');
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: 15));
      
      print('📡 Status: ${response.statusCode}');
      print('📡 Resposta: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 400) {
        print('❌ Erro 400: ${response.body}');
        // Retornar o erro para tratamento
        final errorData = json.decode(response.body);
        throw Exception(errorData.toString());
      } else if (response.statusCode == 401) {
        print('⚠️ Token expirado, tentando renovar...');
        final refreshed = await refreshToken();
        if (refreshed) {
          return await post(endpoint, data);
        }
        return null;
      } else {
        print('❌ Erro ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Erro POST: $e');
      rethrow; // Importante: propagar o erro para tratamento na UI
    }
  }
  
  // ===== PUT =====
  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl$endpoint';
      
      print('📡 PUT $url');
      print('📦 Dados: $data');
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: 15));
      
      print('📡 Status: ${response.statusCode}');
      print('📡 Resposta: ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (refreshed) {
          return await put(endpoint, data);
        }
        return null;
      } else {
        return null;
      }
    } catch (e) {
      print('❌ Erro PUT: $e');
      return null;
    }
  }
  
  // ===== REFRESH TOKEN =====
  static Future<bool> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      
      if (refreshToken == null) {
        print('❌ Refresh token não encontrado');
        return false;
      }
      
      print('🔄 Renovando token...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': refreshToken}),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await prefs.setString('access_token', data['access']);
        _cachedToken = data['access'];
        print('✅ Token renovado com sucesso');
        return true;
      } else {
        print('❌ Falha ao renovar token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Erro refresh: $e');
      return false;
    }
  }
  
  // ===== AUTENTICAÇÃO =====
  static Future<Map<String, dynamic>?> login(String phone, String password) async {
    try {
      print('📡 Login - $phone');
      final response = await http.post(
        Uri.parse('$baseUrl/users/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': phone,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));
      
      print('📡 Status: ${response.statusCode}');
      print('📡 Resposta: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['access']);
        await prefs.setString('refresh_token', data['refresh']);
        _cachedToken = data['access'];
        print('✅ Login realizado com sucesso');
        print('✅ Token: ${data['access'].substring(0, 20)}...');
        return data;
      }
      print('❌ Login falhou: ${response.statusCode}');
      return null;
    } catch (e) {
      print('❌ Erro login: $e');
      return null;
    }
  }
  
  // ===== REGISTRO =====
  static Future<Map<String, dynamic>?> register(Map<String, dynamic> userData) async {
    try {
      print('📡 Registrando usuário: ${userData['phone']}');
      print('📦 Dados: $userData');
      
      final response = await http.post(
        Uri.parse('$baseUrl/users/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      ).timeout(const Duration(seconds: 15));
      
      print('📡 Status: ${response.statusCode}');
      print('📡 Resposta: ${response.body}');
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Registro realizado com sucesso!');
        return data;
      } else {
        print('❌ Erro no registro: ${response.statusCode}');
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map) {
            String errorMsg = '';
            // Concatenar todos os erros
            errorData.forEach((key, value) {
              if (value is List) {
                errorMsg += '${value.join(', ')}\n';
              } else {
                errorMsg += '$value\n';
              }
            });
            throw Exception(errorMsg.trim());
          }
        } catch (e) {
          if (e is Exception) rethrow;
        }
        throw Exception('Erro no registro: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exceção no registro: $e');
      rethrow;
    }
  }
  
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    _cachedToken = null;
    print('✅ Logout realizado');
  }
  
  static Future<bool> isLoggedIn() async {
    if (_cachedToken != null) return true;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString('access_token');
    print('🔍 Verificando login: ${_cachedToken != null}');
    return _cachedToken != null;
  }
  
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      return await get('/users/me/');
    } catch (e) {
      print('❌ Erro ao buscar usuário: $e');
      return null;
    }
  }
  
  // ===== UPDATE PROFILE =====
  static Future<Map<String, dynamic>?> updateProfile(Map<String, dynamic> data) async {
    try {
      print('📡 Atualizando perfil...');
      final response = await put('/update-profile/', data);
      
      if (response != null) {
        print('✅ Perfil atualizado');
        return response;
      }
      return null;
    } catch (e) {
      print('❌ Erro update: $e');
      return null;
    }
  }
  
  // ===== HISTÓRICO =====
  static Future<List<Trip>> getTripHistory() async {
    try {
      final response = await get('/trips/history/');
      if (response is List) {
        return response.map((t) => Trip.fromJson(t)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erro histórico: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getTripHistoryRaw() async {
    try {
      final response = await get('/trips/history/');
      if (response is List) return response;
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getPassengerHistory() async {
    try {
      return await getTripHistoryRaw();
    } catch (e) {
      final trips = await getTripHistory();
      return trips.map((t) => t.toJson()).toList();
    }
  }
  
  // ===== VIAGENS =====
  static Future<List<Trip>> getPendingTrips() async {
    try {
      final response = await get('/trips/pending/');
      if (response is List) {
        return response.map((t) => Trip.fromJson(t)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ===== SOLICITAR VIAGEM (COM MELHOR TRATAMENTO DE ERRO) =====
  static Future<Map<String, dynamic>?> requestTrip(Map<String, dynamic> tripData) async {
    try {
      print('📡 Solicitando viagem...');
      print('📦 Dados: $tripData');
      
      final response = await post('/trips/', tripData);
      
      if (response != null) {
        print('✅ Sucesso: $response');
        return response;
      }
      print('❌ Resposta nula');
      return null;
    } catch (e) {
      print('❌ Erro ao solicitar viagem: $e');
      rethrow;
    }
  }

  static Future<List<Vehicle>> getAvailableVehicles() async {
    try {
      print('🚗 Buscando veículos disponíveis...');
      final response = await get('/vehicles/available/');
      if (response is List) {
        print('✅ Veículos encontrados: ${response.length}');
        return response.map((v) => Vehicle.fromJson(v)).toList();
      }
      print('⚠️ Nenhum veículo encontrado');
      return [];
    } catch (e) {
      print('❌ Erro ao buscar veículos: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> acceptTrip(int tripId) async {
    try {
      return await post('/trips/$tripId/accept/', {});
    } catch (e) {
      return null;
    }
  }

  static Future<List<dynamic>> getMinhasViagens() async {
    try {
      final response = await get('/trips/');
      if (response is List) return response;
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // ===== AVALIAR VIAGEM =====
  static Future<Map<String, dynamic>?> rateTrip(int tripId, int rating, String comment) async {
    try {
      print('⭐ Avaliando viagem #$tripId com $rating estrelas');
      print('💬 Comentário: $comment');
      
      final response = await post('/trips/$tripId/rate/', {
        'rating': rating,
        'comment': comment,
      });
      
      if (response != null) {
        print('✅ Avaliação enviada com sucesso');
        return response;
      }
      return null;
    } catch (e) {
      print('❌ Erro ao avaliar: $e');
      return null;
    }
  }
}