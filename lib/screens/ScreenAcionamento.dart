import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Telaacionamento extends StatefulWidget {
  const Telaacionamento({super.key});

  @override
  State<Telaacionamento> createState() => _TelaacionamentoState();
}

class _TelaacionamentoState extends State<Telaacionamento> {
  @override
  void initState(){
    super.initState();
    _leitura();
  }
  final bool status = false;
  Color status_cor = Colors.red;
   int? temperatura;
  int? umidade;
  int? bomba;
  int? sensorUmidSolo;
 int? pH;
  
  Future<void> _leitura()async{
    final response = await http.get(Uri.parse('https://apiintegradoresp-production.up.railway.app/dados'));
    print(response.body);
    final dados = json.decode(response.body);
    setState(() {
      temperatura=(dados["temperatura"]);
      umidade = (dados["umidade"]);
      sensorUmidSolo = (dados["sensor_umidsolo"]);
      pH = (dados["pH"]);
      bomba= dados["bomba"];
      print(temperatura);
      print(umidade);
      print(sensorUmidSolo);
      print(pH);
      print(bomba);
    });
   
  }

  
  

Future<void> _ligarBomba() async {
    try {
      final response = await http.post(
        Uri.parse('https://apiintegradoresp-production.up.railway.app/bomba'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'estado': 1}),
      );

      if (response.statusCode == 200) {
        setState(() {
          status_cor = Colors.green;
        });
        print("Bomba ligada com sucesso!");
      } else {
        print("Erro ao ligar a bomba: ${response.statusCode}");
      }
    } catch (e) {
      print("Erro na requisição: $e");
    }
  }
  Future<void> _desligarBomba() async {
    try {
      final response = await http.post(
        Uri.parse('https://apiintegradoresp-production.up.railway.app/bomba'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'estado': 0}),
      );

      if (response.statusCode == 200) {
        setState(() {
          status_cor = Colors.red;
        });
        print("Bomba desligada com sucesso!");
      } else {
        print("Erro ao ligar a bomba: ${response.statusCode}");
      }
    } catch (e) {
      print("Erro na requisição: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFEAF5EE),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          title: Text(
            'Acionamento',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        // Widget novo Listview.builder
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Ícone de bomba de irrigação
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: status_cor.withOpacity(0.2),
                        boxShadow: [
                          BoxShadow(
                            color: status_cor.withOpacity(0.3),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(32),
                      child: Icon(
                        Icons.water, // Ícone de bomba de irrigação
                        size: 80,
                        color: status_cor,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: _ligarBomba,
                          icon: Icon(Icons.power_settings_new),
                          label: Text('Ligar'),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: _desligarBomba,
                          icon: Icon(Icons.power_off),
                          label: Text('Desligar'),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      onPressed: _leitura,
                      icon: Icon(Icons.refresh),
                      label: Text('Leitura'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              // Parâmetros em cards
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _ParametroCard(label: 'Temperatura', value: temperatura?.toString() ?? '-'),
                  _ParametroCard(label: 'Umidade', value: umidade?.toString() ?? '-'),
                  _ParametroCard(label: 'Umidade Solo', value: sensorUmidSolo?.toString() ?? '-'),
                  _ParametroCard(label: 'pH', value: pH?.toString() ?? '-'),
                ],
              ),
            ],
          ),
        ));
  }
}

// Card customizado para exibir parâmetros
class _ParametroCard extends StatelessWidget {
  final String label;
  final String value;
  const _ParametroCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 130,
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, color: Colors.teal)),
          ],
        ),
      ),
    );
  }
}
