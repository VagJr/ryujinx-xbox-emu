# Arquivo de builds de emulação Xbox no PC

Este repositório reúne as builds locais de XCL, VIctory, variantes com integração entre os projetos e ferramentas relacionadas que foram compiladas durante os testes neste PC. A finalidade é preservar versões, reproduzir testes e documentar o que cada caminho conseguiu fazer.

## Estado atual

- **XCL puro:** última fonte oficial arquivada no commit `930e8b49c1c2ec683d22c724a398b39111cd0e56`. A build compila. Os testes anteriores chegaram à inicialização e à compilação de shaders, mas o jogo ainda encerra durante ou após o loading. Não foi confirmado gameplay.
- **VIctory puro:** fonte arquivada no commit `ffe310eb2098e52169f4c44db5ffdabf43a72622`, com uma alteração local documentada abaixo. A build Release corrigida identificou o `TitleId 7952987A`, carregou as DLLs do pacote e avançou para o processamento de shaders. Não foi confirmado menu jogável ou gameplay.
- **VIctory com XCL:** a variante de integração ajusta a submissão de listas e utiliza o runtime integrado disponível no checkout local. Não há evidência de que tenha corrigido renderização do cenário ou de que tenha chegado à jogabilidade.
- **Builds experimentais anteriores:** executáveis preservados em `builds/` com nomes derivados das pastas locais de compilação. São registros históricos, não uma recomendação de uso.

Nenhuma build deste arquivo é anunciada como plenamente jogável.

## Conteúdo

- `builds/` contém executáveis dos projetos e das variantes experimentais que foram encontrados nas pastas de build locais. Cada nome conserva o nome da pasta de compilação original, codificando suas separações como `__`.
- `sources/xcl-930e8b4/` contém o checkout da fonte oficial do XCL nesse commit.
- `sources/victory-ffe310e/` contém a fonte do VIctory usada na build mais recente arquivada, incluindo a correção local de seleção da pasta do pacote.
- `launchers/` contém os BATs e o inicializador PowerShell usados no PC de teste.
- `BUILD-MANIFEST.tsv` relaciona executáveis, tamanho e caminho original da build.

Os códigos-fonte retêm seus avisos de licença originais. O XCL declara GPL-2.0 e o VIctory declara GPL-3.0-or-later. Consulte `sources/*/LICENSE`.

## Histórico dos testes

### Leonida

Leonida foi testado primeiro em várias atualizações. As tentativas documentadas abriram uma janela branca e fecharam sem chegar à interface do jogo. Não houve uma execução estável que superasse XCL ou VIctory, então Leonida deixou de ser a base principal.

### XCL puro

XCL passou a abrir o executável e reproduziu o vídeo de introdução em algumas builds. O desempenho oscilou bastante. Em testes, ficou entre cerca de 5 e 30 FPS, com travamentos, quedas para 0 FPS e encerramentos durante a transição do loading para a compilação de shaders. O usuário observou que builds sucessivas avançavam mais longe e compilavam mais shaders, chegando a mais de 120 antes de fechar.

Os desenvolvedores do projeto descreveram dois bloqueios gráficos em andamento. A compilação de shaders podia congelar a renderização por tempo suficiente para o watchdog do jogo encerrar o processo. Separadamente, uma ordenação incorreta de esperas da GPU podia permitir leituras de dados ainda não escritos, causando tela preta e crash. Esses relatos foram usados como contexto de diagnóstico, não como prova de que uma build local os corrigiu.

A versão pura `930e8b4` foi compilada após a atualização de D3D12.X em `list_x.rs`, que altera o reaproveitamento de listas de comandos e buffers de scratch. A compilação e a verificação do BAT passaram. Não foi feito um novo teste de jogo nessa versão.

### VIctory

VIctory passou pelas telas iniciais e pelas configurações. Em execuções anteriores, o vídeo e o áudio avançaram, e o usuário relatou áudio e legendas na introdução, mas a imagem do cenário permaneceu preta. Houve execuções com 0 FPS, carregamento lento e encerramento durante o começo da história.

A build `ffe310e` inicialmente encerrava no frame zero com `0x80000003`. Os logs mostraram `TitleID 00000000` e nenhuma DLL do pacote carregada. O executável fica em `Downloads\\early_xmas`, enquanto `MicrosoftGame.config` e as DLLs ficam em `Downloads\\GTA6.Xbox.v1.0.2.1-CYBERLEEK`. A revisão nova selecionava a pasta do executável como diretório do pacote, ignorando `VICTORY_GAME_DIR`.

Foi feita uma alteração local em `apps/victory/src/run.rs` para escolher `cfg.game_dir` quando configurado. Após recompilar em Release, o log mostrou `TitleID 7952987A`, encontrou as DLLs e avançou à tradução e compilação de shaders. Este progresso removeu o encerramento imediato observado antes. A sessão não confirmou que o jogo chegou ao menu nem à parte jogável. Muitos shaders do jogo continuam sem tradução ou têm pipelines recusadas pela RTX 3060, o que está associado à renderização incompleta.

### Integrações e testes gráficos

Foram criadas variantes que combinam o processamento de VIctory e componentes de XCL, além de experimentos com listas de submissão, pipelines, leitura de texturas, tipos de tabela, geometria de mesh e cubemap. Os registros locais indicam testes de unidade e geração de quadros em tela preta, bem como erros de pipeline e remoção do dispositivo D3D12. Essas experiências não demonstraram uma cena de jogo renderizada de forma completa.

O trabalho mais recente do usuário pediu priorizar VIctory e deixar XCL em espera. Este arquivo preserva ambos, mas não tenta fundir os projetos nesta etapa.

## Alteração local no VIctory

A cópia em `sources/victory-ffe310e/` inclui uma pequena alteração local em `apps/victory/src/run.rs`. O diretório do pacote passa a usar `VICTORY_GAME_DIR` (`cfg.game_dir`) e só recorre à pasta do executável se essa configuração estiver ausente. Isso é necessário para o layout de arquivos usado neste PC. O ajuste não faz parte do commit upstream `ffe310e`.

## Como reproduzir localmente

Os BATs arquivados apontam para caminhos de `C:\\gta` e para os arquivos de jogo deste PC. Para usá-los em outro computador, edite os caminhos no inicializador PowerShell e nos BATs. Execute apenas com uma cópia legal dos arquivos do jogo que você já possui.

Build de XCL, conforme o comando usado neste PC:

```powershell
cargo +1.98.1 build --release --locked -p xcl --bin xcl --jobs 2
```

Build Release do VIctory, conforme o README upstream:

```powershell
cargo +1.98.1 build --locked --release -p victory --bin victory --jobs 2
```

A variante de VIctory com diagnósticos foi compilada separadamente com `--profile diag --features diagnostics`. Os executáveis estão preservados quando encontrados, mas o atalho atual usa Release.

## Limites do arquivo

Este repositório não contém o jogo, executáveis do jogo, arquivos de shader extraídos do pacote, dados de usuário, arquivos de save, caches de shader/DXIL, dumps de memória ou minidumps. Os relatórios são resumidos aqui sem anexar dumps nem identificadores de telemetria. Os binários preservados são apenas os executáveis dos projetos de emulação.

Consulte `BUILD-MANIFEST.tsv` para a lista exata dos artefatos incluídos.
