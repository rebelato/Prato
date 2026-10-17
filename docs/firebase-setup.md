# Análise com Gemini via Firebase AI Logic

Este guia cobre o que precisa ser feito fora do código para a análise real funcionar: projeto Firebase, App Check, custos e privacidade. Sem esses passos o app continua funcionando com a análise de mentira (mock) e nenhuma foto sai do aparelho.

Conferido na documentação oficial em 17/10/2026.

## Como funciona

1. O usuário tira ou escolhe a foto e toca em **Analisar prato**. Nada é enviado antes disso.
2. A foto (JPEG, até 1600 px no maior lado) vai ao Gemini pelo SDK **Firebase AI Logic**, com um schema JSON que pede só: se há comida, nome, termo de busca, preparo, peso estimado, alternativas e observação de incerteza. Nenhum percentual de confiança e nenhuma caloria.
3. A resposta é decodificada e **validada** no app (`FoodRecognition`): campos vazios, pesos fora de 1–2000 g, repetidos e listas longas são descartados.
4. Cada alimento é ligado ao catálogo local só quando o nome bate e o preparo não conflita. O resto aparece na revisão em **Confirme estes alimentos**, para o usuário escolher.
5. Calorias e macros vêm sempre do catálogo, calculados em Swift. Editar o peso não chama o Gemini de novo.

Não há backend próprio, Cloud Functions, Firestore nem login. A chave do Gemini nunca fica no app: o Firebase AI Logic faz a ponte, protegido pelo App Check.

## Requisitos

- **Xcode 26.2 ou mais novo.** O Firebase Apple SDK 13 exige Swift 6.2.
- Firebase Apple SDK **13.0.0+**, produto **`FirebaseAILogic`**. O antigo produto `FirebaseAI` foi removido na 13.0.0.
- Uma conta Apple Developer com o time configurado em *Signing & Capabilities*, para o App Attest nos builds de Release.

## 1. Projeto e app no Firebase

1. Crie um projeto no [console do Firebase](https://console.firebase.google.com).
2. Adicione um app **iOS** com o bundle id `com.rebelato.prato`.
3. Baixe o `GoogleService-Info.plist` e coloque em `Prato/GoogleService-Info.plist`. A pasta é sincronizada com o target, então o Xcode inclui o arquivo sozinho.
   - O arquivo está no `.gitignore`: cada pessoa usa o seu. Ele não é segredo, mas fora do repositório fica mais fácil ter projetos separados de desenvolvimento e produção.
4. Em **Firebase AI Logic**, clique em *Get started* e escolha o provedor **Gemini Developer API**.

Ao abrir o app, `FirebaseBootstrap.configure()` encontra o arquivo, configura o App Check e passa a usar o `GeminiMealAnalyzer`.

## 2. App Check

O App Check garante que só o seu app, num aparelho real, chame o Gemini pelo seu projeto. **A partir de 2 de novembro de 2026 a aplicação (enforcement) do App Check é obrigatória para usar o Firebase AI Logic.**

### Desenvolvimento (Simulador e builds de Debug)

O código usa o provedor de debug **só em builds de Debug** (`#if DEBUG` em `FirebaseBootstrap.swift`).

1. Rode o app em Debug e procure no console do Xcode a linha com `App Check debug token`.
2. No console do Firebase: **Security › App Check › Apps**, abra o app iOS, **Manage debug tokens** e cadastre o token.
3. Nunca versione esse token. Cada desenvolvedor e cada máquina de CI cadastra o seu.

### Produção (Release)

Builds de Release usam o **App Attest** (`AppAttestProvider`).

1. No Xcode, o target já aponta `CODE_SIGN_ENTITLEMENTS = Prato.entitlements` na configuração Release, com `com.apple.developer.devicecheck.appattest-environment = production`. Confira se a capability **App Attest** aparece em *Signing & Capabilities* e se o provisioning profile a inclui.
2. No console: **Security › App Check › Apps**, registre o app com o provedor **App Attest**, informando o Team ID se for pedido.
3. Opcional: ajuste o TTL do token (padrão 1 hora; entre 30 min e 7 dias).

### Ativar a aplicação

1. **Security › App Check › APIs**, linha **Firebase AI Logic**, *Set up* → **Enforced**.
2. Antes de ativar, acompanhe as métricas por alguns dias para ver se as requisições chegam verificadas.
   - O enforcement vale para o Firebase AI Logic **no projeto inteiro**. Se o projeto tiver outros apps que usam o AI Logic, registre todos no App Check antes, ou eles passam a ser bloqueados.
3. **Proteção contra replay** (opcional): exige um token novo por requisição, com alguma latência extra. Para usar, ative no console e passe `useLimitedUseAppCheckTokens: true` em `GeminiMealAnalyzer.Configuration`.

## 3. Modelo

O identificador fica centralizado em `GeminiMealAnalyzer.Configuration.defaultModelName`:

```swift
public static let defaultModelName = "gemini-3.5-flash"
```

Motivos da escolha:

- é **estável**, e a página de modelos não o marca como de "disponibilidade de curto prazo" (aposentadoria não antes de 19/05/2027);
- é multimodal e serve para saída estruturada;
- na Gemini Developer API não exige o plano Blaze.

Os modelos Gemini 2.5 foram desativados para projetos novos e não devem ser usados.

Para trocar sem mexer no código, adicione a chave `PratoGeminiModel` (String) ao Info.plist do app. Antes de trocar, confira na [página de modelos](https://firebase.google.com/docs/ai-logic/models) se o novo modelo é estável e aceita imagem e saída estruturada.

## 4. Custos, cotas e limites

- **Plano Spark (gratuito):** acesso limitado a alguns modelos pela Gemini Developer API, sem cartão. Serve para desenvolver.
- **Plano Blaze (pago):** cobrança por uso de todas as chamadas à Gemini Developer API do projeto.
- **Limite por usuário:** o padrão é **100 requisições por minuto por usuário**. Para mudar: Cloud console › API *Firebase AI Logic* › *Manage* › *Quotas & System Limits*, filtre pela cota de *generate content* e edite.
- **Alertas de orçamento não bloqueiam gastos.** Eles só avisam. Para limitar, use também os limites de gasto (*spend caps*) e as cotas acima. O orçamento vale para a API no projeto inteiro, não só para o app.
- O próprio app ajuda a conter custos: só envia depois do toque em "Analisar prato", nunca envia duas vezes a mesma foto em paralelo, cancela ao sair da tela e não chama o modelo ao editar porções.

## 5. Privacidade

Pontos para a política de privacidade e para a seção de privacidade da App Store:

- **A foto do prato é enviada ao Google (Gemini)** para identificar os alimentos. O app avisa isso na tela "Ficou tudo visível?" antes do envio.
- **Plano gratuito × pago:** nos *Unpaid Services* da Gemini API, o Google pode usar o conteúdo enviado e as respostas para melhorar seus produtos, inclusive com revisão humana, e pede que não se envie informação pessoal ou sensível. Nos *Paid Services* o conteúdo não é usado para isso. **Use o plano pago (Blaze) antes de publicar**: fotos de refeições podem revelar informação pessoal. Para usuários no EEE, na Suíça e no Reino Unido, só os serviços pagos são permitidos. Veja os [termos adicionais da Gemini API](https://ai.google.dev/terms).
- **O Prato não guarda fotos na nuvem.** Foto e histórico ficam no aparelho, em SwiftData.
- **Nada da foto ou da resposta vai para logs.** Os logs do app registram só eventos de configuração.
- Na App Store, declare **Photos or Videos** como dado coletado e compartilhado com terceiro (Google) para *App Functionality*, não vinculado à identidade nem usado para rastreamento. O diário alimentar fica só no aparelho, então não é dado coletado.

## 6. Testar sem consumir a API

- **Sem `GoogleService-Info.plist`:** o app usa o mock automaticamente. A tela de conferência não mostra o aviso de envio.
- **Com o Firebase configurado:** em *Edit Scheme › Run › Arguments*, adicione `-PratoMockAnalysis YES` para forçar o mock.
- **Simulador:** sem câmera, o botão de foto usa uma foto de exemplo desenhada.
- **Testes:** os alvos de teste nunca chamam a rede. `FoodRecognitionTests` cobre decodificação, validação e correspondência com respostas de exemplo.

## 7. Limitações conhecidas

- O catálogo tem 12 alimentos com **valores de demonstração**, marcados como tal no app e gravados com essa origem em cada item. Antes de publicar, troque por uma base com fonte identificada (por exemplo, a TACO, depois de conferir as condições de uso).
- Com um catálogo pequeno, muitos alimentos vão cair em **Confirme estes alimentos**. Isso é intencional: o app pergunta em vez de associar a um alimento diferente.
- A integração foi testada em 17/10/2026 com um projeto Firebase real (provedor Gemini Developer API, token de debug do App Check), num build de Debug. O caminho de Release com App Attest e o enforcement ligado ainda não foram exercitados.
