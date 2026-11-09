import 'package:flutter/material.dart';

import 'pantallas/navegacion_principal.dart';
import 'pantallas/pantalla_arranque.dart';
import 'servicios/iniciar_base_de_datos.dart';
import 'servicios/peliculas_api.dart';
import 'tema/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CineCatalogoApp());
}

class CineCatalogoApp extends StatefulWidget {
  const CineCatalogoApp({super.key, this.api, this.conexion});

  final PeliculasApi? api;

  final ConexionBase? conexion;

  @override
  State<CineCatalogoApp> createState() => _CineCatalogoAppState();
}

class _CineCatalogoAppState extends State<CineCatalogoApp> {
  ConexionBase? _conexion;

  @override
  void initState() {
    super.initState();
    _conexion = widget.conexion;
    if (_conexion == null) _conectar();
  }

  Future<void> _conectar() async {
    final ConexionBase conexion = await iniciarBaseDeDatos();
    if (!mounted) return;
    setState(() => _conexion = conexion);
  }

  @override
  Widget build(BuildContext context) {
    final ConexionBase? conexion = _conexion;

    return MaterialApp(
      title: 'CineCatálogo',
      debugShowCheckedModeBanner: false,
      theme: construirTema(),
      home: conexion == null
          ? const PantallaArranque()
          : NavegacionPrincipal(api: widget.api, conexion: conexion),
    );
  }
}
