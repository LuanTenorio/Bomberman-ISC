.data
	IMAGE_ORIGINAL: .word 0, 0, 0, 0, 0 # Guarda o endereço da imagem e posições iniciais x e y respectivamente
	
	CONTADOR_MUSICA: .word 0
	
	#Posições iniciais do bomberman 
	BOMBER_POS: .half 24, 48
	OLD_BOMBER_POS: .half 40, 48

	BOMBER_VIDA: .byte 3
	PONTUACAO: .word 1022, 0 	# 1º pontuação, 2º espaço auxiliar

# s11 = guarda o tempo para a Música
# s0 = inverte o frame a ser mostrado

.text
SETUP:	# Printa o background inicial
	la a0, mapa_fase1 
	li a1, 0
	li a2, 0
	li a3, 0
	call PRINT
	li a3, 1
	call PRINT
	
	la a0, hard_block
	li a1, 40	
	li a2, 64
	call SET_HARD_BLOCKS # Quando cada hardblock é printado, o softblock é pintado junto
	
	# Tirando os soft blocks ao redor do spawn do bomberman
	la t0, mapa_de_colisao
	li t1, 0
	sh t1, 116(t0)
	sh t1, 118(t0)
	sh t1, 154(t0)


	#Carrega o bomberman
	la t0, BOMBER_POS
	la a0, tijolo_16x16
	lh a1, 0(t0)
	lh a2, 2(t0)
	li a3, 0
	call PRINT
	li a3, 1
	call PRINT

	li s0, 1

	li a7, 30 	# Salva os 32 low bits do tempo atual em s11. IMPORTANTE PARA A MÚSICA!
	ecall
	mv s11, a0
	
GAME_LOOP: 
	call TOCAR_MUSICA
	
	la a0, mapa_fase1
	call PRINT_MAPA
	
	call VERIFICAR_VIDA

	call PRINT_PONTUACAO

	la a0, hard_block
	li a4, 1
	call RENDERIZAR_MAPA_COLISAO

	la a0, soft_block
	li a4, 2
	call RENDERIZAR_MAPA_COLISAO

	call PRINT_BOMBERMAN # Printa o bomberman na posição atual

	call INPUT 	# Retorna a tecla pressinada em a0
	
	call EXECUTAR_ACAO	# Executa ação a partir da tecla em a0

	# Altera o frame mostrado
	li t0, 0xFF200604
	sw s0, 0(t0)

	# Inverte o frame (trabalharemos com o frame escondido enquanto o seu oposto é mostrado)	
	xori s0, s0, 1

	j GAME_LOOP
	

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
.include "images/mapa/chao_do_mapa.data"
.include "images/mapa/mapa_fase1.data"
.include "images/mapa/hard_block.data"
.include "images/mapa/soft_block.data"
.include "images/mapa/tijolo_16x16.data"
.include "images/mapa/mapa_de_colisao.data"



