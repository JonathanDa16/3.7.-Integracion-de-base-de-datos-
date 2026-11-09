import '../modelos/calificacion.dart';
import '../modelos/favorito.dart';
import '../modelos/pelicula.dart';

abstract class RepositorioCatalogo {
  String get usuarioId;

  bool get enLinea;

  Stream<List<Favorito>> favoritos();

  Stream<List<Calificacion>> calificaciones();

  Future<void> agregarFavorito(Pelicula pelicula);

  Future<void> quitarFavorito(int peliculaId);

  Future<void> calificar(Pelicula pelicula, int estrellas);

  Future<void> quitarCalificacion(int peliculaId);

  Future<void> cerrar();
}
