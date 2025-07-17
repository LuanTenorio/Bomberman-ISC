.data
	IMAGE_ORIGINAL: .word 0, 0, 0, 0, 0 # Guarda o endereço da imagem e posições iniciais x e y respectivamente
	
	CONTADOR_MUSICA: .word 0
	DIRECAO_ATUAL_SPRITE_BOMBERMAN: .word bomber_baixo

	BOMBERMAN_1: .word bomber_cima,
		bomber_direita,
		bomber_baixo,
		bomber_esquerda
	
	MAPA_ATUAL: .word 2 # 1 = fase 1 e 2 = fase 2

	IMAGENS_MAPA_1:
        .word mapa_1,
        .word hard_block_1,
        .word soft_block_1,
        .word fogo_1,
        .word bomba_1

    IMAGENS_MAPA_2:
        .word mapa_2,
        .word hard_block_2,
        .word soft_block_2,
        .word fogo_2,
        .word bomba_2

    MAPAS:
        .word IMAGENS_MAPA_1
        .word IMAGENS_MAPA_2

	#Posições iniciais do bomberman 
	BOMBER_POS: .half 24, 48

	BOMBA: .word 0, 3000, 0, 1, 1, 500   # 1º Bomba colocada, 2º Intervalo da bomba (ms), 3º Tempo para controle da bomba,  4º posição X e 5º posição Y, 6º intervalo explosão (ms)
	BOMBER_VIDA: .word 3, 510, 0, 0 	# 1º Qtd corações, 2º intervalo de dano, 3º espaço auxiliar, 4º status se já levou dano ou não
	PONTUACAO: .word 0, 0 	# 1º pontuação, 2º espaço auxiliar

# s11 = guarda o tempo para a Música
# s0 = inverte o frame a ser mostrado

.text

# Defines das imagens na tabela de imagens
.eqv IMAGENS_ID_MAPA, 0
.eqv IMAGENS_ID_HARD_BLOCK, 1
.eqv IMAGENS_ID_SOFT_BLOCK, 2
.eqv IMAGENS_ID_FOGO, 3 # verificar e trocar uma uma fogo com pedaço transparente
.eqv IMAGENS_ID_BOMBA, 4 # verificar e trocar uma uma bomba com pedaço transparente

SETUP:
	# call SORTEAR_FASE
	# li a0, IMAGENS_ID_MAPA
	# call SELECIONA_IMAGEM_PELO_MAPA
	# li a1, 0
	# li a2, 0
	# li a3, 0
	# call PRINT
	# li a3, 1
	# call PRINT
	
	la a0, hard_block_1
	li a1, 40	
	li a2, 64
	call SET_HARD_BLOCKS # Quando cada hardblock é setado, o softblock é setado junto
	
	# Tirando os soft blocks ao redor do spawn do bomberman
	la t0, mapa_de_colisao
	li t1, 3
	sh t1, 116(t0)
	li t1, 0
	sh t1, 118(t0)
	sh t1, 154(t0)

	#Carrega o bomberman
	la t0, BOMBER_POS
	la a0, bomber_baixo
	lh a1, 0(t0)
	lh a2, 2(t0)
	li a3, 0
	call PRINT
	li a3, 1
	call PRINT

	# Seta o frame de trabalho inicial
	li s0, 1

	li a7, 30 	# Salva os 32 low bits do tempo atual em s11. IMPORTANTE PARA A MÚSICA!
	ecall
	mv s11, a0

	# Seta o timer que controla a bomba
	la t0, BOMBA
	sw a0, 8(t0) 

	# Seta o timer que controla o intervalo de dano tomado
	la t0, BOMBER_VIDA
	sw a0, 8(t0)
	
GAME_LOOP: 
	call TOCAR_MUSICA
	
	# Renderiza o mapa
	li a0, IMAGENS_ID_MAPA
	call SELECIONA_IMAGEM_PELO_MAPA
	call PRINT_MAPA
	
	call VERIFICAR_VIDA

	la t0, BOMBER_VIDA
	lw t1, 0(t0) # Carrega a vida do bomberman
	beqz t1, GAME_OVER # Se a vida do bomberman for 0, game over

	call VERIFICAR_BOMBA

	call PRINT_PONTUACAO

	# Renderiza os hard blocks	
	li a0, IMAGENS_ID_HARD_BLOCK
	call SELECIONA_IMAGEM_PELO_MAPA
	li a4, 1
	call RENDERIZAR_MAPA_COLISAO

	# Renderiza os soft blocks
	li a0, IMAGENS_ID_SOFT_BLOCK
	call SELECIONA_IMAGEM_PELO_MAPA
	li a4, 2
	call RENDERIZAR_MAPA_COLISAO

	# Renderiza as bombas
	la a0, bomba_1
	li a4, 4
	call RENDERIZAR_MAPA_COLISAO

	# Renderiza as explosões
	la a0, fogo_1
	li a4, 5
	call RENDERIZAR_MAPA_COLISAO

	# Renderiza o bomberman
	la t0, DIRECAO_ATUAL_SPRITE_BOMBERMAN
	lw a0, 0(t0)
	li a4, 3
	call RENDERIZAR_MAPA_COLISAO

	call INPUT 	# Retorna a tecla pressinada em a0
	call EXECUTAR_ACAO	# Executa ação a partir da tecla em a0

	# Altera o frame mostrado
	li t0, 0xFF200604
	sw s0, 0(t0)

	# Inverte o frame (trabalharemos com o frame escondido enquanto o seu oposto é mostrado)	
	xori s0, s0, 1

	j GAME_LOOP

GAME_OVER:
	# Game Over
	la a0, mapa_1
	call PRINT_MAPA
	
	li a7, 10
	ecall # FIM 

	j SETUP
	

EXECUTAR_ACAO:
	addi sp, sp, -4     # reserva espaço na pilha
    sw ra, 4(sp)         # salva return address
    	
	li t0, 'd'
	beq a0, t0, MOVE_DIREITA
	
	li t0, 'a'
	beq a0, t0, MOVE_ESQUERDA
	
	li t0, 'w'
	beq a0, t0, MOVE_CIMA
	
	li t0, 's'
	beq a0, t0, MOVE_BAIXO

	li t0, ' '
	beq a0, t0, SET_BOMBA
	
	lw ra, 4(sp)       # restaura return address
    addi sp, sp, 4     # desloca o stack pointer
	ret
	
# IMPORT DE FUNÇÕES:
.include "funcoes/funcoes_auxiliares.s"
.include "funcoes/audio.s"
.include "funcoes/funcoes_primarias.s"
.include "funcoes/acoes.s"	
	
# IMPORT DE IMAGES:
.data
.include "images/mapa/fase_1/mapa_1.data"
.include "images/mapa/fase_1/hard_block_1.data"
.include "images/mapa/fase_1/soft_block_1.data"
.include "images/mapa/mapa_de_colisao.data"
.include "images/mapa/fase_1/bomba_1.data"
.include "images/mapa/fase_1/fogo_1.data"
.include "images/personagens/bomber_cima.data"
.include "images/personagens/bomber_baixo.data"
.include "images/personagens/bomber_esquerda.data"
.include "images/personagens/bomber_direita.data"
.include "images/mapa/fase_2/mapa_2.data"
.include "images/mapa/fase_2/hard_block_2.data"
.include "images/mapa/fase_2/soft_block_2.data"
.include "images/mapa/fase_2/bomba_2.data"
.include "images/mapa/fase_2/fogo_2.data"
