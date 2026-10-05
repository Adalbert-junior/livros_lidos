import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zerado/models/jogo.dart';
import 'package:zerado/widgets/jogo_card.dart';

import 'ajudante.dart';

Finder campo(String rotulo) => find.widgetWithText(TextFormField, rotulo);

void main() {
  setUpAll(carregarFontes);

  // Tela alta para o formulário inteiro ficar construído de uma vez.
  const tela = Size(420, 1500);

  group('validação', () {
    testWidgets('título só com espaços é rejeitado e a tela continua aberta', (
      tester,
    ) async {
      final acervo = await montarApp(
        tester,
        jogos: [jogoDe('Alpha')],
        tamanho: tela,
      );

      await tester.tap(find.text('Novo livro'));
      await tester.pumpAndSettle();
      await tester.enterText(campo('Título do livro'), '     ');
      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();

      expect(find.text('Informe o título'), findsOneWidget);
      expect(find.text('Novo livro'), findsWidgets); // ainda no formulário
      expect(acervo.todos.length, 1);
    });

    testWidgets('o erro do título some assim que ele é corrigido', (
      tester,
    ) async {
      await montarApp(tester, tamanho: tela);

      await tester.tap(find.text('Cadastrar livro'));
      await tester.pumpAndSettle();
      await tester.enterText(campo('Título do livro'), '  ');
      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();
      expect(find.text('Informe o título'), findsOneWidget);

      await tester.enterText(campo('Título do livro'), 'Duna');
      await tester.pumpAndSettle();
      expect(find.text('Informe o título'), findsNothing);
    });

    testWidgets('mensagem longa de horas aparece inteira, sem corte', (
      tester,
    ) async {
      await montarApp(tester, tamanho: const Size(390, 1500));

      await tester.tap(find.text('Cadastrar livro'));
      await tester.pumpAndSettle();
      await tester.enterText(campo('Título do livro'), 'Duna');
      await tester.enterText(campo('Horas de leitura'), '12');
      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();

      final texto = find.text(
        'Quem ainda não começou não tem horas. Mude a situação.',
      );
      expect(texto, findsOneWidget);
      expect(tester.widget<Text>(texto).maxLines, 3);
    });

    testWidgets('horas inválidas mostram mensagem útil', (tester) async {
      await montarApp(tester, tamanho: tela);

      await tester.tap(find.text('Cadastrar livro'));
      await tester.pumpAndSettle();
      await tester.enterText(campo('Título do livro'), 'Duna');
      await tester.enterText(campo('Horas de leitura'), '-3');
      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Digite as horas como número inteiro, de 0 a 9999'),
        findsOneWidget,
      );
    });

    testWidgets('livro lido exige ao menos uma hora', (tester) async {
      await montarApp(tester, tamanho: tela);

      await tester.tap(find.text('Cadastrar livro'));
      await tester.pumpAndSettle();
      await tester.enterText(campo('Título do livro'), 'Duna');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Lido'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();

      expect(find.text('Um livro lido tem pelo menos 1 hora'), findsOneWidget);
    });

    testWidgets('título repetido na mesma formato é barrado', (
      tester,
    ) async {
      final acervo = await montarApp(
        tester,
        jogos: [jogoDe('Doom', plataforma: Plataforma.pc)],
        tamanho: tela,
      );

      await tester.tap(find.text('Novo livro'));
      await tester.pumpAndSettle();
      await tester.enterText(campo('Título do livro'), 'doom');
      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Você já tem'), findsOneWidget);
      expect(acervo.todos.length, 1);
    });
  });

  group('criação', () {
    testWidgets('um envio válido cria o livro e a lista mostra o novo cartão', (
      tester,
    ) async {
      final acervo = await montarApp(
        tester,
        jogos: [jogoDe('Alpha')],
        tamanho: tela,
      );
      expect(find.byType(JogoCard), findsOneWidget);

      await tester.tap(find.text('Novo livro'));
      await tester.pumpAndSettle();
      await tester.enterText(campo('Título do livro'), '  Duna  ');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Lendo'));
      await tester.pumpAndSettle();
      await tester.enterText(campo('Horas de leitura'), '7');
      await tester.tap(find.byTooltip('Dar nota 4'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();

      expect(find.byType(JogoCard), findsNWidgets(2));
      expect(find.text('Duna'), findsOneWidget);
      expect(find.text('“Duna” entrou no catálogo'), findsOneWidget);

      final criado = acervo.todos.last;
      expect(criado.titulo, 'Duna'); // espaços das pontas removidos
      expect(criado.status, StatusJogo.jogando);
      expect(criado.horas, 7);
      expect(criado.nota, 4);
    });

    testWidgets('cancelar sem digitar nada volta e não altera a coleção', (
      tester,
    ) async {
      final acervo = await montarApp(
        tester,
        jogos: [jogoDe('Alpha')],
        tamanho: tela,
      );

      await tester.tap(find.text('Novo livro'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.byType(JogoCard), findsOneWidget);
      expect(acervo.todos.length, 1);
    });

    testWidgets(
      'cancelar depois de digitar pergunta e, ao descartar, não salva',
      (tester) async {
        final acervo = await montarApp(
          tester,
          jogos: [jogoDe('Alpha')],
          tamanho: tela,
        );

        await tester.tap(find.text('Novo livro'));
        await tester.pumpAndSettle();
        await tester.enterText(campo('Título do livro'), 'Rascunho');
        await tester.tap(find.widgetWithText(OutlinedButton, 'Cancelar'));
        await tester.pumpAndSettle();
        expect(find.text('Descartar alterações?'), findsOneWidget);

        await tester.tap(find.widgetWithText(FilledButton, 'Descartar'));
        await tester.pumpAndSettle();

        expect(find.text('Rascunho'), findsNothing);
        expect(acervo.todos.length, 1);
      },
    );
  });

  group('edição', () {
    testWidgets('abre preenchida e atualiza o mesmo item, sem duplicar', (
      tester,
    ) async {
      // Dois títulos iguais em plataformas diferentes: o id é que decide.
      final a = jogoDe('Doom', plataforma: Plataforma.pc);
      final b = jogoDe(
        'Doom',
        plataforma: Plataforma.xbox,
        horas: 4,
        status: StatusJogo.jogando,
      );
      final acervo = await montarApp(tester, jogos: [a, b], tamanho: tela);

      // Abre o Doom do Audiolivro pelo detalhe.
      await tester.tap(find.text('Audiolivro · Ação'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Editar livro'));
      await tester.pumpAndSettle();

      expect(find.text('Editar livro'), findsWidgets);
      expect(
        tester.widget<TextFormField>(campo('Título do livro')).controller!.text,
        'Doom',
      );
      expect(
        tester.widget<TextFormField>(campo('Horas de leitura')).controller!.text,
        '4',
      );

      await tester.enterText(campo('Horas de leitura'), '15');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Lido'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();

      expect(acervo.todos.length, 2);
      expect(acervo.porId(b.id)!.horas, 15);
      expect(acervo.porId(b.id)!.status, StatusJogo.zerado);
      expect(acervo.porId(b.id)!.adicionadoEm, b.adicionadoEm);
      // O outro Doom ficou intacto.
      expect(acervo.porId(a.id)!.horas, 0);
      expect(acervo.porId(a.id)!.status, StatusJogo.queroJogar);
    });

    testWidgets('editar mantendo o próprio título não conta como repetido', (
      tester,
    ) async {
      final a = jogoDe('Doom', horas: 0);
      final acervo = await montarApp(tester, jogos: [a], tamanho: tela);

      await tester.tap(find.text('Doom'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Editar livro'));
      await tester.pumpAndSettle();
      await tester.enterText(campo('Anotações (opcional)'), 'Rip and tear');
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Você já tem'), findsNothing);
      expect(acervo.porId(a.id)!.observacoes, 'Rip and tear');
    });

    testWidgets('cancelar a edição não muda o livro', (tester) async {
      final a = jogoDe('Doom');
      final acervo = await montarApp(tester, jogos: [a], tamanho: tela);

      await tester.tap(find.text('Doom'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Editar livro'));
      await tester.pumpAndSettle();
      await tester.enterText(campo('Título do livro'), 'Outro nome');
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancelar'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Descartar'));
      await tester.pumpAndSettle();

      expect(acervo.porId(a.id)!.titulo, 'Doom');
    });
  });
}
