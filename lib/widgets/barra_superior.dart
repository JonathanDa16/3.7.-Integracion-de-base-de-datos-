import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../tema/app_theme.dart';

class BarraSuperior extends StatelessWidget {
  const BarraSuperior({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Icon(
          CupertinoIcons.film,
          color: Paleta.acento,
          size: 22,
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'CineCatálogo',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: Paleta.texto,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('No tienes avisos nuevos.')),
              );
          },
          tooltip: 'Avisos',
          icon: const Icon(
            CupertinoIcons.bell,
            size: 21,
            color: Paleta.textoSuave,
          ),
          splashRadius: 22,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 34, height: 34),
        ),
      ],
    );
  }
}
