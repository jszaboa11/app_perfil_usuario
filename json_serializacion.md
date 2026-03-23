# 📱 Flutter: JSON, Serialización y Almacenamiento de Datos
---

## 📚 Tabla de Contenidos

1. [Introducción a JSON y Dart](#1-introducción-a-json-y-dart)
2. [Serialización Manual con `dart:convert`](#2-serialización-manual-con-dartconvert)
3. [Serialización con Generación de Código (`json_serializable`)](#3-serialización-con-generación-de-código-json_serializable)
4. [Parsear JSON en el Fondo (Isolates)](#4-parsear-json-en-el-fondo-isolates)
5. [Almacenamiento Clave-Valor con `shared_preferences`](#5-almacenamiento-clave-valor-con-shared_preferences)
6. [Leer y Escribir Archivos con `path_provider`](#6-leer-y-escribir-archivos-con-path_provider)
7. [Proyecto Integrador: App de Notas Completa](#7-proyecto-integrador-app-de-notas-completa)
8. [Buenas Prácticas y Errores Comunes](#8-buenas-prácticas-y-errores-comunes)

---

## 1. Introducción a JSON y Dart

### ¿Qué es JSON?

**JSON** (JavaScript Object Notation) es el formato estándar para intercambiar datos entre aplicaciones. En Flutter lo usamos para:

- Consumir APIs REST
- Guardar configuraciones locales
- Sincronizar datos con servidores
- Compartir datos entre aplicaciones

### Anatomía de un JSON

```json
{
  "id": 1,
  "nombre": "Ana García",
  "activo": true,
  "edad": 28,
  "correo": "ana@email.com",
  "direccion": {
    "calle": "Av. Principal 123",
    "ciudad": "San Pedro Sula"
  },
  "habilidades": ["Flutter", "Dart", "Firebase"]
}
```

| Tipo JSON    | Equivalente Dart   |
|--------------|--------------------|
| `string`     | `String`           |
| `number`     | `int` / `double`   |
| `boolean`    | `bool`             |
| `null`       | `null`             |
| `array`      | `List<T>`          |
| `object`     | `Map<String, dynamic>` / clase |

### El Ciclo de Vida del JSON en Flutter

```
API / Archivo
     │
     ▼
  String JSON
     │  dart:convert → jsonDecode()
     ▼
Map<String, dynamic>
     │  fromJson()
     ▼
  Modelo Dart
     │  toJson()
     ▼
Map<String, dynamic>
     │  dart:convert → jsonEncode()
     ▼
  String JSON
     │
     ▼
API / Archivo
```

---

## 2. Serialización Manual con `dart:convert`

### 🎯 App Demo #1: Visor de Perfil de Usuario

Esta app carga un perfil de usuario desde un JSON hardcodeado y lo muestra en pantalla.

#### Estructura del Proyecto

```
app_perfil_usuario/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── usuario.dart
│   └── screens/
│       └── perfil_screen.dart
└── pubspec.yaml
```

#### `pubspec.yaml`

```yaml
name: app_perfil_usuario
description: Demo de serialización JSON manual

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

flutter:
  uses-material-design: true
```

#### `lib/models/usuario.dart`

```dart
/// Modelo de Usuario con serialización manual
class Usuario {
  final int id;
  final String nombre;
  final String correo;
  final int edad;
  final bool activo;
  final Direccion direccion;
  final List<String> habilidades;

  // Constructor constante para mejor rendimiento
  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.edad,
    required this.activo,
    required this.direccion,
    required this.habilidades,
  });

  // ─────────────────────────────────────────
  // DESERIALIZACIÓN: JSON → Objeto Dart
  // ─────────────────────────────────────────
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      correo: json['correo'] as String,
      edad: json['edad'] as int,
      activo: json['activo'] as bool,
      // Objeto anidado: delegamos a su propio fromJson
      direccion: Direccion.fromJson(
        json['direccion'] as Map<String, dynamic>,
      ),
      // Lista de strings: cast explícito
      habilidades: List<String>.from(json['habilidades'] as List),
    );
  }

  // ─────────────────────────────────────────
  // SERIALIZACIÓN: Objeto Dart → JSON
  // ─────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'edad': edad,
      'activo': activo,
      'direccion': direccion.toJson(),
      'habilidades': habilidades,
    };
  }

  // Útil para debugging
  @override
  String toString() {
    return 'Usuario(id: $id, nombre: $nombre, activo: $activo)';
  }

  // copyWith para inmutabilidad
  Usuario copyWith({
    int? id,
    String? nombre,
    String? correo,
    int? edad,
    bool? activo,
    Direccion? direccion,
    List<String>? habilidades,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      edad: edad ?? this.edad,
      activo: activo ?? this.activo,
      direccion: direccion ?? this.direccion,
      habilidades: habilidades ?? this.habilidades,
    );
  }
}

/// Modelo de Dirección anidado
class Direccion {
  final String calle;
  final String ciudad;

  const Direccion({required this.calle, required this.ciudad});

  factory Direccion.fromJson(Map<String, dynamic> json) {
    return Direccion(
      calle: json['calle'] as String,
      ciudad: json['ciudad'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'calle': calle,
    'ciudad': ciudad,
  };
}
```

#### `lib/screens/perfil_screen.dart`

```dart
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
    "habilidades": ["Flutter", "Dart", "Firebase", "REST APIs"]
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
```

#### `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'screens/perfil_screen.dart';

void main() => runApp(const MiApp());

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo JSON',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const PerfilScreen(),
    );
  }
}
```

### 📝 Conceptos Clave — Serialización Manual

| Concepto | Descripción |
|---|---|
| `jsonDecode(String)` | Convierte un JSON String a `Map<String, dynamic>` o `List` |
| `jsonEncode(Object)` | Convierte un Map/List a JSON String |
| `factory Constructor` | Patrón para crear objetos desde un Map |
| `toJson()` | Método que convierte el objeto a Map serializable |
| `JsonEncoder.withIndent` | Produce JSON con formato legible |

### ⚠️ Errores Comunes en Serialización Manual

```dart
// ❌ MAL: Sin casting, puede fallar silenciosamente
final nombre = json['nombre']; // tipo: dynamic

// ✅ BIEN: Con casting explícito, falla rápido y claro
final nombre = json['nombre'] as String;

// ❌ MAL: Olvidar que una lista viene como List dinámica
final skills = json['habilidades'] as List<String>; // ERROR en tiempo de ejecución

// ✅ BIEN: Convertir explícitamente
final skills = List<String>.from(json['habilidades'] as List);

// ❌ MAL: No manejar nulos
final foto = json['foto'] as String; // Crash si es null

// ✅ BIEN: Manejar nulos con el operador ?
final foto = json['foto'] as String?;
```

---

## 3. Serialización con Generación de Código (`json_serializable`)

Para proyectos grandes, la serialización manual es tediosa y propensa a errores. `json_serializable` genera el código automáticamente.

### 🎯 App Demo #2: Catálogo de Productos

#### `pubspec.yaml`

```yaml
name: app_catalogo
description: Demo con json_serializable

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  json_serializable: ^6.8.0
```

#### `lib/models/producto.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

// Este archivo "parte" conecta con el generado automáticamente
part 'producto.g.dart';

@JsonSerializable() // Anotación mágica 🪄
class Producto {
  final int id;
  final String nombre;
  final double precio;
  final String descripcion;
  
  // Mapea el campo JSON 'image_url' al campo Dart 'imagenUrl'
  @JsonKey(name: 'image_url')
  final String imagenUrl;
  
  // Campo opcional con valor por defecto
  @JsonKey(defaultValue: 0)
  final int stock;
  
  // Campo excluido de la serialización
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool esFavorito;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.descripcion,
    required this.imagenUrl,
    this.stock = 0,
    this.esFavorito = false,
  });

  // Métodos generados automáticamente por build_runner
  factory Producto.fromJson(Map<String, dynamic> json) =>
      _$ProductoFromJson(json);

  Map<String, dynamic> toJson() => _$ProductoToJson(this);
}
```

#### Comando para generar código

```bash
# Generar una sola vez
dart run build_runner build

# Modo watch: regenera al guardar cambios
dart run build_runner watch --delete-conflicting-outputs
```

#### Archivo generado `lib/models/producto.g.dart`

> ⚠️ **No edites este archivo manualmente**, es generado automáticamente.

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'producto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Producto _$ProductoFromJson(Map<String, dynamic> json) => Producto(
      id: (json['id'] as num).toInt(),
      nombre: json['nombre'] as String,
      precio: (json['precio'] as num).toDouble(),
      descripcion: json['descripcion'] as String,
      imagenUrl: json['image_url'] as String,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ProductoToJson(Producto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'precio': instance.precio,
      'descripcion': instance.descripcion,
      'image_url': instance.imagenUrl,
      'stock': instance.stock,
    };
```

#### `lib/screens/catalogo_screen.dart`

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/producto.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  static const String _jsonCatalogo = '''
  [
    {
      "id": 1,
      "nombre": "Laptop Pro X",
      "precio": 1299.99,
      "descripcion": "Laptop de alto rendimiento para profesionales",
      "image_url": "https://picsum.photos/200/150?random=1",
      "stock": 15
    },
    {
      "id": 2,
      "nombre": "Auriculares Inalámbricos",
      "precio": 89.99,
      "descripcion": "Sonido premium con cancelación de ruido",
      "image_url": "https://picsum.photos/200/150?random=2",
      "stock": 42
    },
    {
      "id": 3,
      "nombre": "Mouse Ergonómico",
      "precio": 45.50,
      "descripcion": "Diseño ergonómico para largas jornadas",
      "image_url": "https://picsum.photos/200/150?random=3",
      "stock": 0
    }
  ]
  ''';

  late List<Producto> _productos;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  void _cargarProductos() {
    final List<dynamic> lista = jsonDecode(_jsonCatalogo) as List;
    setState(() {
      _productos = lista
          .map((json) => Producto.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  void _toggleFavorito(int index) {
    setState(() {
      _productos[index].esFavorito = !_productos[index].esFavorito;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Productos'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _productos.length,
        itemBuilder: (ctx, index) {
          final p = _productos[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal[100],
                child: Text(
                  p.nombre[0],
                  style: TextStyle(color: Colors.teal[800]),
                ),
              ),
              title: Text(
                p.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.descripcion),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${p.precio.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.teal[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: p.stock > 0
                              ? Colors.green[50]
                              : Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: p.stock > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                        child: Text(
                          p.stock > 0
                              ? 'Stock: ${p.stock}'
                              : 'Sin stock',
                          style: TextStyle(
                            fontSize: 12,
                            color: p.stock > 0
                                ? Colors.green[800]
                                : Colors.red[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  p.esFavorito ? Icons.favorite : Icons.favorite_border,
                  color: p.esFavorito ? Colors.red : null,
                ),
                onPressed: () => _toggleFavorito(index),
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
```

### 📊 Comparación: Manual vs `json_serializable`

| Criterio | Manual | json_serializable |
|---|---|---|
| Configuración | Ninguna | Requiere `build_runner` |
| Código escrito | Mucho | Mínimo |
| Propenso a errores | Sí | No |
| Ideal para | Proyectos pequeños, aprendizaje | Proyectos medianos/grandes |
| Regenerar al cambiar modelo | Manual | `build_runner watch` |

---

## 4. Parsear JSON en el Fondo (Isolates)

### ¿Por qué parsear en segundo plano?

El procesamiento de JSON en el **hilo principal (UI thread)** puede causar **jank** (congelamiento de la interfaz) cuando el JSON es muy grande (miles de registros).

```
Hilo Principal (UI)         Isolate (Fondo)
       │                          │
  [Renderiza UI]                  │
       │                          │
  [Recibe JSON grande]            │
       │──── Envía datos ────────►│
       │                    [Parsea JSON]
  [Sigue renderizando UI]         │
       │◄─── Devuelve objetos ────│
  [Actualiza UI]                  │
```

### 🎯 App Demo #3: Lista de Países (JSON grande)

#### `pubspec.yaml`

```yaml
name: app_paises
description: Demo de parseo en background con Isolates

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
```

#### `lib/models/pais.dart`

```dart
class Pais {
  final String nombre;
  final String codigo;
  final String capital;
  final int poblacion;
  final String region;
  final String bandera;

  const Pais({
    required this.nombre,
    required this.codigo,
    required this.capital,
    required this.poblacion,
    required this.region,
    required this.bandera,
  });

  factory Pais.fromJson(Map<String, dynamic> json) {
    return Pais(
      nombre: (json['name']?['common'] as String?) ?? 'Desconocido',
      codigo: (json['cca2'] as String?) ?? '',
      capital: ((json['capital'] as List?)?.first as String?) ?? 'N/A',
      poblacion: (json['population'] as int?) ?? 0,
      region: (json['region'] as String?) ?? '',
      bandera: (json['flag'] as String?) ?? '🏳️',
    );
  }
}
```

#### `lib/services/pais_service.dart`

```dart
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/pais.dart';

class PaisService {
  static const String _url =
      'https://restcountries.com/v3.1/region/americas?fields=name,cca2,capital,population,region,flag';

  /// Descarga y parsea la lista de países en un isolate separado
  Future<List<Pais>> obtenerPaises() async {
    // 1. Descargar el JSON en el hilo principal
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode != 200) {
      throw Exception('Error HTTP: ${response.statusCode}');
    }

    // 2. Enviar el String JSON al isolate para procesarlo
    //    compute() es el helper de Flutter para crear isolates fácilmente
    final paises = await compute(_parsearPaisesEnIsolate, response.body);

    return paises;
  }

  /// Esta función DEBE ser top-level o static para poder usarse en isolate
  /// compute() la ejecuta en un hilo separado
  static List<Pais> _parsearPaisesEnIsolate(String jsonString) {
    final List<dynamic> lista = jsonDecode(jsonString) as List;

    return lista
        .map((item) => Pais.fromJson(item as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.nombre.compareTo(b.nombre));
  }
}

// ═══════════════════════════════════════════════════════
// MÉTODO AVANZADO: Isolate manual con SendPort/ReceivePort
// Para cuando necesitas más control o comunicación bidireccional
// ═══════════════════════════════════════════════════════

class PaisServiceAvanzado {
  /// Versión con Isolate explícito — más control, más código
  Future<List<Pais>> obtenerPaisesConIsolateManual(
      String jsonString) async {
    
    // Puerto para recibir la respuesta del isolate
    final receivePort = ReceivePort();
    
    // Crear el isolate pasándole el puerto y los datos
    await Isolate.spawn(
      _entryPoint,
      _IsolateData(
        sendPort: receivePort.sendPort,
        jsonString: jsonString,
      ),
    );
    
    // Esperar la respuesta (se bloquea aquí hasta recibirla)
    final resultado = await receivePort.first;
    
    if (resultado is List<Pais>) {
      return resultado;
    } else {
      throw Exception('Error en isolate: $resultado');
    }
  }

  /// Función de entrada del isolate
  static void _entryPoint(_IsolateData data) {
    try {
      final lista = jsonDecode(data.jsonString) as List;
      final paises = lista
          .map((item) => Pais.fromJson(item as Map<String, dynamic>))
          .toList();
      // Enviar resultado de vuelta
      data.sendPort.send(paises);
    } catch (e) {
      data.sendPort.send('Error: $e');
    }
  }
}

/// Clase auxiliar para pasar datos al isolate
class _IsolateData {
  final SendPort sendPort;
  final String jsonString;
  const _IsolateData({required this.sendPort, required this.jsonString});
}
```

#### `lib/screens/paises_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../models/pais.dart';
import '../services/pais_service.dart';

class PaisesScreen extends StatefulWidget {
  const PaisesScreen({super.key});

  @override
  State<PaisesScreen> createState() => _PaisesScreenState();
}

class _PaisesScreenState extends State<PaisesScreen> {
  final PaisService _service = PaisService();
  
  List<Pais> _paises = [];
  List<Pais> _filtrados = [];
  bool _cargando = false;
  String? _error;
  final TextEditingController _busquedaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarPaises();
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarPaises() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final paises = await _service.obtenerPaises();
      setState(() {
        _paises = paises;
        _filtrados = paises;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  void _filtrar(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtrados = _paises;
      } else {
        _filtrados = _paises
            .where((p) =>
                p.nombre.toLowerCase().contains(query.toLowerCase()) ||
                p.capital.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  String _formatearPoblacion(int poblacion) {
    if (poblacion >= 1000000) {
      return '${(poblacion / 1000000).toStringAsFixed(1)}M';
    } else if (poblacion >= 1000) {
      return '${(poblacion / 1000).toStringAsFixed(0)}K';
    }
    return poblacion.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Países de América'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _busquedaCtrl,
              onChanged: _filtrar,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar país o capital...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.white60),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Parseando JSON en segundo plano...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Error: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _cargarPaises,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_filtrados.isEmpty) {
      return const Center(child: Text('No se encontraron países'));
    }

    return Column(
      children: [
        Container(
          color: Colors.indigo[50],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.indigo),
              const SizedBox(width: 8),
              Text(
                '${_filtrados.length} países — Parseado en Isolate 🚀',
                style: const TextStyle(color: Colors.indigo, fontSize: 13),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filtrados.length,
            itemBuilder: (ctx, index) {
              final p = _filtrados[index];
              return ListTile(
                leading: Text(
                  p.bandera,
                  style: const TextStyle(fontSize: 28),
                ),
                title: Text(p.nombre),
                subtitle: Text('${p.capital} · ${p.region}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.indigo[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatearPoblacion(p.poblacion),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.indigo[700],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

### 📊 ¿Cuándo usar `compute()`?

```
Tamaño del JSON          Recomendación
──────────────────────────────────────────
< 10 KB                  Hilo principal ✅
10 KB – 1 MB             Evalúa caso por caso
> 1 MB o > 1000 objetos  Isolate/compute() ✅
```

---

## 5. Almacenamiento Clave-Valor con `shared_preferences`

### ¿Cuándo usar SharedPreferences?

Ideal para datos simples y pequeños que deben persistir entre sesiones:

- ✅ Preferencias del usuario (tema, idioma)
- ✅ Tokens de autenticación
- ✅ Banderas de onboarding
- ✅ Configuraciones de la app
- ❌ No para listas grandes o datos estructurados complejos

### 🎯 App Demo #4: App de Configuración y Preferencias

#### `pubspec.yaml`

```yaml
name: app_configuracion
description: Demo de SharedPreferences

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.3.0
```

#### `lib/services/preferencias_service.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio que encapsula todas las operaciones de SharedPreferences
/// Aplicamos el patrón Service/Repository para mantener limpio el código
class PreferenciasService {
  // Claves tipadas como constantes — evita errores de tipeo
  static const String _keyTemaOscuro = 'tema_oscuro';
  static const String _keyIdioma = 'idioma';
  static const String _keyNombreUsuario = 'nombre_usuario';
  static const String _keyNotificaciones = 'notificaciones_activas';
  static const String _keyTamanoFuente = 'tamano_fuente';
  static const String _keyPrimerUso = 'primer_uso';
  static const String _keyUltimoAcceso = 'ultimo_acceso';
  static const String _keyContadorAperturas = 'contador_aperturas';

  // Instancia única compartida
  static SharedPreferences? _prefs;

  /// Inicializar SharedPreferences (llamar en main())
  static Future<void> inicializar() async {
    _prefs = await SharedPreferences.getInstance();
    // Registrar apertura
    await _registrarApertura();
  }

  static SharedPreferences get _instancia {
    assert(_prefs != null, 'Llama a PreferenciasService.inicializar() primero');
    return _prefs!;
  }

  // ─── Tema ────────────────────────────────────────
  
  bool get temaOscuro => _instancia.getBool(_keyTemaOscuro) ?? false;

  Future<void> setTemaOscuro(bool valor) =>
      _instancia.setBool(_keyTemaOscuro, valor);

  // ─── Idioma ──────────────────────────────────────
  
  String get idioma => _instancia.getString(_keyIdioma) ?? 'es';

  Future<void> setIdioma(String valor) =>
      _instancia.setString(_keyIdioma, valor);

  // ─── Nombre de usuario ──────────────────────────
  
  String get nombreUsuario =>
      _instancia.getString(_keyNombreUsuario) ?? '';

  Future<void> setNombreUsuario(String valor) =>
      _instancia.setString(_keyNombreUsuario, valor);

  // ─── Notificaciones ─────────────────────────────
  
  bool get notificacionesActivas =>
      _instancia.getBool(_keyNotificaciones) ?? true;

  Future<void> setNotificaciones(bool valor) =>
      _instancia.setBool(_keyNotificaciones, valor);

  // ─── Tamaño de fuente ────────────────────────────
  
  double get tamanoFuente =>
      _instancia.getDouble(_keyTamanoFuente) ?? 14.0;

  Future<void> setTamanoFuente(double valor) =>
      _instancia.setDouble(_keyTamanoFuente, valor);

  // ─── Onboarding / Primer uso ─────────────────────
  
  bool get esPrimerUso => _instancia.getBool(_keyPrimerUso) ?? true;

  Future<void> marcarUsado() => _instancia.setBool(_keyPrimerUso, false);

  // ─── Estadísticas ────────────────────────────────
  
  int get contadorAperturas =>
      _instancia.getInt(_keyContadorAperturas) ?? 0;

  String get ultimoAcceso =>
      _instancia.getString(_keyUltimoAcceso) ?? 'Nunca';

  static Future<void> _registrarApertura() async {
    final prefs = _instancia;
    final actual = prefs.getInt(_keyContadorAperturas) ?? 0;
    await prefs.setInt(_keyContadorAperturas, actual + 1);
    await prefs.setString(
      _keyUltimoAcceso,
      DateTime.now().toIso8601String(),
    );
  }

  // ─── Utilidades ──────────────────────────────────
  
  /// Limpiar TODAS las preferencias (útil para logout)
  Future<void> limpiarTodo() => _instancia.clear();

  /// Eliminar una clave específica
  Future<bool> eliminar(String clave) => _instancia.remove(clave);

  /// Verificar si existe una clave
  bool contieneClave(String clave) => _instancia.containsKey(clave);

  /// Obtener todas las claves almacenadas
  Set<String> get todasLasClaves => _instancia.getKeys();
}
```

#### `lib/screens/configuracion_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../services/preferencias_service.dart';

class ConfiguracionScreen extends StatefulWidget {
  final VoidCallback onTemaChanged;
  
  const ConfiguracionScreen({super.key, required this.onTemaChanged});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final _prefs = PreferenciasService();
  final _nombreCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nombreCtrl.text = _prefs.nombreUsuario;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.restore, color: Colors.white),
            label: const Text(
              'Restablecer',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _restablecerTodo,
          ),
        ],
      ),
      body: ListView(
        children: [
          // ─── Perfil ─────────────────────────────
          _seccionHeader('Perfil'),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre de usuario',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              onSubmitted: (valor) async {
                await _prefs.setNombreUsuario(valor);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nombre guardado ✓')),
                  );
                }
              },
            ),
          ),

          // ─── Apariencia ─────────────────────────
          _seccionHeader('Apariencia'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Tema oscuro'),
            subtitle: const Text('Activar modo nocturno'),
            value: _prefs.temaOscuro,
            onChanged: (valor) async {
              await _prefs.setTemaOscuro(valor);
              widget.onTemaChanged();
              setState(() {});
            },
          ),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Tamaño de texto'),
            subtitle: Text('${_prefs.tamanoFuente.toStringAsFixed(0)} px'),
            trailing: SizedBox(
              width: 160,
              child: Slider(
                min: 10,
                max: 22,
                divisions: 6,
                value: _prefs.tamanoFuente,
                label: '${_prefs.tamanoFuente.toStringAsFixed(0)}px',
                onChanged: (valor) async {
                  await _prefs.setTamanoFuente(valor);
                  setState(() {});
                },
              ),
            ),
          ),

          // ─── Idioma ─────────────────────────────
          _seccionHeader('Idioma'),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idioma de la aplicación'),
            subtitle: Text(_nombreIdioma(_prefs.idioma)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _seleccionarIdioma,
          ),

          // ─── Notificaciones ─────────────────────
          _seccionHeader('Notificaciones'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Notificaciones push'),
            subtitle: const Text('Recibir alertas de la app'),
            value: _prefs.notificacionesActivas,
            onChanged: (valor) async {
              await _prefs.setNotificaciones(valor);
              setState(() {});
            },
          ),

          // ─── Estadísticas ────────────────────────
          _seccionHeader('Estadísticas de uso'),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Aperturas totales'),
            trailing: Chip(
              label: Text('${_prefs.contadorAperturas}'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Último acceso'),
            subtitle: Text(_formatearFecha(_prefs.ultimoAcceso)),
          ),

          // ─── Datos ──────────────────────────────
          _seccionHeader('Datos'),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Claves almacenadas'),
            trailing: Chip(
              label: Text('${_prefs.todasLasClaves.length}'),
            ),
            onTap: _mostrarClaves,
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: const Text(
                'Limpiar todos los datos',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
              ),
              onPressed: _confirmarLimpiar,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _seccionHeader(String titulo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Text(
        titulo.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  String _nombreIdioma(String codigo) {
    const idiomas = {'es': 'Español', 'en': 'English', 'fr': 'Français'};
    return idiomas[codigo] ?? codigo;
  }

  String _formatearFecha(String iso) {
    try {
      final fecha = DateTime.parse(iso);
      return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  void _seleccionarIdioma() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Seleccionar idioma',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            for (final entry in {
              'es': '🇪🇸 Español',
              'en': '🇺🇸 English',
              'fr': '🇫🇷 Français',
            }.entries)
              ListTile(
                title: Text(entry.value),
                trailing: _prefs.idioma == entry.key
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () async {
                  await _prefs.setIdioma(entry.key);
                  setState(() {});
                  if (mounted) Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _mostrarClaves() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Claves en SharedPreferences'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _prefs.todasLasClaves
              .map((k) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.key, size: 14),
                        const SizedBox(width: 8),
                        Text(k, style: const TextStyle(fontFamily: 'monospace')),
                      ],
                    ),
                  ))
              .toList(),
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

  void _restablecerTodo() async {
    await _prefs.limpiarTodo();
    setState(() {
      _nombreCtrl.text = '';
    });
    widget.onTemaChanged();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuración restablecida')),
      );
    }
  }

  void _confirmarLimpiar() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Limpiar datos?'),
        content: const Text(
          'Se eliminarán todas las preferencias guardadas. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _restablecerTodo();
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }
}
```

#### `lib/main.dart` (con soporte de tema dinámico)

```dart
import 'package:flutter/material.dart';
import 'screens/configuracion_screen.dart';
import 'services/preferencias_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializar SharedPreferences antes de correr la app
  await PreferenciasService.inicializar();
  runApp(const MiApp());
}

class MiApp extends StatefulWidget {
  const MiApp({super.key});

  @override
  State<MiApp> createState() => _MiAppState();
}

class _MiAppState extends State<MiApp> {
  final _prefs = PreferenciasService();

  void _refrescarTema() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Configuración App',
      debugShowCheckedModeBanner: false,
      // El tema se lee de SharedPreferences en cada rebuild
      themeMode: _prefs.temaOscuro ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: ConfiguracionScreen(onTemaChanged: _refrescarTema),
    );
  }
}
```

### 📋 Resumen de Métodos SharedPreferences

```dart
final prefs = await SharedPreferences.getInstance();

// ─── ESCRIBIR ──────────────────────────────
await prefs.setBool('key', true);
await prefs.setInt('key', 42);
await prefs.setDouble('key', 3.14);
await prefs.setString('key', 'hola');
await prefs.setStringList('key', ['a', 'b', 'c']);

// ─── LEER (con valores por defecto) ────────
final b = prefs.getBool('key') ?? false;
final i = prefs.getInt('key') ?? 0;
final d = prefs.getDouble('key') ?? 0.0;
final s = prefs.getString('key') ?? '';
final list = prefs.getStringList('key') ?? [];

// ─── ELIMINAR ──────────────────────────────
await prefs.remove('key');        // Una clave
await prefs.clear();              // Todo

// ─── VERIFICAR ─────────────────────────────
final existe = prefs.containsKey('key');
final claves = prefs.getKeys();   // Set<String>
```

> ⚠️ **Limitación importante**: SharedPreferences solo soporta tipos primitivos.  
> Para objetos complejos, serializa a JSON String primero:

```dart
// Guardar objeto como JSON
final jsonString = jsonEncode(usuario.toJson());
await prefs.setString('usuario', jsonString);

// Leer objeto desde JSON
final jsonString = prefs.getString('usuario');
if (jsonString != null) {
  final usuario = Usuario.fromJson(jsonDecode(jsonString));
}
```

---

## 6. Leer y Escribir Archivos con `path_provider`

### ¿Cuándo usar archivos locales?

| Caso de uso | Solución recomendada |
|---|---|
| Notas de texto | `path_provider` + `dart:io` |
| Documentos / PDF | `path_provider` + archivos binarios |
| Historial grande | `path_provider` + JSON / SQLite |
| Cache de imágenes | `path_provider` + bytes |
| Logs de la app | `path_provider` + append a archivo |

### Directorios disponibles en Flutter

```
Android                          iOS / macOS
────────────────                 ─────────────────────────
getTemporaryDirectory()          NSTemporaryDirectory
  └── /data/.../cache             └── tmp/

getApplicationDocumentsDirectory()  NSDocumentDirectory
  └── /data/.../files               └── Documents/

getApplicationSupportDirectory()  NSApplicationSupportDirectory
  └── /data/.../files/support       └── Library/Application Support/

getExternalStorageDirectory()    (No disponible en iOS)
  └── /sdcard/Android/data/.../files
```

### 🎯 App Demo #5: Diario Personal

#### `pubspec.yaml`

```yaml
name: app_diario
description: Demo de lectura y escritura de archivos

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  path_provider: ^2.1.0
  intl: ^0.19.0
```

#### `lib/services/archivo_service.dart`

```dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Servicio de bajo nivel para operaciones de archivo
class ArchivoService {
  // ──────────────────────────────────────────────────
  // TEXTO PLANO
  // ──────────────────────────────────────────────────

  /// Escribe texto en un archivo (sobreescribe si existe)
  Future<File> escribirTexto(String nombreArchivo, String contenido) async {
    final archivo = await _obtenerArchivo(nombreArchivo);
    return archivo.writeAsString(contenido);
  }

  /// Lee texto de un archivo
  Future<String?> leerTexto(String nombreArchivo) async {
    try {
      final archivo = await _obtenerArchivo(nombreArchivo);
      if (await archivo.exists()) {
        return archivo.readAsString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Añade texto al final de un archivo (útil para logs)
  Future<File> agregarTexto(String nombreArchivo, String linea) async {
    final archivo = await _obtenerArchivo(nombreArchivo);
    return archivo.writeAsString(
      '$linea\n',
      mode: FileMode.append,
    );
  }

  // ──────────────────────────────────────────────────
  // JSON ESTRUCTURADO
  // ──────────────────────────────────────────────────

  /// Guarda un objeto como JSON en disco
  Future<File> escribirJson(String nombreArchivo, dynamic datos) async {
    final archivo = await _obtenerArchivo(nombreArchivo);
    final jsonString = const JsonEncoder.withIndent('  ').convert(datos);
    return archivo.writeAsString(jsonString);
  }

  /// Lee y parsea JSON desde disco
  Future<dynamic> leerJson(String nombreArchivo) async {
    try {
      final texto = await leerTexto(nombreArchivo);
      if (texto == null) return null;
      return jsonDecode(texto);
    } catch (e) {
      return null;
    }
  }

  // ──────────────────────────────────────────────────
  // BYTES (imágenes, PDFs, etc.)
  // ──────────────────────────────────────────────────

  /// Escribe datos binarios
  Future<File> escribirBytes(String nombreArchivo, List<int> bytes) async {
    final archivo = await _obtenerArchivo(nombreArchivo);
    return archivo.writeAsBytes(bytes);
  }

  /// Lee datos binarios
  Future<List<int>?> leerBytes(String nombreArchivo) async {
    try {
      final archivo = await _obtenerArchivo(nombreArchivo);
      if (await archivo.exists()) {
        return archivo.readAsBytes();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ──────────────────────────────────────────────────
  // GESTIÓN DE ARCHIVOS
  // ──────────────────────────────────────────────────

  /// Elimina un archivo
  Future<bool> eliminar(String nombreArchivo) async {
    try {
      final archivo = await _obtenerArchivo(nombreArchivo);
      if (await archivo.exists()) {
        await archivo.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Verifica si un archivo existe
  Future<bool> existe(String nombreArchivo) async {
    final archivo = await _obtenerArchivo(nombreArchivo);
    return archivo.exists();
  }

  /// Tamaño en bytes de un archivo
  Future<int> tamanioBytes(String nombreArchivo) async {
    final archivo = await _obtenerArchivo(nombreArchivo);
    if (await archivo.exists()) {
      return archivo.length();
    }
    return 0;
  }

  /// Lista todos los archivos del directorio de documentos
  Future<List<FileSystemEntity>> listarArchivos() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.listSync().toList();
  }

  /// Obtiene la ruta del directorio de documentos
  Future<String> obtenerDirectorio() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  // ──────────────────────────────────────────────────
  // PRIVADO
  // ──────────────────────────────────────────────────

  Future<File> _obtenerArchivo(String nombreArchivo) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$nombreArchivo');
  }
}
```

#### `lib/models/entrada_diario.dart`

```dart
class EntradaDiario {
  final String id;
  final String titulo;
  final String contenido;
  final DateTime fecha;
  final String emoji;

  const EntradaDiario({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.fecha,
    required this.emoji,
  });

  factory EntradaDiario.fromJson(Map<String, dynamic> json) {
    return EntradaDiario(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      contenido: json['contenido'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      emoji: json['emoji'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'contenido': contenido,
    'fecha': fecha.toIso8601String(),
    'emoji': emoji,
  };

  EntradaDiario copyWith({
    String? titulo,
    String? contenido,
    String? emoji,
  }) =>
      EntradaDiario(
        id: id,
        titulo: titulo ?? this.titulo,
        contenido: contenido ?? this.contenido,
        fecha: fecha,
        emoji: emoji ?? this.emoji,
      );
}
```

#### `lib/services/diario_service.dart`

```dart
import '../models/entrada_diario.dart';
import 'archivo_service.dart';

/// Servicio de alto nivel para el diario
/// Usa ArchivoService internamente
class DiarioService {
  static const String _archivoEntradas = 'diario.json';
  final ArchivoService _archivoService = ArchivoService();

  Future<List<EntradaDiario>> cargarEntradas() async {
    final datos = await _archivoService.leerJson(_archivoEntradas);
    if (datos == null) return [];

    final lista = datos as List;
    return lista
        .map((item) =>
            EntradaDiario.fromJson(item as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha)); // Más recientes primero
  }

  Future<void> guardarEntrada(EntradaDiario entrada) async {
    final entradas = await cargarEntradas();

    // Verificar si es edición o nueva entrada
    final index = entradas.indexWhere((e) => e.id == entrada.id);
    if (index >= 0) {
      entradas[index] = entrada; // Actualizar
    } else {
      entradas.add(entrada); // Nueva
    }

    await _guardarLista(entradas);
  }

  Future<void> eliminarEntrada(String id) async {
    final entradas = await cargarEntradas();
    entradas.removeWhere((e) => e.id == id);
    await _guardarLista(entradas);
  }

  Future<void> _guardarLista(List<EntradaDiario> entradas) async {
    final datos = entradas.map((e) => e.toJson()).toList();
    await _archivoService.escribirJson(_archivoEntradas, datos);
  }

  Future<String> obtenerRutaArchivo() async {
    final dir = await _archivoService.obtenerDirectorio();
    return '$dir/$_archivoEntradas';
  }

  Future<int> obtenerTamanio() async {
    return _archivoService.tamanioBytes(_archivoEntradas);
  }
}
```

#### `lib/screens/diario_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/entrada_diario.dart';
import '../services/diario_service.dart';

class DiarioScreen extends StatefulWidget {
  const DiarioScreen({super.key});

  @override
  State<DiarioScreen> createState() => _DiarioScreenState();
}

class _DiarioScreenState extends State<DiarioScreen> {
  final DiarioService _servicio = DiarioService();
  List<EntradaDiario> _entradas = [];
  bool _cargando = true;
  String _rutaArchivo = '';
  int _tamanioBytes = 0;

  @override
  void initState() {
    super.initState();
    _cargarEntradas();
  }

  Future<void> _cargarEntradas() async {
    setState(() => _cargando = true);
    final entradas = await _servicio.cargarEntradas();
    final ruta = await _servicio.obtenerRutaArchivo();
    final tamanio = await _servicio.obtenerTamanio();
    setState(() {
      _entradas = entradas;
      _rutaArchivo = ruta;
      _tamanioBytes = tamanio;
      _cargando = false;
    });
  }

  void _nuevaEntrada() {
    _mostrarFormulario(null);
  }

  void _editarEntrada(EntradaDiario entrada) {
    _mostrarFormulario(entrada);
  }

  void _mostrarFormulario(EntradaDiario? existente) {
    final tituloCtrl = TextEditingController(
      text: existente?.titulo ?? '',
    );
    final contenidoCtrl = TextEditingController(
      text: existente?.contenido ?? '',
    );
    String emojiSeleccionado = existente?.emoji ?? '😊';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                existente == null ? 'Nueva entrada' : 'Editar entrada',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Selector de emoji
              Row(
                children: [
                  const Text('Estado de ánimo: '),
                  for (final e in ['😊', '😢', '😡', '🤔', '🥳', '😴'])
                    GestureDetector(
                      onTap: () =>
                          setModalState(() => emojiSeleccionado = e),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: emojiSeleccionado == e
                              ? Border.all(
                                  color: Theme.of(ctx).colorScheme.primary,
                                  width: 2,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: tituloCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contenidoCtrl,
                decoration: const InputDecoration(
                  labelText: '¿Cómo fue tu día?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (tituloCtrl.text.isEmpty) return;
                    final entrada = EntradaDiario(
                      id: existente?.id ??
                          DateTime.now().millisecondsSinceEpoch
                              .toString(),
                      titulo: tituloCtrl.text,
                      contenido: contenidoCtrl.text,
                      fecha: existente?.fecha ?? DateTime.now(),
                      emoji: emojiSeleccionado,
                    );
                    await _servicio.guardarEntrada(entrada);
                    await _cargarEntradas();
                    if (mounted) Navigator.pop(ctx);
                  },
                  child: Text(existente == null ? 'Guardar' : 'Actualizar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _eliminarEntrada(EntradaDiario entrada) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar entrada'),
        content:
            Text('¿Eliminar "${entrada.titulo}"? No se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _servicio.eliminarEntrada(entrada.id);
      await _cargarEntradas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Diario Personal'),
        backgroundColor: Colors.pink[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _mostrarInfoArchivo,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _entradas.isEmpty
              ? _buildVacio()
              : _buildLista(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevaEntrada,
        icon: const Icon(Icons.edit),
        label: const Text('Nueva entrada'),
        backgroundColor: Colors.pink[800],
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📖', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'Tu diario está vacío',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Toca el botón para escribir tu primera entrada'),
        ],
      ),
    );
  }

  Widget _buildLista() {
    // Agrupar por mes/año
    final Map<String, List<EntradaDiario>> agrupadas = {};
    for (final e in _entradas) {
      final llave = DateFormat('MMMM yyyy', 'es').format(e.fecha);
      agrupadas.putIfAbsent(llave, () => []).add(e);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        // Info del archivo
        Container(
          color: Colors.pink[50],
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Row(
            children: [
              const Icon(Icons.folder, size: 16, color: Colors.pink),
              const SizedBox(width: 8),
              Text(
                '${_entradas.length} entradas · ${_tamanioBytes} bytes',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.pink,
                ),
              ),
            ],
          ),
        ),

        // Lista agrupada
        for (final grupo in agrupadas.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              grupo.key.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.pink[800],
                letterSpacing: 1.2,
              ),
            ),
          ),
          for (final entrada in grupo.value)
            Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              child: ListTile(
                leading: Text(
                  entrada.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
                title: Text(
                  entrada.titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (entrada.contenido.isNotEmpty)
                      Text(
                        entrada.contenido,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      DateFormat('EEEE d, HH:mm', 'es')
                          .format(entrada.fecha),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Editar'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'eliminar',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.red),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  onSelected: (valor) {
                    if (valor == 'editar') _editarEntrada(entrada);
                    if (valor == 'eliminar') _eliminarEntrada(entrada);
                  },
                ),
                isThreeLine: true,
              ),
            ),
        ],
      ],
    );
  }

  void _mostrarInfoArchivo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Información del archivo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoFila('📁 Ruta', _rutaArchivo),
            const SizedBox(height: 8),
            _infoFila('📝 Entradas', '${_entradas.length}'),
            const SizedBox(height: 8),
            _infoFila('💾 Tamaño', '$_tamanioBytes bytes'),
            const SizedBox(height: 8),
            _infoFila('📄 Formato', 'JSON en disco'),
          ],
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

  Widget _infoFila(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }
}
```

---

## 7. Proyecto Integrador: App de Notas Completa

Esta app combina **todos los conceptos** anteriores:

- Modelos con `json_serializable`
- Persistencia con archivos (para las notas)
- SharedPreferences (para configuración de usuario)
- Parseo en background (para cargas iniciales grandes)

### Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────┐
│                    UI Layer                          │
│  NotasScreen ─── ConfigScreen ─── DetallsScreen     │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│                  Service Layer                       │
│  NotasService ─── PreferenciasService               │
└──────────┬────────────────────┬─────────────────────┘
           │                    │
┌──────────▼──────┐   ┌─────────▼────────────────────┐
│  Archivos JSON  │   │      SharedPreferences        │
│  (path_provider)│   │  (configuración de usuario)   │
└─────────────────┘   └──────────────────────────────┘
```

### Estructura del proyecto final

```
app_notas_completa/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── nota.dart
│   │   └── nota.g.dart        ← generado
│   ├── services/
│   │   ├── notas_service.dart
│   │   ├── archivo_service.dart
│   │   └── preferencias_service.dart
│   ├── screens/
│   │   ├── notas_screen.dart
│   │   ├── editor_screen.dart
│   │   └── config_screen.dart
│   └── widgets/
│       └── nota_card.dart
├── pubspec.yaml
└── README.md
```

#### `lib/models/nota.dart` (con json_serializable)

```dart
import 'package:json_annotation/json_annotation.dart';

part 'nota.g.dart';

enum Prioridad { baja, media, alta }

enum Categoria { personal, trabajo, ideas, tareas }

@JsonSerializable(explicitToJson: true)
class Nota {
  final String id;
  final String titulo;
  final String contenido;
  final DateTime creadaEn;
  DateTime modificadaEn;
  final Prioridad prioridad;
  final Categoria categoria;
  final List<String> etiquetas;
  bool archivada;

  Nota({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.creadaEn,
    required this.modificadaEn,
    this.prioridad = Prioridad.media,
    this.categoria = Categoria.personal,
    this.etiquetas = const [],
    this.archivada = false,
  });

  factory Nota.nueva({
    required String titulo,
    required String contenido,
    Prioridad prioridad = Prioridad.media,
    Categoria categoria = Categoria.personal,
    List<String> etiquetas = const [],
  }) {
    final ahora = DateTime.now();
    return Nota(
      id: ahora.millisecondsSinceEpoch.toString(),
      titulo: titulo,
      contenido: contenido,
      creadaEn: ahora,
      modificadaEn: ahora,
      prioridad: prioridad,
      categoria: categoria,
      etiquetas: etiquetas,
    );
  }

  factory Nota.fromJson(Map<String, dynamic> json) => _$NotaFromJson(json);
  Map<String, dynamic> toJson() => _$NotaToJson(this);

  // Parseo en isolate: esta función DEBE ser top-level o static
  static List<Nota> parsearLista(String jsonString) {
    // Esta función se usará con compute()
    final List<dynamic> lista = 
        (const JsonDecoder().convert(jsonString) as List);
    return lista
        .map((item) => Nota.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
```

### Tabla de Decisión: ¿Qué tecnología usar?

```
┌────────────────────────────────────────────────────────────────────┐
│                ÁRBOL DE DECISIÓN DE ALMACENAMIENTO                 │
├───────────────────────────────┬────────────────────────────────────┤
│ ¿Qué tipo de datos?           │ Tecnología recomendada             │
├───────────────────────────────┼────────────────────────────────────┤
│ Configuración (bool, int,     │ SharedPreferences                  │
│ String, double)               │                                    │
├───────────────────────────────┼────────────────────────────────────┤
│ Documentos, notas, listas     │ path_provider + dart:io (JSON)     │
│ medianas (~1000 ítems)        │                                    │
├───────────────────────────────┼────────────────────────────────────┤
│ Datos relacionales, consultas │ sqflite / drift                    │
│ complejas                     │                                    │
├───────────────────────────────┼────────────────────────────────────┤
│ Cache de red, alta velocidad  │ Hive / Isar                        │
├───────────────────────────────┼────────────────────────────────────┤
│ Archivos multimedia           │ path_provider + bytes              │
├───────────────────────────────┼────────────────────────────────────┤
│ Sincronización en la nube     │ Firebase Firestore / Supabase      │
└───────────────────────────────┴────────────────────────────────────┘
```

---

## 8. Buenas Prácticas y Errores Comunes

### ✅ Buenas Prácticas

#### 1. Maneja siempre los errores de serialización

```dart
// ❌ Sin manejo de errores
final usuario = Usuario.fromJson(jsonDecode(respuesta.body));

// ✅ Con manejo de errores
try {
  final data = jsonDecode(respuesta.body) as Map<String, dynamic>;
  final usuario = Usuario.fromJson(data);
} on FormatException catch (e) {
  debugPrint('JSON inválido: $e');
} on TypeError catch (e) {
  debugPrint('Tipo incorrecto en JSON: $e');
}
```

#### 2. Centraliza las claves de SharedPreferences

```dart
// ❌ Claves hardcodeadas en múltiples lugares
prefs.getBool('dark_mode');        // En un archivo
prefs.setBool('dark_mode', true);  // En otro archivo

// ✅ Clase de constantes centralizada
abstract class PrefKeys {
  static const temaOscuro = 'dark_mode';
  static const idioma = 'language';
  static const tokenAuth = 'auth_token';
  // ...
}
prefs.getBool(PrefKeys.temaOscuro);
```

#### 3. Usa `compute()` para JSONs grandes

```dart
// Regla general: si el JSON > 1MB o > 1000 objetos, usa compute()
final productos = await compute(parsearProductos, jsonString);
```

#### 4. Valida antes de parsear

```dart
factory Usuario.fromJson(Map<String, dynamic> json) {
  // Validación defensiva
  if (json['id'] == null) throw FormatException('Campo id requerido');
  if (json['nombre'] is! String) throw FormatException('nombre debe ser String');
  
  return Usuario(
    id: json['id'] as int,
    nombre: json['nombre'] as String,
  );
}
```

#### 5. Patrón Repository para desacoplar el almacenamiento

```dart
// Interfaz abstracta
abstract class NotasRepository {
  Future<List<Nota>> obtenerTodas();
  Future<void> guardar(Nota nota);
  Future<void> eliminar(String id);
}

// Implementación con archivos
class NotasArchivoRepository implements NotasRepository {
  // ...implementación con path_provider
}

// Fácil de cambiar a SQLite sin afectar el resto de la app
class NotasSqliteRepository implements NotasRepository {
  // ...implementación alternativa
}
```

### ❌ Errores Comunes

```dart
// ─── ERROR 1: Olvidar await en inicialización ───────────────────
// ❌ MAL
void main() {
  SharedPreferences.getInstance(); // Sin await, sin garantía
  runApp(const MiApp());
}

// ✅ BIEN
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(const MiApp());
}

// ─── ERROR 2: Escribir archivos en el hilo de UI ─────────────────
// ❌ MAL (bloquea la UI)
onPressed: () {
  File('data.json').writeAsStringSync(json); // SÍNCRONO = BLOQUEO
}

// ✅ BIEN (no bloquea la UI)
onPressed: () async {
  await File('data.json').writeAsString(json); // ASÍNCRONO
}

// ─── ERROR 3: No manejar archivos inexistentes ────────────────────
// ❌ MAL
final contenido = await archivo.readAsString(); // Exception si no existe

// ✅ BIEN
if (await archivo.exists()) {
  final contenido = await archivo.readAsString();
}

// ─── ERROR 4: JSON anidado con cast incorrecto ───────────────────
// ❌ MAL
final ciudad = json['direccion']['ciudad']; // dynamic, peligroso

// ✅ BIEN
final dir = json['direccion'] as Map<String, dynamic>;
final ciudad = dir['ciudad'] as String;

// ─── ERROR 5: Usar SharedPreferences para objetos complejos ──────
// ❌ MAL
await prefs.setString('usuario', usuario.toString()); // toString != JSON

// ✅ BIEN
await prefs.setString('usuario', jsonEncode(usuario.toJson()));
```

### 🔧 Herramientas Útiles

| Herramienta | Uso |
|---|---|
| [quicktype.io](https://quicktype.io) | Genera modelos Dart desde JSON automáticamente |
| `json_serializable` | Generación de código en tiempo de compilación |
| `freezed` | Clases inmutables con `fromJson`/`toJson` |
| `hive` | Alternativa NoSQL super rápida a SharedPreferences |
| `sqflite` / `drift` | Base de datos SQLite para datos relacionales |
| VS Code Flutter extension | Herramienta "Paste JSON as Code" |

---

## 📖 Resumen General

```
TEMA                     PAQUETE/HERRAMIENTA       CUÁNDO USARLO
──────────────────────────────────────────────────────────────────────
Serialización básica     dart:convert              Siempre (base)
Serialización avanzada   json_serializable         Modelos complejos
Parseo en background     compute() / Isolate       JSON > 1MB
Datos clave-valor        shared_preferences        Configuración simple
Archivos locales         path_provider + dart:io   Documentos, logs
DB relacional            sqflite / drift           Datos estructurados
DB clave-valor rápida    hive / isar               Cache, alto volumen
```

---

## 📚 Referencias Oficiales

- [Flutter: JSON and serialization](https://docs.flutter.dev/data-and-backend/serialization/json)
- [Flutter: Parse JSON in the background](https://docs.flutter.dev/cookbook/networking/background-parsing)
- [Flutter: Store key-value data on disk](https://docs.flutter.dev/cookbook/persistence/key-value)
- [Flutter: Read and write files](https://docs.flutter.dev/cookbook/persistence/reading-writing-files)
- [pub.dev: shared_preferences](https://pub.dev/packages/shared_preferences)
- [pub.dev: path_provider](https://pub.dev/packages/path_provider)
- [pub.dev: json_serializable](https://pub.dev/packages/json_serializable)

---

*Tutorial creado para el curso de Desarrollo de Aplicaciones Móviles con Flutter.*  
*Versión 1.0 — Marzo 2026*
