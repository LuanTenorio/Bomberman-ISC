.data
	quebraLinha: .string "\n"

.text
# ============================
# Funções auxiliares do jogo
# ============================	
#	- PRINT
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
