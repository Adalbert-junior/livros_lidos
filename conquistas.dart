import 'package:flutter/material.dart';

import 'jogo.dart';

/// Selos que o app libera conforme a coleção cresce. Não são gravados: são
/// recalculados a partir dos jogos, então nunca ficam fora de sincronia.
class Conquista {
  const Conquista({
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.liberada,
  });

  final String titulo;
  final String descricao;
  final IconData icone;
  final bool Function(List<Jogo> jogos) liberada;
}

int _horas(List<Jogo> jogos) => jogos.fold(0, (soma, j) => soma + j.horas);

final conquistas = <Conquista>[
  Conquista(
    titulo: 'Primeiro livro',
    descricao: 'Cadastre seu primeiro livro.',
    icone: Icons.save_outlined,
    liberada: (jogos) => jogos.isNotEmpty,
  ),
  Conquista(
    titulo: 'Zerou!',
    descricao: 'Termine um livro.',
    icone: Icons.flag_outlined,
    liberada: (jogos) => jogos.any((j) => j.status == StatusJogo.zerado),
  ),
  Conquista(
    titulo: 'Colecionador',
    descricao: 'Tenha 10 livros no catálogo.',
    icone: Icons.inventory_2_outlined,
    liberada: (jogos) => jogos.length >= 10,
  ),
  Conquista(
    titulo: 'Crítico',
    descricao: 'Dê nota máxima para um livro.',
    icone: Icons.star_outline,
    liberada: (jogos) => jogos.any((j) => j.nota == 5),
  ),
  Conquista(
    titulo: 'Multiformato',
    descricao: 'Tenha livros em 3 formatos diferentes.',
    icone: Icons.devices_outlined,
    liberada: (jogos) => jogos.map((j) => j.plataforma).toSet().length >= 3,
  ),
  Conquista(
    titulo: 'Sem vida social',
    descricao: 'Some 100 horas de leitura.',
    icone: Icons.timer_outlined,
    liberada: (jogos) => _horas(jogos) >= 100,
  ),
  Conquista(
    titulo: 'Persistente',
    descricao: 'Tenha 5 livros lidos.',
    icone: Icons.emoji_events_outlined,
    liberada: (jogos) =>
        jogos.where((j) => j.status == StatusJogo.zerado).length >= 5,
  ),
  Conquista(
    titulo: 'Sem julgamentos',
    descricao: 'Assuma um livro abandonado.',
    icone: Icons.sentiment_neutral_outlined,
    liberada: (jogos) => jogos.any((j) => j.status == StatusJogo.abandonado),
  ),
];
