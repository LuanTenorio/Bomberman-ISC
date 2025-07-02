.data
	IMAGE_ORIGINAL: .word 0, 0, 0, 0, 0 # Guarda o endereço da imagem e posições iniciais x e y respectivamente
	
	CONTADOR_MUSICA: .word 0
	
	#Posições iniciais do bomberman 
	BOMBER_POS: .half 24, 48
	OLD_BOMBER_POS: .half 24, 48

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
	
	#Carrega o bomberman
	la t0, BOMBER_POS
	la a0, tijolo_16x16
	lh a1, 0(t0)
	lh a2, 2(t0)
	li a3, 0
	call PRINT
	li a3, 1
	call PRINT
	
	li a7, 30 	# Salva os 32 low bits do tempo atual em s11. IMPORTANTE PARA A MÚSICA!
	ecall
	mv s11, a0
	
GAME_LOOP: 
	call TOCAR_MUSICA

	call VERIFICA_VIDA
	
	call PRINT_PONTUACAO

	call INPUT 	# Retorna a tecla pressinada em a0
	
	call EXECUTAR_ACAO	# Executa ação a partir da tecla em a0

	# Inverte o frame (trabalharemos com o frame escondido enquanto o seu oposto é mostrado)	
	xori s0, s0, 1

	# Altera o frame mostrado
	li t0, 0xFF200604
	sw s0, 0(t0)
	
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
.include "funcoes_auxiliares.s"
.include "audio.s"
.include "funcoes_primarias.s"
.include "acoes.s"	
	
# IMPORT DE IMAGES:
.data
.include "images/chao_do_mapa.data"
.include "images/mapa_fase1.data"
.include "images/hard_block.data"
.include "images/soft_block.data"
.include "images/tijolo_16x16.data"
.include "images/mapa_de_colisao.data"



