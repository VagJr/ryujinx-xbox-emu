# Shaders e Pipelines - GTA 6 (24/11/2026)

## Pipeline Async (Background Compilation)
- **Status**: Implementado e funcionando
- **Threads**: cores - 1 (configurado por XCL_DXC_THREADS)
- **Stand-in**: Criado instantaneamente enquanto o real compila em background
- **Substituicao**: Automatica quando o build termina

## Cache de Shaders
- **DXIL Cache**: dxil-sdk-1.8
- **PSO Disk Cache**: Ativado (XCL_PSO_DISK_CACHE=1)
- **Shaders pre-compilados**: ~15.000+ em cache

## Modos de compilacao
1. **Async (padrao)**: Stand-in + background build
   - XCL_ASYNC_PSO=1 (padrao)
   - XCL_LAZY_PSO=1 (padrao)
2. **Sync**: Compila tudo na chamada
   - XCL_ASYNC_PSO=0
3. **Lazy**: Compila so quando usado
   - XCL_LAZY_PSO=1

## Pipeline Fallback
Quando a traducao de shader falha:
1. Tenta dummy shaders (VS/PS genericos)
2. Se o driver rejeitar, retorna erro mas jogo continua
3. Nenhum pipeline com erro derruba o jogo

## Proximos passos:
- Implementar slots #126, #142, #101, #131, #132 (stubs)
- Investigar por que o jogo trava no primeiro loading
- Testar com diferentes versoes do DXC
