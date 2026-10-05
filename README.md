# Livros Lidos

Backlog de livros pessoal, feito em Flutter. Você cadastra os livros que quer ler,
está lendo ou já leu, dá nota, anota o que achou e acompanha tudo num painel.

Trabalho final de **Desenvolvimento Mobile I** (Unilavras, 2º semestre de 2026).

**Feito por:** Adalbert.

**Versão online:** <https://lido-tau.vercel.app>

## O que o app faz

- **Catálogo** em lista (celular) ou grade de duas colunas (tela larga), com busca por
  título, gênero ou formato, filtro por situação e quatro ordenações.
- **Estado vazio** com ação clara: cadastrar o primeiro livro ou carregar uma coleção de exemplo.
- **Detalhe** do livro tocado, com troca rápida de situação.
- **Formulário único** para cadastrar e editar, com validação (título obrigatório, sem
  título repetido na mesma formato, horas coerentes com a situação). Cancelar não altera nada.
- **Excluir** com confirmação no detalhe, ou deslizando o cartão, sempre com "Desfazer".

### Além do que o enunciado pede

- **Painel** com total de livros, horas, nota média, taxa de conclusão, rosca por situação e
  horas por formato.
- **Roleta do backlog:** sorteia o próximo livro entre os marcados como "Quero ler".
- **Conquistas** liberadas conforme a coleção cresce (recalculadas, nunca gravadas).
- **Capas geradas** a partir do título: mesma entrada, mesma capa, sem baixar imagem nenhuma.
- **Persistência local:** os dados ficam no aparelho e sobrevivem ao fechar o app.
- **Tema escuro, claro ou do sistema**, e versão web instalável (PWA).
- **Copiar resumo** do backlog para colar numa conversa.

Sincronização entre aparelhos, login e backend ficam como evolução para o Mobile II.

## Como rodar

Precisa do Flutter 3.47 ou mais novo (Dart 3.13). Não há chave de API nem serviço externo.

```bash
flutter pub get
flutter test
flutter run
```

APK de release:

```bash
flutter build apk --release
# saída: build/app/outputs/flutter-apk/app-release.apk
```

Versão web:

```bash
flutter build web --release
# saída: build/web
```

## Como o código está organizado

```
lib/
  models/     Livro (com id), enums de situação/formato e as conquistas
  data/       Repositorio (interface), versão em memória e versão local, exemplos
  state/      Acervo (coleção + busca/filtro/ordem) e ModoTema
  pages/      lista, detalhe, formulário, painel e os fluxos de navegação
  widgets/    JogoCard, EstadoVazio, CapaJogo, NotaEstrelas, StatusTag, rosca...
  theme/      paleta clara/escura e temas dos componentes
test/         modelo, estado, telas, formulário, painel e acessibilidade
```

Algumas decisões:

- **A identidade de um livro é o `id`, não o título.** Editar troca o item de mesmo id
  (`indexWhere` + substituição), então dois livros com o mesmo nome em formatos diferentes
  nunca se confundem e a edição nunca duplica.
- **Um formulário só** serve para criar e editar: recebe o livro (ou não) e devolve o resultado
  pelo `pop`. Quem chamou decide o que fazer, e cancelar devolve `null`.
- **`EstadoVazio` e `JogoCard` são reutilizados**: o primeiro aparece no catálogo vazio e na busca
  sem resultado; o segundo na lista e na roleta do painel.
- **O estado é um `ChangeNotifier`** entregue por um `InheritedNotifier`, sem pacote de gerência
  de estado. O app é pequeno e isso deixa o fluxo fácil de acompanhar.

## Acessibilidade

Rótulos persistentes em todos os campos, tooltip em todo botão só com ícone, cartões lidos
como um botão com descrição completa ("1984, Físico, Lendo, nota 4 de 5, 31 horas de leitura"),
áreas de toque de pelo menos 48 px, informação nunca só por cor (ícone e texto repetem a
situação) e animações reduzidas quando o sistema pede. Os testes conferem as diretrizes de
área de toque, rótulo e contraste do Flutter nos dois temas, e verificam a razão de contraste
das paletas.

## Fontes e recursos externos

- Documentação oficial do Flutter e do Dart (formulários, layout, testes e acessibilidade).
- Pacotes: `shared_preferences`, `flutter_localizations` e `cupertino_icons`.
- Fontes **Chakra Petch** e **Barlow**, sob a SIL Open Font License 1.1.
- Ícones do Material Icons.
- As capas e a logo são desenhadas em código, sem imagens de terceiros.
