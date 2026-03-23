/// Modelo de Usuario con serialización manual
class Usuario {
  final int id;
  final String nombre;
  final String correo;
  final int edad;
  final bool activo;
  final Direccion direccion;
  final List<String> habilidades;
  final String? profesion; // Nuevo campo opcional
  final int? experiencia; // Nuevo campo opcional para años de experiencia

  // Constructor constante para mejor rendimiento
  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.edad,
    required this.activo,
    required this.direccion,
    required this.habilidades,
    this.profesion, // Inicialización del nuevo campo
    this.experiencia, // Inicialización del nuevo camp
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
      profesion: json['profesion'] as String?, // Lectura del nuevo campo
      experiencia: json['experiencia'] as int?, // Lectura del nuevo campo
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
      if (profesion != null) 'profesion': profesion, // Solo se incluye si no es null
      if (experiencia != null) 'experiencia': experiencia, // Solo se incluye si no es null
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
    String? profesion, // Nuevo campo en copyWith
    int? experiencia, // Nuevo campo en copyWith
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      edad: edad ?? this.edad,
      activo: activo ?? this.activo,
      direccion: direccion ?? this.direccion,
      habilidades: habilidades ?? this.habilidades,
      profesion: profesion ?? this.profesion, // Manejo del nuevo campo
      experiencia: experiencia ?? this.experiencia, // Manejo del nuevo campo
    );
  }
}

/// Modelo de Dirección anidado
class Direccion {
  final String calle;
  final String ciudad;

  const Direccion({
    required this.calle, 
    required this.ciudad
  });

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