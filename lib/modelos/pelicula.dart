import '../config/api_config.dart';
import 'generos_tmdb.dart';

class Pelicula {
  const Pelicula({
    required this.id,
    required this.titulo,
    this.anio,
    required this.genero,
    required this.calificacion,
    this.duracionMin,
    required this.sinopsis,
    required this.poster,
    this.destacada = false,
  });

  final int id;

  final String titulo;

  final int? anio;

  final String genero;

  final double calificacion;

  final int? duracionMin;

  final String sinopsis;

  final String poster;

  final bool destacada;

  bool get posterRemoto => poster.startsWith('http');

  String get anioTexto => anio == null ? 'Próximamente' : '$anio';

  String? get duracionTexto {
    final int? minutos = duracionMin;
    if (minutos == null || minutos <= 0) return null;
    final int horas = minutos ~/ 60;
    final int resto = minutos % 60;
    if (horas == 0) return '$resto min';
    if (resto == 0) return '$horas h';
    return '$horas h $resto min';
  }

  String get textoBusqueda => '$titulo $genero ${anio ?? ''}'.toLowerCase();

  factory Pelicula.desdeTmdb(Map<String, dynamic> json) {
    final String titulo = _texto(json['title']) ??
        _texto(json['original_title']) ??
        'Título sin nombre';

    final List<int> ids = <int>[
      if (json['genre_ids'] is List)
        for (final dynamic id in json['genre_ids'] as List<dynamic>)
          if (id is int) id,
    ];

    return Pelicula(
      id: json['id'] is int ? json['id'] as int : 0,
      titulo: titulo,
      anio: _anioDe(_texto(json['release_date'])),
      genero: nombreDelGenero(ids),
      calificacion: _calificacion(json['vote_average']),
      duracionMin: null,
      sinopsis: _texto(json['overview']) ??
          'TMDB todavía no tiene la sinopsis de esta película en español.',
      poster: ApiConfig.urlPoster(_texto(json['poster_path'])) ?? '',
      destacada: false,
    );
  }

  factory Pelicula.fromJson(Map<String, dynamic> json) {
    return Pelicula(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      anio: json['anio'] is int ? json['anio'] as int : null,
      genero: json['genero'] as String,
      calificacion: (json['calificacion'] as num).toDouble(),
      duracionMin:
          json['duracionMin'] is int ? json['duracionMin'] as int : null,
      sinopsis: json['sinopsis'] as String,
      poster: json['poster'] as String,
      destacada: (json['destacada'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'titulo': titulo,
        'anio': anio,
        'genero': genero,
        'calificacion': calificacion,
        'duracionMin': duracionMin,
        'sinopsis': sinopsis,
        'poster': poster,
        'destacada': destacada,
      };

  Pelicula comoDestacada(bool valor) => Pelicula(
        id: id,
        titulo: titulo,
        anio: anio,
        genero: genero,
        calificacion: calificacion,
        duracionMin: duracionMin,
        sinopsis: sinopsis,
        poster: poster,
        destacada: valor,
      );

  static String? _texto(Object? valor) {
    if (valor is! String) return null;
    final String limpio = valor.trim();
    return limpio.isEmpty ? null : limpio;
  }

  static int? _anioDe(String? fecha) {
    if (fecha == null || fecha.length < 4) return null;
    final int? anio = int.tryParse(fecha.substring(0, 4));
    if (anio == null || anio < 1900) return null;
    return anio;
  }

  static double _calificacion(Object? valor) {
    if (valor is! num) return 0;
    final double calificacion = valor.toDouble();
    if (calificacion.isNaN) return 0;
    return calificacion.clamp(0, 10).toDouble();
  }
}
