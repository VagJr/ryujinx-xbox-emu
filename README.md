# Ryujinx Xbox Emu

Projeto comunitário para acompanhar a compatibilidade de emuladores Xbox no PC.

Servidor Discord: https://discord.gg/z4JXVuchn3

Este repositório reúne as builds locais de XCL, VIctory, variantes com integração entre os projetos e ferramentas relacionadas que foram compiladas durante os testes neste PC. A finalidade é preservar versões, reproduzir testes e documentar o que cada caminho conseguiu fazer.

## Estado atual

- **XCL puro:** fonte oficial atualizada no commit `b7aa9f3bd212088e0d927439284dc5ed325ce3c7`. A nova build Release compila. Ainda não foi executada com o jogo; as execuções anteriores chegaram à inicialização e à compilação de shaders, mas encerraram durante ou após o loading. Não foi confirmado gameplay.
- **VIctory puro:** fonte arquivada no commit `ffe310eb2098e52169f4c44db5ffdabf43a72622`, com uma alteração local documentada abaixo. A build Release corrigida identificou o `TitleId 7952987A`, carregou as DLLs do pacote e avançou para o processamento de shaders. Não foi confirmado menu jogável ou gameplay.
- **VIctory com XCL:** a variante de integração ajusta a submissão de listas e utiliza o runtime integrado disponível no checkout local. Não há evidência de que tenha corrigido renderização do cenário ou de que tenha chegado à jogabilidade.
- **Builds experimentais anteriores:** executáveis preservados em `builds/` com nomes derivados das pastas locais de compilação. São registros históricos, não uma recomendação de uso.

Nenhuma build deste arquivo é anunciada como plenamente jogável.

## Conteúdo

- `builds/` contém executáveis dos projetos e das variantes experimentais que foram encontrados nas pastas de build locais. Cada nome conserva o nome da pasta de compilação original, codificando suas separações como `__`.
- `builds/xcl-puro/build-b7aa9f3__release__xcl.exe` é a build Release mais recente do XCL arquivada aqui.
- `sources/xcl-b7aa9f3/` contém a fonte oficial do XCL no commit usado para essa build. `sources/xcl-930e8b4/` permanece como snapshot anterior.
- `sources/xcl-930e8b4/` contém o checkout da fonte oficial do XCL nesse commit.
- `sources/victory-ffe310e/` contém a fonte do VIctory usada na build mais recente arquivada, incluindo a correção local de seleção da pasta do pacote.
- `launchers/` contém os BATs e o inicializador PowerShell usados no PC de teste.
- `launchers/Preparar shaders XCL Atualizado.bat` inicia a preparação persistente dos shaders antes de abrir o jogo.
- `BUILD-MANIFEST.tsv` relaciona executáveis, tamanho e caminho original da build.

Os códigos-fonte retêm seus avisos de licença originais. O XCL declara GPL-2.0 e o VIctory declara GPL-3.0-or-later. Consulte `sources/*/LICENSE`.

## Histórico dos testes

### Leonida

Leonida foi testado primeiro em várias atualizações. As tentativas documentadas abriram uma janela branca e fecharam sem chegar à interface do jogo. Não houve uma execução estável que superasse XCL ou VIctory, então Leonida deixou de ser a base principal.

### XCL puro

XCL passou a abrir o executável e reproduziu o vídeo de introdução em algumas builds. O desempenho oscilou bastante. Em testes, ficou entre cerca de 5 e 30 FPS, com travamentos, quedas para 0 FPS e encerramentos durante a transição do loading para a compilação de shaders. O usuário observou que builds sucessivas avançavam mais longe e compilavam mais shaders, chegando a mais de 120 antes de fechar.

Os desenvolvedores do projeto descreveram dois bloqueios gráficos em andamento. A compilação de shaders podia congelar a renderização por tempo suficiente para o watchdog do jogo encerrar o processo. Separadamente, uma ordenação incorreta de esperas da GPU podia permitir leituras de dados ainda não escritos, causando tela preta e crash. Esses relatos foram usados como contexto de diagnóstico, não como prova de que uma build local os corrigiu.

A versão pura `930e8b4` foi compilada após a atualização de D3D12.X em `list_x.rs`, que altera o reaproveitamento de listas de comandos e buffers de scratch. A compilação e a verificação do BAT passaram. Não foi feito um novo teste de jogo nessa versão.

A build pura `b7aa9f3` foi compilada em Release com Rust 1.98.1 após atualizar a fonte oficial. Ela inclui a nova sessão de cache de shaders D3D12.X e correções recentes de sincronização D3D12.X/DirectStorage. O launcher mantém o cache DXIL da RTX 3060, habilita o cache persistente de PSO e usa a janela de memória coerente de 4096 MiB quando há pelo menos 17 GiB de commit livre. A compilação concluiu; não foi feito teste de jogo nessa build, então ainda não há medida comparativa de FPS nem confirmação de imagem ou gameplay.

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

### Leonida puro e versões modificadas

As snapshots `sources/leonida-pure/` e `sources/leonida-modified/` preservam, respectivamente, a pasta local `C:\gta\Leonida-main` e o checkout de trabalho `C:\gta\leonida-test\source`. Essas pastas locais não continham metadados Git, então não foi possível fixar o commit de origem. O arquivo de trabalho inclui as alterações locais que estavam nessa cópia. Também foram guardados os patches `4348.patch` e `6964.patch` em `patches/leonida/`.

As tentativas locais com Leonida abriram uma janela branca e fecharam logo em seguida, sem interface do jogo. Não foi verificado carregamento do prólogo. Não há um executável principal de Leonida compilado nas duas pastas de origem. `builds/leonida/rt5-build/` guarda apenas os executáveis auxiliares de teste encontrados no diretório de build modificado: `gta6rt.exe`, `bvh_builder_test.exe` e `vk_pipeline_check.exe`. Eles validam partes do runtime e do BVH, não são um launcher de jogo.

Os dois diretórios de origem foram copiados sem diretórios de build e cache, arquivos de shader e assets extraídos. A lista de executáveis e seus caminhos de origem foi atualizada em `BUILD-MANIFEST.tsv`.

