# Prato

Diário alimentar por foto para iOS: fotografe o prato, confira as porções e registre a refeição. Em português (pt-BR) e inglês.

## Requisitos

- Xcode 26.2 ou mais novo (o Firebase Apple SDK 13 exige Swift 6.2)
- iOS 17+

## Como rodar

Abra `Prato.xcodeproj` e rode o esquema **Prato**. O Xcode resolve as dependências do pacote local `PratoKit` sozinho.

A análise das fotos usa o Gemini pelo Firebase AI Logic. Sem o `GoogleService-Info.plist` o app usa uma análise de mentira e nada sai do aparelho; veja [docs/firebase-setup.md](docs/firebase-setup.md) para configurar o Firebase e o App Check.

Para testar em inglês: *Product › Scheme › Edit Scheme › Run › Options › App Language › English*.

## Estrutura

O app é fino: só `PratoApp.swift`, assets e o `InfoPlist.xcstrings`. Todo o resto vive no pacote local `PratoKit`, com um módulo por responsabilidade.

```text
Prato/                    target do app
PratoKit/
  Sources/
    DesignSystem/         cores (claro e escuro), tipografia, botões, ilustração do prato, card de macros
    MealKit/              domínio: alimentos, porções, regra de arredondamento, MealAnalyzing + mock
    MealStore/            diário em SwiftData (SwiftDataMealStore), com cópia dos valores de cada alimento
    FoodRecognition/      resposta do Gemini: decodificação, validação e ligação com o catálogo (sem Firebase)
    GeminiAnalysis/       GeminiMealAnalyzer, schema, Firebase e App Check
    HomeFeature/          tela Hoje: HomeView, HomeViewModel, HomeEvent
    HistoryFeature/       tela Histórico: semana, dia selecionado, totais e média
    ScanFeature/          fluxo de registro: câmera, conferir foto, análise, revisão e ajuste de porção
    AppFeature/           AppCoordinator e tab bar
  Tests/                  Swift Testing, um alvo por módulo
```

## Arquitetura

MVVM com coordinators ([CoordinatorFramework](https://github.com/rebelato/CoordinatorFramework) 2.0):

- A **View** só desenha estado e chama o ViewModel.
- O **ViewModel** (`@MainActor @Observable`) guarda o estado da tela e nunca navega: ele emite eventos (`HomeEvent`).
- O **Coordinator** recebe os eventos e muda o `Router`, que dirige a navegação e as apresentações.

## Localização

Cada módulo com texto tem o próprio `Localizable.xcstrings`, com pt-BR como idioma base e en. As chaves são semânticas (`home.title`) e lidas por um enum `L10n` interno a cada módulo, com `bundle: .module`. O `InfoPlist.xcstrings` do app declara os dois idiomas no bundle principal, sem ele o iOS abriria o app sempre em pt-BR.
