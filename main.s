.data
	IMAGE_ORIGINAL: .word 0, 0, 0, 0, 0 # Guarda o endereço da imagem e posições iniciais x e y respectivamente
	
	CONTADOR_MUSICA: .word 0, 0 	# 1º Contador da música, 2º controlador do timer 
	
	#Posições iniciais do bomberman 
	BOMBER_POS: .half 24, 48

	BOMBA: .word 0, 3000, 0, 1, 1, 500   # 1º Bomba colocada, 2º Intervalo da bomba (ms), 3º Tempo para controle da bomba,  4º posição X e 5º posição Y, 6º intervalo explosão (ms)
	BOMBER_VIDA: .word 1, 510, 0, 0 	# 1º Qtd corações, 2º intervalo de dano, 3º espaço auxiliar, 4º status se já levou dano ou não
	PONTUACAO: .word 0, 0 	# 1º pontuação, 2º espaço auxiliar

# s11 = guarda o tempo para a Música
# s0 = inverte o frame a ser mostrado

.text

SETUP:	# Printa o background inicial
	la a0, mapa_fase1 
	call PRINT_MAPA
	
	la a0, hard_block
	li a1, 40	
	li a2, 64
	call SET_HARD_BLOCKS # Quando cada hardblock é setado, o softblock é setado junto
	
	# Tirando os soft blocks ao redor do spawn do bomberman
	la t0, mapa_de_colisao
	li t1, 0
	sh t1, 116(t0)
	li t1, 0
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

	# Seta o frame de trabalho inicial
	li s0, 1

	li a7, 30 	# Salva os 32 low bits do tempo atual em s11. IMPORTANTE PARA A MÚSICA!
	ecall
	mv t0, a0

	la t1, CONTADOR_MUSICA
	sw t0, 4(t1)

	# Seta o timer que controla a bomba
	la t0, BOMBA
	sw a0, 8(t0) 

	# Seta o timer que controla o intervalo de dano tomado
	la t0, BOMBER_VIDA
	sw a0, 8(t0)
	
GAME_LOOP: 
	la a4, notas_fase1
	la a5, num_notas_fase1
	call TOCAR_MUSICA
	
	la a0, mapa_fase1
	call PRINT_MAPA
	
	call VERIFICAR_VIDA

	la t0, BOMBER_VIDA
	lw t1, 0(t0) # Carrega a vida do bomberman
	beqz t1, GAME_OVER # Se a vida do bomberman for 0, game over

	call VERIFICAR_BOMBA

	call PRINT_PONTUACAO

	la a0, chao_do_mapa
	li a4, 0
	call RENDERIZAR_MAPA_COLISAO

	# Renderiza os hard blocks	
	la a0, hard_block
	li a4, 1
	call RENDERIZAR_MAPA_COLISAO

	# Renderiza os soft blocks
	la a0, soft_block
	li a4, 2
	call RENDERIZAR_MAPA_COLISAO

	# Renderiza as bombas
	la a0, bomba
	li a4, 4
	call RENDERIZAR_MAPA_COLISAO

	# Renderiza as explosões
	la a0, bomba
	li a4, 5
	call RENDERIZAR_MAPA_COLISAO

	call PRINT_BOMBERMAN

	call INPUT 	# Retorna a tecla pressinada em a0
	call EXECUTAR_ACAO	# Executa ação a partir da tecla em a0

	# Altera o frame mostrado
	li t0, 0xFF200604
	sw s0, 0(t0)

	# Inverte o frame (trabalharemos com o frame escondido enquanto o seu oposto é mostrado)	
	xori s0, s0, 1

	j GAME_LOOP

GAME_OVER:

	# Zera o controlar de música para a música de gameover
	la t0, CONTADOR_MUSICA
	li t1, 0	
	sw t1, 0(t0)

	li a7, 30
	ecall

	mv t1, a0
	sw t1, 4(t0)

	# Game Over - TROCAR PARA TELA DE GAME OVER
	la a0, mapa_fase1
	li a1, 0
	li a2, 0
	li a3, 1
	call PRINT
	li a3, 0
	call PRINT

loop_go:
	la a4, notas_game_over
	la a5, num_notas_game_over
	call TOCAR_MUSICA

	li t1,0xFF200000		
	lw t0,0(t1)			
	andi t0,t0,0x0001		
	beq t0, zero, loop_go
	lw a0, 4(t1)

	li t0, '\n'
	bne a0, t0, loop_go

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
.include "images/mapa/chao_do_mapa.data"
.include "images/mapa/mapa_fase1.data"
.include "images/mapa/hard_block.data"
.include "images/mapa/soft_block.data"
.include "images/mapa/tijolo_16x16.data"
.include "images/mapa/mapa_de_colisao.data"
.include "images/mapa/bomba.data"
.include "audio/musica_fase1.data"
.include "audio/musica_game_over.data"