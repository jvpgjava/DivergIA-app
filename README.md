# DivergIA — Aplicativo

App móvel (Flutter, Android e iOS) do DivergIA: a pessoa envia um texto original e uma versão editada por IA (colando ou por upload de documento), o app mostra onde o sentido, a posição ou a intensidade da mensagem foram alterados, e sugere reescritas alternativas mais fiéis ao original.

Consome o [backend do DivergIA](../DivergIA-backend) — este repositório não roda sozinho, precisa de uma instância do backend (local, homologação ou produção) para funcionar de verdade.

---

## Stack

- **Framework:** Flutter 3.44 (canal stable) / Dart 3.12
- **Gerenciamento de estado:** Riverpod (`flutter_riverpod`)
- **Roteamento:** go_router
- **Cliente HTTP:** Dio, com interceptors de autenticação e tratamento de erro central
- **Armazenamento seguro:** `flutter_secure_storage` (token JWT — nunca em `shared_preferences` puro)
- **Gráficos:** fl_chart (painel de tendência pessoal)
- **Corte de imagem:** `crop_your_image` (foto de perfil)
- **Testes:** `flutter_test` + `mocktail`

---

## Pré-requisitos

- **Flutter SDK 3.44+** instalado e no `PATH` (`flutter doctor` sem erros bloqueantes)
- **Android:**
  - Android Studio com **Android SDK 37** instalado (o projeto fixa `compileSdk = 37` — exigência do `flutter_secure_storage` — então uma instalação padrão do Flutter, que às vezes só traz o SDK 36, precisa desse componente extra pelo SDK Manager)
  - Um emulador Android ou aparelho físico com depuração USB habilitada
- **iOS** (só é possível compilar/rodar num Mac):
  - Xcode mais recente + CocoaPods (`sudo gem install cocoapods` ou via Homebrew)
  - Uma conta de desenvolvedor Apple configurada no Xcode para assinar o app (mesmo pra rodar num iPhone físico em modo debug)
  - `IPHONEOS_DEPLOYMENT_TARGET` do projeto é 13.0

Confirme o ambiente com:
```bash
flutter doctor -v
```

---

## Configuração inicial

```bash
git clone <url-do-repositorio>
cd DivergIA-app
flutter pub get
```

### Apontando para o backend

A URL do backend é injetada em tempo de build via `--dart-define=API_BASE_URL=...` (ver [`lib/core/network/api_config.dart`](lib/core/network/api_config.dart)). Sem esse parâmetro, o app aponta pro padrão `http://localhost:8080`.

| Ambiente | Valor de `API_BASE_URL` |
|---|---|
| Backend local | `http://localhost:8080` (padrão, não precisa passar `--dart-define`) |
| Homologação | `https://api-hml-divergia.jgnx.com.br` |
| Produção | `https://api-divergia.jgnx.com.br` |

> **Testando contra um backend local a partir de um dispositivo físico Android:** o "localhost" do celular é o próprio celular, não o seu PC. Depois de subir o backend localmente, rode `adb reverse tcp:8080 tcp:8080` pra encaminhar a porta do celular pra máquina de desenvolvimento.

---

## Rodando em desenvolvimento

```bash
flutter devices                 # lista emuladores/aparelhos conectados
flutter run -d <device-id>      # aponta pro localhost:8080 por padrão

# apontando pra homologação
flutter run -d <device-id> --dart-define=API_BASE_URL=https://api-hml-divergia.jgnx.com.br
```

Com `flutter run`, o terminal imprime uma URL do **Flutter DevTools** — abra no navegador pra inspecionar rebuilds, estado do Riverpod e requisições de rede (aba Network) em tempo real.

---

## Build

### Android

```bash
# APK debug (instalável direto por adb, sem precisar de assinatura de release)
flutter build apk --debug --dart-define=API_BASE_URL=https://api-hml-divergia.jgnx.com.br
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# APK release
flutter build apk --release --dart-define=API_BASE_URL=https://api-divergia.jgnx.com.br

# App Bundle release (formato exigido pela Play Store)
flutter build appbundle --release --dart-define=API_BASE_URL=https://api-divergia.jgnx.com.br
```

Saída em `build/app/outputs/flutter-apk/` (APK) ou `build/app/outputs/bundle/release/` (AAB).

> **Assinatura de release ainda não configurada:** hoje o build `--release` usa o `signingConfig` de debug ([`android/app/build.gradle.kts:34`](android/app/build.gradle.kts#L34)) — funciona pra testar localmente, mas **não deve ser usado pra publicar na Play Store**. Antes de publicar, gere uma keystore própria (`keytool -genkey -v -keystore ~/divergia-release.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias divergia`), crie um `android/key.properties` (não versionado) apontando pra ela, e configure um `signingConfig` de release em `build.gradle.kts` lendo esse arquivo — só depois disso o `--release` fica seguro pra loja.

### iOS (requer macOS)

```bash
# build de debug/desenvolvimento, direto num iPhone conectado
flutter run -d <device-id> --dart-define=API_BASE_URL=...

# build de release, sem assinatura automática de loja
flutter build ios --release --dart-define=API_BASE_URL=https://api-divergia.jgnx.com.br

# arquivo .ipa pronto pra TestFlight/App Store (abre o fluxo de assinatura do Xcode)
flutter build ipa --release --dart-define=API_BASE_URL=https://api-divergia.jgnx.com.br
```

Pra rodar num iPhone físico ou gerar o `.ipa` de fato, abra `ios/Runner.xcworkspace` no Xcode pelo menos uma vez e selecione seu **Team** de desenvolvedor em Signing & Capabilities — o `flutter build ipa` reaproveita essa configuração.

---

## Testes

```bash
flutter analyze     # lint estático — deve sempre voltar "No issues found!"
flutter test         # suíte completa (unit + widget), roda sem emulador/dispositivo
flutter test test/features/rewrite    # só uma pasta/feature
```

Todo teste roda em modo headless (não precisa de emulador rodando) e cobre unit (formatação, validação, mapeamento de resposta) e widget (telas com providers do Riverpod mockados via `ProviderScope overrides` + `mocktail`).

---

## Ícone e splash screen

Os assets de origem ficam em `assets/icon/` (`divergia-icon-light.png`, `divergia-icon-dark.png`, variantes geradas a partir deles). Depois de trocar algum desses arquivos, regenere:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

A splash do Android 12+ só pode mostrar o ícone do app num círculo sobre uma cor sólida (limitação da API do próprio Android) — por isso a splash "legada" (Android <12 e iOS) e a do Android 12+ usam configurações de imagem levemente diferentes em `pubspec.yaml` (seção `flutter_native_splash`).

---

## Estrutura do projeto

```
lib
├── core
│   ├── network      (ApiClient/Dio, interceptors, exceções tipadas)
│   ├── router        (go_router, todas as rotas do app)
│   ├── storage         (wrapper sobre flutter_secure_storage)
│   ├── theme             (cores, tipografia — tokens extraídos do Figma)
│   ├── utils               (formatação compartilhada entre telas)
│   └── widgets               (componentes reutilizáveis: ScreenBackHeader, tela de doc legal, etc.)
├── features
│   ├── auth          (login, cadastro, recuperação de senha)
│   ├── analysis        (nova análise — texto ou upload —, loading, resultado)
│   ├── rewrite           (sugestão de reescrita: 3 alternativas, aceitar/gerar mais)
│   ├── history             (minhas análises, painel de tendência)
│   └── profile               (dados da conta, foto com corte, termos, privacidade)
└── main.dart
```

Cada feature segue `data` (API + modelos de resposta) → `domain` (modelo de negócio, quando diverge da resposta bruta) → `presentation` (telas, widgets, controllers Riverpod).

---

## Funcionalidades implementadas

- Cadastro, login, recuperação de senha (código por e-mail), sessão persistida via JWT
- Nova análise por texto colado ou upload de documento, com tela de progresso
- Resultado da análise: pontuação, tipo e trechos de divergência comparando original x editado
- Sugestão de reescrita: 3 alternativas geradas por IA, seleção, aceitar (persistido e visível depois no histórico) ou descartar com opção de gerar mais
- Histórico de análises com busca e painel de tendência pessoal (gráfico de evolução)
- Perfil: trocar nome/e-mail/senha, foto de perfil com tela de corte, exclusão de conta
- Termos de Serviço e Política de Privacidade
- Ícone adaptativo e splash screen (modo claro/escuro)

---

## Outro documento neste repositório

[`README_app_divergia.md`](README_app_divergia.md) é o roadmap original usado para guiar o desenvolvimento fase a fase — histórico de decisão de arquitetura, não um guia de uso. Todas as fases nele descritas já foram concluídas; para instruções de uso do dia a dia, use este README.
