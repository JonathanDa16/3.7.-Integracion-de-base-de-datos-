import 'dart:async';

import '../modelos/calificacion.dart';
import '../modelos/favorito.dart';
import '../modelos/pelicula.dart';
import 'repositorio_catalogo.dart';

class CatalogoEnMemoria implements RepositorioCatalogo {
  CatalogoEnMemoria({
    this.usuarioId = 'memoria-local',
    List<Favorito> iniciales = const <Favorito>[],
    List<Calificacion> calificacionesIniciales = const <Calificacion>[],
  })  : _favoritos = <int, Favorito>{
          for (final Favorito f in iniciales) f.peliculaId: f,
        },
        _calificaciones = <int, Calificacion>{
          for (final Calificacion c in calificacionesIniciales) c.peliculaId: c,
        } {
    _avisarFavoritos();
    _avisarCalificaciones();
  }

  @override
  final String usuarioId;

  @override
  bool get enLinea => false;

  final Map<int, Favorito> _favoritos;
  final Map<int, Calificacion> _calificaciones;

  final StreamController<List<Favorito>> _controlFavoritos =
      StreamController<List<Favorito>>.broadcast();
  final StreamController<List<Calificacion>> _controlCalificaciones =
      StreamController<List<Calificacion>>.broadcast();

  @override
  Stream<List<Favorito>> favoritos() async* {
    yield _listaFavoritos();
    yield* _controlFavoritos.stream;
  }

  @override
  Stream<List<Calificacion>> calificaciones() async* {
    yield _listaCalificaciones();
    yield* _controlCalificaciones.stream;
  }

  @override
  Future<void> agregarFavorito(Pelicula pelicula) async {
    _favoritos[pelicula.id] = Favorito.desdePelicula(pelicula);
    _avisarFavoritos();
  }

  @override
  Future<void> quitarFavorito(int peliculaId) async {
    _favoritos.remove(peliculaId);
    _avisarFavoritos();
  }

  @override
  Future<void> calificar(Pelicula pelicula, int estrellas) async {
    _calificaciones[pelicula.id] = Calificacion.para(pelicula, estrellas);
    _avisarCalificaciones();
  }

  @override
  Future<void> quitarCalificacion(int peliculaId) async {
    _calificaciones.remove(peliculaId);
    _avisarCalificaciones();
  }

  @override
  Future<void> cerrar() async {
    await _controlFavoritos.close();
    await _controlCalificaciones.close();
  }

  List<Favorito> _listaFavoritos() {
    final List<Favorito> lista = _favoritos.values.toList()
      ..sort((Favorito a, Favorito b) => b.agregadoEn.compareTo(a.agregadoEn));
    return lista;
  }

  List<Calificacion> _listaCalificaciones() {
    final List<Calificacion> lista = _calificaciones.values.toList()
      ..sort(
        (Calificacion a, Calificacion b) =>
            b.actualizadoEn.compareTo(a.actualizadoEn),
      );
    return lista;
  }

  void _avisarFavoritos() {
    if (!_controlFavoritos.isClosed) _controlFavoritos.add(_listaFavoritos());
  }

  void _avisarCalificaciones() {
    if (!_controlCalificaciones.isClosed) {
      _controlCalificaciones.add(_listaCalificaciones());
    }
  }
}
