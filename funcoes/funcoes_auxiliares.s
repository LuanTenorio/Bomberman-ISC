.data
	quebraLinha: .string "\n"

.text
# ============================
# Funções auxiliares do jogo
# ============================	
#	- PRINT
# 	- PRINT_TRANSPARENTE
# 	- INPUT
#	- PRINT_DEGUB
# 	- PRINT_QUEBRA

# ============================
# Funções que pega a tecla pressionada e coloca em a0
# ============================	
INPUT:
	li t1,0xFF200000		
	lw t0,0(t1)			
	andi t0,t0,0x0001		
	beq t0, zero, FIM
	lw a0, 4(t1)

FIM: 	ret

# ============================
# Funções que printa qualquer imagem
# ============================	
# Argumentos:
#	a0 = endereço imagem (com tudo, pixeis e metadados)
#	a1 = x
#	a2 = y
#	a3 = frame (0 ou 1)
#
## --- Contexto da função PRINT
#	t0 = endereço do bitmap display
#	t1 = endereço da imagem (só pixel)
#	t2 = contador de linha
#	t3 = contador de coluna
#	t4 = largura
# 	t5 = altura
#
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


# ============================
# Funções que printa qualquer imagem com uma cor sendo considerada como transparente
# ============================	
# Argumentos:
#	a0 = endereço imagem (com tudo, pixeis e metadados)
#	a1 = x
#	a2 = y
#	a3 = frame (0 ou 1)
#	a5 = cor (em 8 bits) que será a transparente
#
## --- Contexto da função PRINT
#	t0 = endereço do bitmap display
#	t1 = endereço da imagem (só pixel)
#	t2 = contador de linha
#	t3 = contador de coluna
#	t4 = largura
# 	t5 = altura
#

PRINT_TRANSPARENTE:
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
	# Busca 1 pixel da imagem e coloca no endereço de vídeo
	lb t6, 0(t1)
	beq t6, a5, skip_pl
	sb t6, 0(t0)

skip_pl:
	addi t0, t0, 1
	addi t1, t1, 1
	
	# Fica preso nesse loop até a coluna chegar na largura da imagem
	addi t3, t3, 1  
	blt t3, t4, PRINT_LINHA
	
	# Pula para a próxima linha
	addi t0, t0, 320
	sub t0, t0, t4
	
	# Fica preso nesse loop até linha chegar na altura da imagem
	mv t3, zero
	addi t2, t2, 1
	bgt t5, t2, PRINT_LINHA

	ret


PRINT_DEGUB:
    	addi sp, sp, -4        # reserva espaço na pilha
    	sw ra, 0(sp)           # salva ra da função atual

	la t0, IMAGE_ORIGINAL
	sw a0, 0(t0)
	sw a1, 4(t0)
	sw a2, 8(t0)
	sw a3, 12(t0)
	sw a4, 16(t0)
	
	call PRINT_INT
	call PRINT_QUEBRA
	
	la t0, IMAGE_ORIGINAL
	lw a0, 0(t0)
	lw a1, 4(t0)
	lw a2, 8(t0)
	lw a3, 12(t0)
	lw a4, 16(t0)

	lw ra, 0(sp)         # restaura ra
	addi sp, sp, 4       # libera os 16 bytes da stack
    	ret
    	
PRINT_INT:
	li a7, 1
	ecall
	ret
	
PRINT_QUEBRA:
	li a7, 4
	la a0, quebraLinha
	ecall
	ret


TRANSFORMA_COORDENADAS:
	addi sp, sp, -4     # reserva espaço na pilha
	sw ra, 0(sp)

	mv t1, a5
	mv t2, a6

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

	mv a5, t3

	lw ra, 0(sp)
	addi sp, sp, 4     # desloca o stack pointer
	ret


# Recebe o a0 e converte ele na imagem correspondente a partir do IMAGENS_ID_...
SELECIONA_IMAGEM_PELO_MAPA:
	addi sp, sp, -4
	sw ra, 0(sp)

    mv t4, a0 # Salva o ID da imagem em t4

	# Pega o mapa atual e subtrai 1 pra usar como índice
    la   t0, MAPA_ATUAL
    lw   t1, 0(t0)
    addi t1, t1, -1
    slli t1, t1, 2

	# Pega o endereço base da tabela de mapas
    la   t2, MAPAS
    add  t2, t2, t1
    lw   t5, 0(t2)

    # Com a tabela da fase correta em t5, busca a imagem pelo ID
    slli t0, t4, 2
    add  t1, t5, t0
    lw   a0, 0(t1)

	lw ra, 0(sp)
	addi sp, sp, 4     # desloca o stack pointer
    ret

SORTEAR_FASE:
	addi sp, sp, -4
	sw ra, 0(sp)

	li a1, 2
	li a7, 42
	ecall

	addi a0, a0, 1

	la t0, MAPA_ATUAL
	sw a0, 0(t0)

	lw ra, 0(sp)
	addi sp, sp, 4     # desloca o stack pointer
    ret