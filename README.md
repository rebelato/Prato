# Prato

Diário alimentar por foto para iOS: fotografe o prato, confira as porções e registre a refeição. Em português (pt-BR) e inglês.

## Requisitos

- Xcode 16 ou mais novo (Swift 6)
- iOS 17+

## Como rodar

Abra `Prato.xcodeproj` e rode o esquema **Prato**. O Xcode resolve as dependências do pacote local `PratoKit` sozinho.

Para testar em inglês: *Product › Scheme › Edit Scheme › Run › Options › App Language › English*.

## Estrutura

O app é fino: só `PratoApp.swift`, assets e o `InfoPlist.xcstrings`. Todo o resto vive no pacote local `PratoKit`, com um módulo por responsabilidade.

```text
Prato/                    target do app
PratoKit/
  Sources/
    DesignSystem/         cores (claro e escuro), tipografia, botões, ilustração do prato, card de macros
    MealKit/              domínio: alimentos, porções, regra de arredondamento, MealAnalyzing + mock
    HomeFeature/          tela Hoje: HomeView, HomeViewModel, HomeEvent
    ScanFeature/          fluxo de registro: câmera, conferir foto, análise, revisão e ajuste de porção
    AppFeature/           AppCoordinator, tab bar e telas provisórias
  Tests/                  Swift Testing, um alvo por módulo
```

## Arquitetura

MVVM com coordinators ([CoordinatorFramework](https://github.com/rebelato/CoordinatorFramework) 2.0):

- A **View** só desenha estado e chama o ViewModel.
- O **ViewModel** (`@MainActor @Observable`) guarda o estado da tela e nunca navega: ele emite eventos (`HomeEvent`).
- O **Coordinator** recebe os eventos e muda o `Router`, que dirige a navegação e as apresentações.

## Localização

Cada módulo com texto tem o próprio `Localizable.xcstrings`, com pt-BR como idioma base e en. As chaves são semânticas (`home.title`) e lidas por um enum `L10n` interno a cada módulo, com `bundle: .module`. O `InfoPlist.xcstrings` do app declara os dois idiomas no bundle principal, sem ele o iOS abriria o app sempre em pt-BR.
