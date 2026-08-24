# DivergIA — Aplicativo

App móvel que consome o backend do DivergIA: a pessoa insere (colando ou por
upload de documento) um texto original e a versão editada por IA, o app
mostra onde o sentido foi alterado, e oferece sugestão de reescrita fiel ao
sentido original.

O roadmap de desenvolvimento completo, dividido em fases, está em
[`README_app_divergia.md`](README_app_divergia.md). Este documento cobre
apenas o que já existe implementado e como rodar.

---

## Stack

- Flutter (canal estável) + Dart
- Riverpod (gerenciamento de estado)
- go_router (roteamento)
- Dio (cliente HTTP) com interceptor de autenticação e tratamento de erro centralizado
- flutter_secure_storage (token JWT — Keychain/Keystore, nunca `shared_preferences` puro)
- google_fonts (Sora + Inter, extraídas do protótipo Figma)
- lucide_icons_flutter (mesmo conjunto de ícones usado no Figma)
- fl_chart (painel de tendência pessoal — a partir da Fase 7)

## Arquitetura

Estrutura em camadas por feature:

```
lib
├── core
│   ├── theme      (cores, tipografia — extraídas do Figma via MCP)
│   ├── network      (Dio, interceptors de auth/erro)
│   ├── storage        (wrapper sobre flutter_secure_storage)
│   ├── router           (go_router, shell com a bottom nav)
│   └── widgets             (componentes reutilizáveis)
├── features
│   ├── auth        (login, cadastro, splash)
│   ├── analysis      (nova análise)
│   ├── rewrite          (sugestão de reescrita — Fase 5+)
│   ├── history             (histórico, tendência — Fase 2+)
│   └── profile               (perfil, configurações — Fase 6+)
└── main.dart
```

## O que já existe (Fase 0)

- Projeto Flutter (Android + iOS) criado, dependências principais instaladas
- Tema base (`AppTheme`/`AppColors`/`AppTypography`) com paleta e tipografia
  (Sora/Inter) extraídas do protótipo Figma via MCP (frames `login` e
  `Bottom-Nav`)
- Roteamento (go_router) com as rotas principais definidas: `/splash`,
  `/login`, `/signup`, `/historico`, `/perfil`, `/nova-analise` — todas
  apontando para telas placeholder (conteúdo real chega fase a fase)
- Bottom navigation bar (Histórico, Nova análise, Perfil) fiel ao frame
  "Bottom-Nav" do Figma
- Cliente HTTP (`ApiClient`) sobre Dio: `AuthInterceptor` anexa o token
  JWT via `flutter_secure_storage` e limpa a sessão em 401;
  `ErrorInterceptor` traduz toda falha para uma `ApiException` tipada
  (`NetworkException`, `UnauthorizedException`, `ForbiddenException`,
  `NotFoundException`, `ValidationException`, `ServerException`) — nenhuma
  tela deve interpretar `DioException`/status code por conta própria
- Estrutura de pastas por feature já criada

## Variáveis de ambiente

| Variável         | Uso                              | Default                  |
|-------------------|-------------------------------------|-----------------------------|
| `API_BASE_URL`   | URL base do backend DivergIA        | `http://localhost:8080`   |

Passar via `--dart-define=API_BASE_URL=...` no `flutter run`/`flutter build`.

## Rodando o app

```bash
flutter pub get
flutter run
```

## Rodando os testes

```bash
flutter test
```

## Integração com Figma

Ver seção dedicada em [`README_app_divergia.md`](README_app_divergia.md#integração-com-figma-mcp).
Arquivo de referência:
https://www.figma.com/design/GZAUYFm09VeQScR1GRuKVE/PrototipoTelas-DIvergIA
