# ============================
# Funções primárias do jogo
# ============================
#	- SET_HARD_BLOCKS
#	- SET_SOFT_BLOCKS	
#	- VERIFICAR_VIDA
#	- PRINT_PONTUACAO

.data
.include "../images/mapa/vida.data"

# IMPORTS:
.include "print_caractere.s" 		# Contêm função de imprimir caractere

# ============================
# Funções para setar os blocos indestrutíveis na matriz de colisão
# ============================
# Argumentos:
#	- a0 = endereço da imagem
#   - a1 = x
#	- a2 = y
# 	- a3 = frame (0 ou 1)
#  	- a4 = tipo de bloco (1 = hardblock, 2 = softblock)
.text
SET_HARD_BLOCKS:
	# Esses comandos são necessários para que funções que chamem funções funcionem corretamente
	addi sp, sp, -4      # reserva 16 bytes (mesmo que só vá usar 4)
	sw ra, 0(sp)         # salva ra no topo da área alocada

loop_shb:
	# # Printa o hardblock na posição a1 (x) e a2 (y) inicial
	# li a3, 0
	# call PRINT 
	# li a3, 1
	# call PRINT

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
	# li a3, 0
	# call PRINT
	# li a3, 1
	# call PRINT

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
# Função para renderizar o a imagem em a0 do que estiver no mapa de colisão 
# ============================
# Percorre apenas o quadrado formado pelas coordenadas:
# (1, 3) (18, 3) (1, 13) (18, 13)
#
# Argumentos:
#		- a0 = endereço da imagem 	
#		- a4 = tipo de bloco (1 = hardblock, 2 = softblock)
#
RENDERIZAR_MAPA_COLISAO:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)    # salva registradores que serão usados
    sw s1, 8(sp)
    sw s2, 12(sp)
    
    li s0, 1        # x inicial
    li s1, 3        # y inicial
    li s2, 18       # x final (exclusive)
    li s3, 14       # y final (exclusive)
    
loop_y:
    li s0, 1
    
loop_x:
    # Aqui você pode processar cada posição (t2, t1)
    # Exemplo: calcular endereço na matriz
    la t3, mapa_de_colisao
    li t4, 19               # largura da matriz
    mul t5, s1, t4          # y * largura
    add t5, t5, s0          # (y * largura) + x
	mv t0, t5				
    slli t5, t5, 1          # * 2 (pois são half words)
    add t3, t3, t5          # endereço final
    
    # Exemplo de operação: ler valor atual
    lh t6, 0(t3)

	bne t6, a4, skip_print_hb  # se não for hard block, pula


	li t4, 16
	mul t0, t0, t4          # converte para pixels (multiplica por 16)
	addi t5, s1, 1
	mul t5, t5, t4          
	add t0, t0, t5         
	addi t0, t0, -8

	mv a1, t0
	li t4, 15
	mul a2, s1, t4

	li a3, 0
	call PRINT
	li a3, 1
	call PRINT

    # Aqui você pode fazer o que precisar com a posição (t2, t1)
    # Por exemplo, chamar uma função que processa cada célula
   
skip_print_hb:
    addi s0, s0, 1 # próximo x
    blt s0, s2, loop_x      # continua se x < 16
    
    addi s1, s1, 1          # próximo y
    blt s1, s3, loop_y      # continua se y < 13
    
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

# ============================
# Função responsável por printar qualquer mapa
# ============================
# Argumentos:
#	- a0 = endereço da imagem
PRINT_MAPA:
	addi sp, sp, -4      # reserva 4 bytes  no stack pointer
	sw ra, 0(sp)         # salva ra no topo da área alocada

	li a1, 0
	li a2, 0
	li a3, 0
	call PRINT


	lw ra, 0(sp)         # restaura ra
	addi sp, sp, 4       # libera os 4 bytes da stack
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

# ============================
# Função responsável por printar o bomberman
# ============================
# A função printa o bomberman na posição atual e limpa a posição antiga
PRINT_BOMBERMAN:
	addi sp, sp, -4     # reserva espaço na pilha
    sw ra, 0(sp)         # salva return address
    	
	
	#Carrega o bomberman
	la t0, BOMBER_POS
	la a0, tijolo_16x16
	lh a1, 0(t0)
	lh a2, 2(t0)
	mv a3, s0
	call PRINT
	xori a3, a3, 1
	call PRINT
	
	#limpa o frame
	#Carrega o bomberman
	la t0, OLD_BOMBER_POS
	la a0, chao_do_mapa
	lh a1, 0(t0)
	lh a2, 2(t0)
	mv a3, s0
	call PRINT
	xori a3, a3, 1
	call PRINT
	
	lw ra, 0(sp)       # restaura return address
    addi sp, sp, 4     # desloca o stack pointer
    	
    ret

# ============================
# Função responsável por atualizar a matriz de colisão
# ============================
# A função recebe as coordenadas em pixels (a1, a2) e o valor a ser escrito na matriz de colisão em a4.
ATUALIZA_MAPA_COLISAO:
	addi sp, sp, -4
	sw ra, 0(sp) 

	# converte coordenadas de pixel para coordenadas da matriz (divisão por 16)
	srli t0, a1, 4  # x_map / 16
	srli t1, a2, 4  # y_map / 16

	# calcula o endereco na matriz de colisao (EnderecoBase + (y_map * largura + x_map) * 2)
	la t2, mapa_de_colisao # endereco base da matriz
	li t3, 19              # largura da matriz
	
	mul t1, t1, t3          # y_map * largura
	add t0, t0, t1          # (y_map * largura) + x_map
	
	slli t0, t0, 1           # distancia em bytes
	add t2, t2, t0          # endereco final da célula na matriz

	# atualiza a matriz com o valor passado em a4.
	sh a4, 0(t2)

	lw ra, 0(sp)        
	addi sp, sp, 4	   

	ret
