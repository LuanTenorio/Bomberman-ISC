.data

# --- Metadados dos registrados --
#	a0 = endereço imagem (com tudo, pixeis e metadados)
#	a1 = x
#	a2 = y
#	a3 = frame (0 ou 1)
#
## ---
#	t0 = endereço do bitmap display
#	t1 = endereço da imagem (só pixel)
#	t2 = contador de linha
#	t3 = contador de coluna
#	t4 = largura
# 	t5 = altura
#

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
	li a2, 32
	call PRINT_HARD_BLOCKS
	
	la a0, soft_block
	li a1, 40	
	li a2, 16
	call PRINT_SOFT_BLOCKS
	
GAME_LOOP: 
	# Importante chamar o INPUT antes de tudo, pois ele define os parâmetros do que irá ser printado
	call INPUT

	# Inverte o frame (trabalharemos com o frame escondido enquanto o seu oposto é mostrado)
	xori s0, s0, 1

	#Carrega o bomberman
	la t0, BOMBER_POS
	la a0, tijolo_16x16
	lh a1, 0(t0)
	lh a2, 2(t0)
	mv a3, s0
	call PRINT
	
	# Altera o frame mostrado
	li t0, 0xFF200604
	sw s0, 0(t0)
	
	#limpa o frame
	#Carrega o bomberman
	la t0, OLD_BOMBER_POS
	la a0, chao_do_mapa
	lh a1, 0(t0)
	lh a2, 2(t0)
	
	mv a3, s0
	xori a3, a3, 1
	call PRINT
	
	j GAME_LOOP
	
# Nesse procedimento, ele checa se o teclado foi apertado e se o 'o' ou 'f' foi a tecla apertada
# Se for uma dessas duas opções, ele muda a imagem mostrada para a otaviano ou frogger respectivamente
INPUT:
	li t1,0xFF200000		
	lw t0,0(t1)			
	andi t0,t0,0x0001		
	beq t0, zero, FIM
	lw t2, 4(t1)
	
	li t0, 'd'
	beq t2, t0, MOVE_DIREITA
	
	li t0, 'a'
	beq t2, t0, MOVE_ESQUERDA
	
	li t0, 'w'
	beq t2, t0, MOVE_CIMA
	
	li t0, 's'
	beq t2, t0, MOVE_BAIXO
	
FIM: 	ret

IMG_OTAVIANO:
	la a0, otaviano
	li a1, 0
	li a2, 0
	mv a3, s0
	ret
	
IMG_FROGGER:
	la a0, frogger
	li a1, 0
	li a2, 0
	mv a3, s0
	ret

PRINT: 
	# Define o endereço inicial do bitmap display e qual frame vai usar
	li t0, 0xFF0
	add t0, t0, a3
	slli t0, t0, 20
	
	# Define qual pixel irá preencher a partir do endereço inicial e valores X e Y advindos da iteração da imagem
	# Endereço = Endereço base (t0) + y (a2) * 320 + x (a1)
	add t0, t0, a1
	
	li t1, 320
	mul t1, t1, a2
	add t0, t0, t1
	
	# Define o começo dos píxeis
	addi t1, a0, 8
	
	# Define as variáveis que irão iteração sobre a imagem (contadores)
	mv t2, zero
	mv t3, zero
	
	# Define a largura (t4) e altura (t5) da imagem
	lw t4, 0(a0)
	lw t5, 4(a0)

PRINT_LINHA:
	# Busca 4 pixeis da imagem e coloca no endereço de vídeo
	lw t6, 0(t1)
	sw t6, 0(t0)
	
	addi t0, t0, 4
	addi t1, t1, 4
	
	# Fica preso nesse loop até a coluna chegar na largura da imagem
	addi t3, t3, 4  
	blt t3, t4, PRINT_LINHA
	
	# Pula para a próxima linha
	addi t0, t0, 320
	sub t0, t0, t4
	
	# Fica preso nesse loop até linha chegar na altura da imagem
	mv t3, zero
	addi t2, t2, 1
	bgt t5, t2, PRINT_LINHA
	
	ret

MOVE_ESQUERDA:
	li s10, -16
	j MOVE_HORIZONTAL
	
MOVE_DIREITA:
	li s10, 16
	j MOVE_HORIZONTAL
	
#s10 eh o argumento da direção
MOVE_HORIZONTAL:
	addi sp, sp, -4     # reserva espaço na pilha
    	sw ra, 4(sp)         # salva return address
    	
	#carrega e altera a posição antiga do bomber
	la s11, BOMBER_POS # carreaga a posição atual no mapa de pixeis
	la s9, OLD_BOMBER_POS
	lw s8, 0(s11)
	sw s8, 0(s9)

	call VERIFICA_COLISAO_HORIZONTAL

	li a1, 1 # Se a7 for 1, houve colisão
	beq a7, a1, FIM_MOVIMENTO_HORIZONTAL

	#soma e atualiza a posição
	lh a1, 0(s11) # Carrega a coordenada X atual
	add a1, a1, s10 # Adiciona o deslocamento
	sh a1, 0(s11) # Salva a nova coordenada X

FIM_MOVIMENTO_HORIZONTAL:
	lw ra, 4(sp)       # restaura return address
    	addi sp, sp, 4     # desloca o stack pointer
	
	ret

MOVE_CIMA:
	li s10, -16
	j MOVE_VERTICAL

MOVE_BAIXO:
	li s10, 16
	j MOVE_VERTICAL

#s10 eh o argumento da direção
MOVE_VERTICAL:
	addi sp, sp, -4     # reserva espaço na pilha
    	sw ra, 4(sp)         # salva return address

	#carrega e altera a posição antiga do bomber
	la s11, BOMBER_POS # carreaga a posição atual no mapa de pixeis
	la s9, OLD_BOMBER_POS
	lw s8, 0(s11)
	sw s8, 0(s9)
	
	call VERIFICA_COLISAO_VERTICAL # Chama a função de verificação de colisão vertical

	li a1, 1 # Se a7 for 1, houve colisão
	beq a7, a1, FIM_MOVIMENTO_VERTICAL

	#soma e atualiza a posição
	lh a1, 2(s11) # Carrega a coordenada Y atual
	add a1, a1, s10 # Adiciona o deslocamento
	sh a1, 2(s11) # Salva a nova coordenada Y

FIM_MOVIMENTO_VERTICAL:
	lw ra, 4(sp)       # restaura return address
    	addi sp, sp, 4     # desloca o stack pointer

	ret

VERIFICA_COLISAO_HORIZONTAL:
	# Salva registradores usados que nao sao temporarios
	addi sp, sp, -16
	sw ra, 0(sp)
	sw s11, 4(sp)
	sw s10, 8(sp) 
	sw s9, 12(sp)

	# Carrega a posição atual do bomberman em pixel
	la t0, BOMBER_POS
	lh t1, 0(t0) # t1 = x_atual (pixel)
	lh t2, 2(t0) # t2 = y_atual (pixel)

	# Calcula a posição X futura
	add t1, t1, s10 # t1 = x_futuro (pixel)

	# Converte coordenadas de pixel para coordenadas de mapa de colisao
	srli t1, t1, 4 # divide por 16
	srli t2, t2, 4 # divide por 16

	# Calcula o endereço da celula no mapa de colisao
	# Endereço = Endereço base do mapa + (y_mapa * largura_mapa + x_mapa) * tamanho_elemento
	la t3, mapa_de_colisao # t3 = endereço base do mapa

	li t4, 19 # t4 = largura do mapa
	mul t5, t2, t4 # t5 = y_mapa * largura_mapa
	add t5, t5, t1 # t5 = (y_mapa * largura_mapa) + x_mapa

	slli t5, t5, 1 # t5 = t5 * 2 
	add t3, t3, t5 # t3 = endereço da celula no mapa de colisao

	# Carrega o valor da celula do mapa de colisao
	lh t6, 0(t3) # t6 = valor da celula

	# Chamar aqui quando colidir com o inimigo
	bne t6, zero, COLISAO_OCORREU

	# Não houve colisao
	li a7, 0
	j FIM_VERIFICA_COLISAO_HORIZONTAL

COLISAO_OCORREU:
	li a7, 1

FIM_VERIFICA_COLISAO_HORIZONTAL:
	# Restaura registradores salvos
	lw ra, 0(sp)
	lw s11, 4(sp)
	lw s10, 8(sp)
	lw s9, 12(sp)
	addi sp, sp, 16

	ret

VERIFICA_COLISAO_VERTICAL:
	# Salva registradores usados que não são temporários
	addi sp, sp, -16
	sw ra, 0(sp)
	sw s11, 4(sp)
	sw s10, 8(sp)
	sw s9, 12(sp)

	# Carrega a posição atual do bomberman
	la t0, BOMBER_POS
	lh t1, 0(t0) # t1 = x_atual
	lh t2, 2(t0) # t2 = y_atual

	# Calcula a posição Y futura
	add t2, t2, s10 

	# Converte coordenadas de pixel para coordenadas de mapa de colisao
	srli t1, t1, 4
	srli t2, t2, 4

	# Calcula o endereço da celula no mapa de colisao
	la t3, mapa_de_colisao

	li t4, 19 # t4 = largura do mapa (19 celulas)
	mul t5, t2, t4 # t5 = y_mapa * largura_mapa
	add t5, t5, t1 # t5 = (y_mapa * largura_mapa) + x_mapa

	slli t5, t5, 1 # t5 = t5 * 2 
	add t3, t3, t5 # t3 = endereço da celula no mapa de colisao

	# Carrega o valor da celula do mapa de colisao
	lh t6, 0(t3) # t6 = valor da celula

	# Verifica se há colisao (valor != 0)
	bne t6, zero, COLISAO_VERTICAL_OCORREU

	# Não houve colisao
	li a7, 0
	j FIM_VERIFICA_COLISAO_VERTICAL

COLISAO_VERTICAL_OCORREU:
	li a7, 1

FIM_VERIFICA_COLISAO_VERTICAL:
	# Restaura registradores salvos
	lw ra, 0(sp)
	lw s11, 4(sp)
	lw s10, 8(sp)
	lw s9, 12(sp)
	addi sp, sp, 16

	ret	
	
PRINT_HARD_BLOCKS:
	addi sp, sp, -4     # reserva espaço na pilha
    	sw ra, 4(sp)         # salva return address

loop_phb:
	li a3, 0
	call PRINT
	li a3, 1
	call PRINT

	addi a1, a1, 32
	
	li t4, 288

	# Fica preso nesse loop até a coluna chegar na largura d
	blt a1, t4, loop_phb
	
	li a1, 40
	
	li t5, 224
	
	# Fica preso nesse loop até linha chegar na altura da imagem
	addi a2, a2, 32
	bgt t5, a2, loop_phb

	li a2, 32
	
	lw ra, 4(sp)         # restaura return address
    	addi sp, sp, 4     # desloca o stack pointer
		
	ret
	
PRINT_SOFT_BLOCKS:
	addi sp, sp, -4     # reserva espaço na pilha
    	sw ra, 4(sp)         # salva return address

loop_psb:
	# Acha o resto da divisão da largura (largura - 40) e altura (altura  - 32) por 32
	# Executa um or com esses restos e se ambas altura e largura forem divisiveis por 32, não printa o soft block
	# Isso é necessário para que ele não seja printado em cima do hardblock
	li t1, 40
	sub t1, a1, t1

	li t0, 32
	rem t0, t1, t0

	li t2, 32
	sub t2, a2, t2

	li t1, 32
	rem t1, t2, t1
	
	or t0, t1, t0
	beq t0, zero, skip
	
	
	# Pega um número aleatório entre 0 e 4 e printa o softblock apenas se esse número for 0
	# Isso é necessário para manter a aleatoriedade dos blocos que aparecem
	# É necessário fazer uma forma mais organica disso. 
	# Creio que seja necessário considerar a aleatoriedade ao redor de cada hardblock e não em todo o mapa discriminadamente
	# Cada hardblock tem 4/5 de chance de printar 1 ou 2 softblock aleatoriamente ao seu redor por exemplo
	
	mv t4, a0
	mv t5, a1  

	li a1, 4
	li a7, 42
	ecall
	mv t1, a0
	
	mv a0, t4
	mv a1, t5
	
	bne t1, zero, skip
	
	li a3, 0
	call PRINT
	li a3, 1
	call PRINT

skip:	addi a1, a1, 16
	
	li t4, 296

	# Fica preso nesse loop até a coluna chegar na largura d
	blt a1, t4, loop_psb
	
	li a1, 24
	
	li t5, 224
	
	# Fica preso nesse loop até linha chegar na altura da imagem
	addi a2, a2, 16
	bgt t5, a2, loop_psb

	li a2, 16
	
	lw ra, 4(sp)         # restaura return address
    	addi sp, sp, 4     # desloca o stack pointer
		
	ret


.data
BOMBER_POS: .half 24, 16
OLD_BOMBER_POS: .half 24, 16
.include "images/chao_do_mapa.data"
.include "images/mapa_fase1.data"
.include "images/hard_block.data"
.include "images/soft_block.data"
.include "images/tijolo_16x16.data"
.include "images/mapa_de_colisao.data"

.include "images/otaviano.data"
.include "images/frogger.data"


		

