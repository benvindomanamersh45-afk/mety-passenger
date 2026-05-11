import 'package:flutter/material.dart';
import 'package:metty_pro/core/theme/app_colors.dart';
import 'package:metty_pro/core/theme/app_gradients.dart';
import 'package:metty_pro/features/passenger/widgets/gradient_button.dart';
import 'package:metty_pro/core/api/api_client.dart';
import 'package:metty_pro/core/models/trip_model.dart';

class RateTripScreen extends StatefulWidget {
  final Trip trip;

  const RateTripScreen({super.key, required this.trip});

  @override
  State<RateTripScreen> createState() => _RateTripScreenState();
}

class _RateTripScreenState extends State<RateTripScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitted = false;

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma avaliação de 1 a 5 estrelas'),
          backgroundColor: AppColors.metyOrange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiClient.rateTrip(widget.trip.id, _rating, _commentController.text);
      
      if (result != null) {
        setState(() {
          _isSubmitted = true;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avaliação enviada com sucesso!'),
            backgroundColor: AppColors.metyGreen,
          ),
        );
        
        // Voltar após 2 segundos
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context, true);
        });
      } else {
        throw Exception('Erro ao enviar');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar avaliação: $e'),
          backgroundColor: AppColors.metyOrange,
        ),
      );
    }
  }

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
          'AVALIAR VIAGEM',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: _isSubmitted
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 80,
                    color: AppColors.metyGreen,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Avaliação enviada!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sua avaliação ajuda outros passageiros.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 30),
                          Text(
                            'Como foi sua viagem?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Sua opinião é importante para melhorarmos',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.white.withOpacity(0.7),
                            ),
                          ),
                          SizedBox(height: 40),
                          
                          // Informações do motorista
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: AppColors.metyPurple,
                                  child: Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  widget.trip.driverName ?? 'Motorista',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Viagem #${widget.trip.id}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 40),
                          
                          // Estrelas
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _rating = index + 1;
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(
                                    index < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                                    size: 50,
                                    color: AppColors.metyOrange,
                                  ),
                                ),
                              );
                            }),
                          ),
                          
                          SizedBox(height: 10),
                          
                          Text(
                            _rating > 0
                                ? 'Você avaliou com $_rating estrela${_rating > 1 ? 's' : ''}'
                                : 'Toque nas estrelas para avaliar',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          
                          SizedBox(height: 40),
                          
                          // Comentário
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: AppColors.white.withOpacity(0.1)),
                            ),
                            child: TextField(
                              controller: _commentController,
                              maxLines: 5,
                              style: TextStyle(color: AppColors.white),
                              decoration: InputDecoration(
                                hintText: 'Deixe seu comentário (opcional)',
                                hintStyle: TextStyle(color: AppColors.white.withOpacity(0.5)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  GradientButton(
                    text: _isLoading ? 'ENVIANDO...' : 'ENVIAR AVALIAÇÃO',
                    onPressed: _isLoading ? null : _submitRating,
                    gradient: AppGradients.mety,
                    fullWidth: true,
                    type: null,
                  ),
                ],
              ),
            ),
    );
  }
}