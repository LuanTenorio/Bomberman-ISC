# Bomberman-ISC

Implementação do clássico jogo Bomberman desenvolvido em Assembly RISC-V como trabalho final da disciplina de Introdução aos Sistemas Computacionais (ISC).

## 📋 Descrição

Este projeto recria o famoso jogo Bomberman utilizando a arquitetura RISC-V, implementa boa parte das funcionalidades originais como movimentação do personagem, colocação de bombas, explosões, quebras de blocos e pontuação. 

## 🎮 Funcionalidades

- **Movimentação do Bomberman** com sprites diferentes
- **Sistema de bombas** com explosões em cruz
- **Mapa com blocos destrutíveis e indestrutíveis**
- **Sistema de colisão**
- **Pontuação** e sistema de vidas
- **Efeitos sonoros** e música de fundo
- **Telas de vitória e game over**
- **Fases** geradas aleatoriamente

## 🎯 Controles

- **W** - Mover para cima
- **S** - Mover para baixo  
- **A** - Mover para esquerda
- **D** - Mover para direita
- **Espaço** - Colocar bomba
- **Enter** - Confirmar nas telas de menu

## 🛠️ Tecnologias Utilizadas

- **Assembly RISC-V** - Linguagem principal
- **RARS (RISC-V Assembler and Runtime Simulator)** - Simulador
- **FPGRARS (Fast Pretty Good RISC-V Assembly Rendering System)** - Simulador melhor
- **Bitmap Display** - Para renderização gráfica (320x240)
- **Keyboard and Display MMIO** - Para entrada de teclado
- **MIDI Out** - Para efeitos sonoros e música
- **Paint.NET** - Para criar e editar as imagens
- **bmp2oac3** - Conversor de imagem para .data

## 📁 Estrutura do Projeto

```
Bomberman-ISC/
├── main.s                      # Arquivo principal e game
├── funcoes/
│   ├── funcoes_primarias.s     # Funções de renderização e 
│   ├── funcoes_auxiliares.s    # Funções utilitárias
│   ├── acoes.s                 # Ações do jogador e bombas
│   └── inimigo.s               # Tentativa de criar inimigos
|   └── audio.s                 # Funções para tocar música
├── imagens/
│   ├── Algarismos, sprites de mapa, elementos e etc
├── audio/
│   ├── musica_game_over.data  # Música de derrota
│   └── musica_vitoria.data    # Música de vitória
|   └── musica_fase.data        
└── README.md
```

## 🚀 Como Executar
Execute o arquivo main.s com o fpgrars:
``` bash
    programas/fpgrars-x86_64-pc-windows-msvc--unb.exe main.s 
```

## 🎯 Objetivos do Jogo

- Destrua os blocos destrutíveis para se movimentar
- Evite explosões
- Colete pontos destruindo blocos e colocando bombas
- Consiga 50 pontos

## 👥 Créditos

Desenvolvido como trabalho final da disciplina de **Introdução aos Sistemas Computacionais (ISC)**.

**Autores**:
- Kauã Otaviano Teixeira
- Thierry Luan Tenório De Jesus
- Jennifer Carvalho Alves

**Instituição**: Universidade de Brasília - Departamento de Ciência da Computação
**Ano**: 2025

## 📄 Licença

Este projeto foi desenvolvido para fins educacionais como parte do curso de ISC.

---

*Bomberman original © Hudson Soft / Konami*