# XCL - Novos Handlers Implementados (24/11/2026)

## Slots corrigidos no codigo:

### 1. CommandAllocator #9 - SetCommandMemoryCallback
- **Problema**: 854 chamadas retornando NULL
- **Solucao**: Implementado handler que armazena o callback e retorna S_OK
- **Arquivo**: `crates/xcl/src/hle/d3d12x/real.rs:48`

### 2. CommandQueue #31 - EnableRecorder (newer layout)
- **Problema**: 374 chamadas retornando NULL (stub generico)
- **Solucao**: Handler dedicado que retorna S_OK
- **Arquivo**: `crates/xcl/src/hle/d3d12x/real.rs:1089`

### 3. CommandList #75 - SetAsyncPipelineState
- **Problema**: 773 chamadas sem mapeamento no NEWER_LIST_SLOTS
- **Solucao**: Mapeado para redirecionar para SetPipelineState1 (ID3D12GraphicsCommandList5)
- **Arquivo**: `crates/xcl/src/hle/d3d12x/real.rs:1076`

### 4. Fix de tipo
- EnableRecorder: retorno S_OK (i32) -> usize cast

### 5. Fix de deprecation
- XUserCloseHandle: fetch_update -> try_update

## Build:
```
cargo build --release [1m 29s]
```

## Commit:
```
Fix CommandAllocator slot #9, CommandQueue slot #31, CommandList slot #75
- Add alloc_set_cmd_callback for Xbox Reset with callback
- Add enable_recorder_x for newer queue layout
- Map SetAsyncPipelineState to SetPipelineState1
- Fix S_OK type mismatch in EnableRecorder
- Fix deprecated fetch_update in XUserCloseHandle
```
