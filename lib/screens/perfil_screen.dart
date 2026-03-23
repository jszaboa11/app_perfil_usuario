import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/usuario.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // JSON de ejemplo (normalmente vendría de una API)
  static const String _jsonData = '''
  {
    "id": 1,
    "nombre": "Ana García",
    "correo": "ana@ejemplo.com",
    "edad": 28,
    "activo": true,
    "direccion": {
      "calle": "Av. Circunvalación 450",
      "ciudad": "San Pedro Sula"
    },
    "habilidades": ["Flutter", "Dart", "Firebase", "REST APIs"],
    "profesion": "Desarrolladora Móvil",
    "experiencia": 5
  }
  ''';

  Usuario? _usuario;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _parsearJson();
  }

  void _parsearJson() {
    try {
      // Paso 1: Convertir String JSON → Map
      final Map<String, dynamic> jsonMap = jsonDecode(_jsonData);

      // Paso 2: Map → Objeto tipado
      setState(() {
        _usuario = Usuario.fromJson(jsonMap);
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al parsear JSON: $e';
      });
    }
  }

  void _mostrarJsonResultante() {
    if (_usuario == null) return;

    // Objeto → JSON formateado con indentación
    final jsonString = const JsonEncoder.withIndent('  ')
        .convert(_usuario!.toJson());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('JSON Resultante'),
        content: SingleChildScrollView(
          child: SelectableText(
            jsonString,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Ver JSON',
            onPressed: _mostrarJsonResultante,
          ),
        ],
      ),
      body: _errorMessage != null
          ? _buildError()
          : _usuario == null
              ? const Center(child: CircularProgressIndicator())
              : _buildPerfil(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildPerfil() {
    final u = _usuario!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.deepPurple,
            child: Text(
              u.nombre[0],
              style: const TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            u.nombre,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Chip(
            label: Text(u.activo ? 'Activo' : 'Inactivo'),
            backgroundColor: u.activo ? Colors.green[100] : Colors.red[100],
          ),
          const SizedBox(height: 24),

          // Información
          _infoCard('Información Personal', [
            _infoRow(Icons.email, 'Correo', u.correo),
            _infoRow(Icons.cake, 'Edad', '${u.edad} años'),
            _infoRow(Icons.location_on, 'Dirección', u.direccion.calle),
            _infoRow(Icons.location_city, 'Ciudad', u.direccion.ciudad),
            _infoRow(Icons.home_work, 'Profesión', u.profesion ?? 'No especificada'),
            _infoRow(Icons.timer_3, 'Años de experiencia', u.experiencia?.toString() ?? 'No especificada'),            
          ]),
          const SizedBox(height: 16),

          // Habilidades
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Habilidades',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: u.habilidades
                        .map((h) => Chip(
                              label: Text(h),
                              backgroundColor: Colors.deepPurple[50],
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String titulo, List<Widget> filas) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...filas,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}