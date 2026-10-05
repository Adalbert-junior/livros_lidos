import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zerado/models/conquistas.dart';
import 'package:zerado/models/jogo.dart';
import 'package:zerado/pages/painel_page.dart';
import 'package:zerado/state/acervo.dart';
import 'package:zerado/data/repositorio.dart';
import 'package:zerado/widgets/roleta_backlog.dart';

import 'ajudante.dart';

void main() {
  setUpAll(carregarFontes);

  Future<Acervo> abrirPainel(WidgetTester tester, List<Jogo> jogos) async {
    final acervo = await montarApp(
      tester,
      jogos: jogos,
      tamanho: const Size(420, 2400),
    );
    await tester.tap(find.byTooltip('Painel e estatísticas'));
    await tester.pumpAndSettle();
    return acervo;
  }

  testWidgets('o painel mostra os números da coleção', (tester) async {
    await abrirPainel(tester, [
      jogoDe('A', status: StatusJogo.zerado, nota: 5, horas: 10),
      jogoDe('B', status: StatusJogo.zerado, nota: 3, horas: 20),
      jogoDe('C'),
    ]);

    expect(find.text('30 h'), findsWidgets); // total e barra da plataforma
    expect(find.text('4,0'), findsOneWidget); // nota média
    expect(find.text('100%'), findsOneWidget); // 2 de 2 iniciados
  });

  testWidgets('a roleta sorteia só entre os livros "quero ler"', (
    tester,
  ) async {
    final acervo = await montarApp(
      tester,
      jogos: [
        jogoDe('Fila 1'),
        jogoDe('Lendo', status: StatusJogo.jogando, horas: 2),
      ],
      tamanho: const Size(420, 2400),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoletaBacklog(
            acervo: acervo,
            random: Random(1),
            aoAbrir: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Sortear'));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Fila 1'), findsOneWidget);
    expect(find.text('Lendo'), findsNothing);
    expect(find.text('Sortear de novo'), findsOneWidget);
  });

  testWidgets('sem livros na fila o botão da roleta fica desligado', (
    tester,
  ) async {
    final acervo = Acervo(
      RepositorioMemoria([jogoDe('X', status: StatusJogo.zerado, horas: 3)]),
    );
    await acervo.carregar();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoletaBacklog(acervo: acervo, aoAbrir: (_) {}),
        ),
      ),
    );

    final botao = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(botao.onPressed, isNull);
  });

  testWidgets('"Começar a ler" muda a situação do livro sorteado', (
    tester,
  ) async {
    final alvo = jogoDe('Único');
    final acervo = Acervo(RepositorioMemoria([alvo]));
    await acervo.carregar();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoletaBacklog(acervo: acervo, aoAbrir: (_) {}),
        ),
      ),
    );

    await tester.tap(find.text('Sortear'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.tap(find.text('Começar a ler'));
    await tester.pumpAndSettle();

    expect(acervo.porId(alvo.id)!.status, StatusJogo.jogando);
  });

  group('conquistas', () {
    test('cada selo é liberado pela condição descrita', () {
      Conquista por(String titulo) =>
          conquistas.firstWhere((c) => c.titulo == titulo);

      expect(por('Primeiro livro').liberada([]), isFalse);
      expect(por('Primeiro livro').liberada([jogoDe('A')]), isTrue);

      final dez = [for (var i = 0; i < 10; i++) jogoDe('J$i')];
      expect(por('Colecionador').liberada(dez.take(9).toList()), isFalse);
      expect(por('Colecionador').liberada(dez), isTrue);

      expect(
        por('Multiformato').liberada([
          jogoDe('A', plataforma: Plataforma.pc),
          jogoDe('B', plataforma: Plataforma.xbox),
        ]),
        isFalse,
      );
      expect(
        por('Multiformato').liberada([
          jogoDe('A', plataforma: Plataforma.pc),
          jogoDe('B', plataforma: Plataforma.xbox),
          jogoDe('C', plataforma: Plataforma.mobile),
        ]),
        isTrue,
      );

      expect(
        por('Sem vida social').liberada([
          jogoDe('A', horas: 60, status: StatusJogo.jogando),
          jogoDe('B', horas: 40, status: StatusJogo.jogando),
        ]),
        isTrue,
      );
    });
  });

  test('o resumo em texto lista os livros por situação', () {
    final jogos = [
      jogoDe('Hades', status: StatusJogo.zerado, nota: 5, horas: 30),
      jogoDe('Dune'),
    ];
    final acervo = Acervo(RepositorioMemoria());
    acervo.adicionarVarios(jogos);

    final texto = montarResumoTexto(acervo.todos, acervo.resumo);
    expect(
      texto,
      contains('2 livros · 1 lido · 30 h de leitura · nota média 5,0'),
    );
    expect(texto, contains('Lido: Hades'));
    expect(texto, contains('Quero ler: Dune'));
  });
}
