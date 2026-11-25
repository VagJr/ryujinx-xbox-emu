# Progresso do Projeto - GTA 6 via Emulador Xbox
**Ultima atualizacao**: 25/11/2026 - Build 5523818 (XCL cbc296a + VIctory latest)

---

## Builds Disponiveis

### XCL Puro (sem VIctory)
- **Caminho**: C:\gta\xcl-puro\build-5523818\release\xcl.exe
- **Commit**: cbc296a (upstream xcl-dev/xcl)
- **Modificacoes**: Slots #9 (CommandAllocator), #31 (CommandQueue), #75 (CommandList)
- **Tamanho**: ~15 MB

### XCL + VIctory Integrado
- **Caminho**: C:\gta\xcl-victory\build-5523818-xcl\release\xcl.exe
- **VIctory worker**: C:\gta\xcl-victory\decoder\victory-bcpack-worker.exe
- **Commit**: cbc296a + VIctory latest (Marvisak/VIctory)
- **Tamanho**: ~22 MB

### VIctory Puro
- **Caminho**: C:\gta\victory-test\source\target\release\victory.exe
- **Commit**: latest Marvisak/VIctory
- **Build time**: 40s

---

## BATS de Inicio Rapido

| BAT | O que faz |
|-----|-----------|
| Abrir XCL Puro.bat | XCL puro build 5523818 |
| Abrir XCL Atualizado.bat | Mesmo, nome alternativo |
| Abrir XCL com VIctory.bat | XCL + VIctory integrado |
| Abrir VIctory Puro.bat | VIctory standalone |
| Abrir VIctory com XCL.bat | VIctory + XCL (alternativo) |
| Preparar shaders XCL Atualizado.bat | Compila shaders em background |

---

## Modificacoes no Codigo Fonte (XCL-Atual)

### Crate hle/d3d12x/real.rs
1. **Slot #9 CommandAllocator**: lloc_set_cmd_callback - callback de memoria de comandos
2. **Slot #31 CommandQueue**: enable_recorder_x - stub do gravador de comandos
3. **Slot #75 CommandList**: set_async_pso_x - roteamento correto para SetPipelineState1
4. **fetch_update ? try_update**: Fix de API depreciada (real.rs:3409 + xgameruntime/mod.rs)

### Crate hle/xgameruntime/mod.rs
- Fix etch_update ? 	ry_update (deprecated API)

---

## Testes Realizados

### XCL Puro (build 5523818)
- Jogo abre e mostra imagem
- Primeiro loading roda
- Nao passa do primeiro loading (trava)
- Sem audio
- Sem crash

### XCL + VIctory (build 5523818-xcl)
- Em teste
- VIctory worker atualizado para latest

---

## Proximos Passos

1. Testar jogo com build 5523818 e verificar se avanca do primeiro loading
2. Implementar slots faltantes (#126, #142, #101, #131, #132)
3. Testar com diferentes versoes DXC
4. Compilar mais shaders em cache
5. Investigar trava no primeiro loading (possivelmente pipeline nao compilado)

---

## Shaders Cache

- **DXIL Cache**: dxil-sdk-1.8
- **Shaders embedded**: shaders-pe-early-xmas (~15.000+ pipelines)
- **Pre-compile**: Preparar shaders XCL Atualizado.bat
