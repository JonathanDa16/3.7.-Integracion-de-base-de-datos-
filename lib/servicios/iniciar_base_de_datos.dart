import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../config/firebase_config.dart';
import 'catalogo_en_memoria.dart';
import 'catalogo_firestore.dart';
import 'repositorio_catalogo.dart';

class ConexionBase {
  const ConexionBase({
    required this.repositorio,
    required this.enLinea,
    required this.mensaje,
    this.usuarioId,
  });

  final RepositorioCatalogo repositorio;

  final bool enLinea;

  final String mensaje;

  final String? usuarioId;

  factory ConexionBase.sinConexion(String mensaje) => ConexionBase(
        repositorio: CatalogoEnMemoria(),
        enLinea: false,
        mensaje: mensaje,
      );
}

Future<ConexionBase> iniciarBaseDeDatos({
  Duration limite = const Duration(seconds: 90),
}) async {
  try {
    return await _arrancar().timeout(limite);
  } on TimeoutException {
    debugPrint('[Firebase] sin respuesta en ${limite.inSeconds} s');
    return ConexionBase.sinConexion(
      'La base de datos no respondió en ${limite.inSeconds} s. '
      'Se muestran los datos en memoria.',
    );
  } catch (error) {
    debugPrint('Firebase no inicializó: $error');
    return ConexionBase.sinConexion(
      'No se pudo conectar con Firebase (${_resumen(error)}). '
      'Se muestran los datos en memoria.',
    );
  }
}

Future<ConexionBase> _arrancar() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: FirebaseConfig.actuales);
  }

  if (FirebaseConfig.usarEmulador) {
    final String host = FirebaseConfig.hostEmulador;
    FirebaseFirestore.instance.useFirestoreEmulator(
      host,
      FirebaseConfig.puertoFirestore,
    );
    await FirebaseAuth.instance.useAuthEmulator(
      host,
      FirebaseConfig.puertoAuth,
    );
    debugPrint('[Firebase] Firestore y Auth apuntando a $host '
        '(${FirebaseConfig.puertoFirestore}/${FirebaseConfig.puertoAuth})');
  }

  final UserCredential credencial =
      await FirebaseAuth.instance.signInAnonymously();
  final String? uid = credencial.user?.uid;

  if (uid == null || uid.isEmpty) {
    return ConexionBase.sinConexion(
      'Firebase no devolvió un identificador de usuario.',
    );
  }

  final CatalogoFirestore repositorio = CatalogoFirestore(usuarioId: uid);
  await repositorio.preparar(plataforma: _plataforma());

  return ConexionBase(
    repositorio: repositorio,
    enLinea: true,
    mensaje: FirebaseConfig.usarEmulador
        ? 'Cloud Firestore (emulador ${FirebaseConfig.hostEmulador})'
        : 'Cloud Firestore (${FirebaseConfig.proyecto})',
    usuarioId: uid,
  );
}

String _plataforma() {
  if (kIsWeb) return 'web';
  return defaultTargetPlatform.name;
}

String _resumen(Object error) {
  final String texto = error.toString().replaceAll('\n', ' ');
  return texto.length > 120 ? '${texto.substring(0, 120)}…' : texto;
}
