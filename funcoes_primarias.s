# ============================
# Funções primárias do jogo
# ============================
#	- SET_HARD_BLOCKS
#	- SET_SOFT_BLOCKS	
#	- VERIFICAR_VIDA
#	- PRINT_PONTUACAO


# IMPORTS:
.include "print_caractere.s" 		# Contêm função de imprimir caractere

# ============================
# Funções para setar os blocos indestrutíveis na matriz de colisão
# ============================
.text
SET_HARD_BLOCKS:
	# Esses comandos são necessários para que funções que chamem funções funcionem corretamente
	addi sp, sp, -4      # reserva 16 bytes (mesmo que só vá usar 4)
	sw ra, 0(sp)         # salva ra no topo da área alocada

loop_shb:
	# Printa o hardblock na posição a1 (x) e a2 (y) inicial
	li a3, 0
	call PRINT 
	li a3, 1
	call PRINT

	li a4, 1  # argumento de bloco indestrutivel
	call ATUALIZA_MAPA_COLISAO

	# Printa o softblock ao redor do hardblock
	
	# É necessário guardar esses valores na memória, pois para printar o softblock eles também são necessários
	la t0, IMAGE_ORIGINAL
	sw a0, 0(t0)
	sw a1, 4(t0)
	sw a2, 8(t0)

	call SET_SOFT_BLOCKS

	# Retornar os parâmetros originais
	la t0, IMAGE_ORIGINAL
	lw a0, 0(t0)
	lw a1, 4(t0)
	lw a2, 8(t0)

	addi a1, a1, 32
	
	li t4, 288

	# Fica preso nesse loop até a coluna chegar na largura do background - 32
	blt a1, t4, loop_shb
	
	li a1, 40
	
	li t5, 224
	
	# Fica preso nesse loop até linha chegar na altura do background - 16
	addi a2, a2, 32
	bgt t5, a2, loop_shb

	li a2, 32
	
	lw ra, 0(sp)         # restaura ra
	addi sp, sp, 4       # libera os 16 bytes da stack
	ret
		
	ret
	
# ============================
# Funções para setar os blocos destrutíveis na matriz de colisão
# ============================
SET_SOFT_BLOCKS:
	# Seta os parâmetros inicias necessários para printar o softblock
	la a0, soft_block
	li t0, 16
	sub a1, a1, t0
	sub a2, a2, t0 
		
	addi sp, sp, -4      # reserva 16 bytes (mesmo que só vá usar 4)
	sw ra, 0(sp)         # salva ra no topo da área alocada
	
loop_ssb:
	# Código para printar o softblock ao redor do hardblock

	# Primeiro verifica se o softbloco a ser printado não está na mesma posição do hardblock. Se estiver na mesma posição, não printa
	la t0, IMAGE_ORIGINAL
	lw t1, 4(t0)

	lw t2, 8(t0)

	xor t1, a1, t1
	xor t2, a2, t2

	or t1, t1, t2

	beq t1, zero, skip_ssb
	
	# Código que decide se o softblock será printado ou não
	# Ele pega um número entr 0 e 8 e se for 0 ele printa
	
	# É necessário guardar os valores em a0 (endereço da imagem a ser printado) e a1 (coordenada x da imagem a ser printada)
	# pois o ecall usa eles
	mv t4, a0 
	mv t5, a1  

	li a1, 6
	li a7, 42
	ecall
	mv t1, a0
	
	mv a0, t4
	mv a1, t5
	
	bne t1, zero, skip_ssb
	
	# Printa os softblock
	li a3, 0
	call PRINT
	li a3, 1
	call PRINT

	li a4, 2  # argumento de bloco destrutivel
	call ATUALIZA_MAPA_COLISAO
  
skip_ssb:	
	addi a1, a1, 16

	# Pega a coordenada x do hardblock, subtrai 16 e soma 48.
	# Se a coordenada x do softblock a ser printado for igual a esse número, passa para a próxima linha
	# Isso é importante para delimitar a área de print do softblock como sendo no quadro 3x3 blocos de centro no hardblock
	la t0, IMAGE_ORIGINAL
	lw t0, 4(t0)
	li t4, 16
	sub t0, t0, t4

	addi t4, t0, 48

	blt a1, t4, loop_ssb
	
	# Restaura o x do softblock a ser printado para o x do hardblock - 16
	la t0, IMAGE_ORIGINAL
	lw a1, 4(t0)	
	li t4, 16
	sub a1, a1, t4

	# Restaurda o x do hardblock, subtrai 16 e soma 48 para encontrar o limite de printa da linha.
	# Mesma razão citada anteriormente
	lw t0, 8(t0)
	li t5, 16
	sub t4, t0, t5

	addi t5, t4, 48
	
	addi a2, a2, 16
	bgt t5, a2, loop_ssb

	la t0, IMAGE_ORIGINAL
	lw a2, 8(t0)
	
	lw ra, 0(sp)         # restaura ra
	addi sp, sp, 4       # libera os 16 bytes da stack
	ret


# ============================
# Função responsável por printar a vida e verificar se ela chegou a zero
# ============================
VERIFICA_VIDA:
	addi sp, sp, -4      # reserva 4 bytes  no stack pointer
	sw ra, 0(sp)         # salva ra no topo da área alocada	
		
	la t0, BOMBER_VIDA
	lb a4, 0(t0)		# Pega vida do bomberman
	
	beq a4, zero, skip_vv	# Se a vida for zero, skipa
	
	# Carrega endereço da imagem da vida e sua posição
	la a0, vida
	li a1, 24
	li a2, 0
	
	li a5, 0 # count do print
	
print_vida:
	li a3, 0
	call PRINT
	li a3, 1
	call PRINT

	addi a1, a1, 20 	# Coloca as coordenada do próximo coração
	addi a5, a5, 1		# Aumenta o count
	bne a5, a4, print_vida
			
skip_vv:
	# Por enquanto não faz nada caso a vida dele chegue a zero

	lw ra, 0(sp)         # restaura ra
	addi sp, sp, 4       # libera os 4 bytes da stack
	ret

# ============================
# Função responsável por printar a pontuacao
# ============================
PRINT_PONTUACAO:
	addi sp, sp, -4      # reserva 4 bytes  no stack pointer
	sw ra, 0(sp)         # salva ra no topo da área alocada	
		
	la t0, PONTUACAO
	lw t1, 0(t0)		# Pega pega a pontuação
	sw t1, 4(t0) 		# Guarda na memória auxiliar para o print
	
	li a1, 280	# Coordenadas iniciais dos números (Da direita para a esquerda)
	li a2, 0
	
loop_pp:	
	la t0, PONTUACAO 	#Carrega pontuação auxiliar
	lw t1, 4(t0)

	li t2, 10
	rem a4, t1, t2
	
	div t1, t1, t2

	sw t1, 4(t0)
	
	call PRINT_CARACTERE
	
	addi a1, a1, -16
	li t0, 200
	bne a1, t0, loop_pp
	
	lw ra, 0(sp)         # restaura ra
	addi sp, sp, 4       # libera os 4 bytes da stack
	ret
	
.data
.include "images/vida.data"