import '../models/jogo.dart';

/// Coleção de partida oferecida no estado vazio, para o app poder ser
/// explorado sem cadastrar tudo à mão. A ordem em que aparecem é a ordem em
/// que estão escritos aqui: cada um é "adicionado" um minuto antes do anterior.
List<Jogo> jogosDeExemplo() {
  final agora = DateTime.now();
  var posicao = 0;

  Jogo j(
    String titulo,
    Plataforma plataforma,
    String genero,
    StatusJogo status, {
    int nota = 0,
    int horas = 0,
    String observacoes = '',
  }) => Jogo.novo(
    titulo: titulo,
    plataforma: plataforma,
    genero: genero,
    status: status,
    nota: nota,
    horas: horas,
    observacoes: observacoes,
    adicionadoEm: agora.subtract(Duration(minutes: posicao++)),
  );

  return [
    j(
      'O Hobbit',
      Plataforma.pc,
      'Aventura',
      StatusJogo.zerado,
      nota: 5,
      horas: 46,
      observacoes: 'Leitura concluída. Gostei da aventura e dos personagens.',
    ),
    j(
      'O Senhor dos Anéis',
      Plataforma.playstation,
      'Fantasia',
      StatusJogo.jogando,
      nota: 5,
      horas: 78,
      observacoes: 'Leitura em andamento. Quero terminar o primeiro volume.',
    ),
    j(
      'O Pequeno Príncipe',
      Plataforma.nintendo,
      'Poesia',
      StatusJogo.zerado,
      nota: 5,
      horas: 14,
    ),
    j(
      '1984',
      Plataforma.pc,
      'Ficção',
      StatusJogo.jogando,
      nota: 4,
      horas: 31,
      observacoes: 'Lendo alguns capítulos por semana.',
    ),
    j(
      'Duna',
      Plataforma.pc,
      'Fantasia',
      StatusJogo.queroJogar,
      observacoes: 'Recomendação de um amigo do grupo.',
    ),
    j(
      'Drácula',
      Plataforma.playstation,
      'Terror',
      StatusJogo.queroJogar,
    ),
    j(
      'Sapiens',
      Plataforma.mobile,
      'Não ficção',
      StatusJogo.abandonado,
      nota: 3,
      horas: 9,
      observacoes: 'Interrompi a leitura e pretendo retomar depois.',
    ),
    j(
      'A Vida de um Leitor',
      Plataforma.xbox,
      'Biografia',
      StatusJogo.jogando,
      nota: 3,
      horas: 120,
    ),
  ];
}
