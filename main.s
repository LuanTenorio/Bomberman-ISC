.data
	IMAGE_ORIGINAL: .word 0, 0, 0 # Guarda o endereço da imagem e posições iniciais x e y respectivamente

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
	call PRINT_HARD_BLOCKS # Quando cada hardblock é printado, o softblock é pintado junto
	
	
GAME_LOOP: 
	# Importante chamar o INPUT antes de tudo, pois ele define os parâmetros do que irá ser printado
	call INPUT

	# Inverte o frame (trabalharemos com o frame escondido enquanto o seu oposto é mostrado)
	xori s0, s0, 1

#	call PRINT
	
	# Altera o frame mostrado
	li t0, 0xFF200604
	sw s0, 0(t0)
	
	j GAME_LOOP
	
	
# Nesse procedimento, ele checa se o teclado foi apertado e se o 'o' ou 'f' foi a tecla apertada
# Se for uma dessas duas opções, ele muda a imagem mostrada para a otaviano ou frogger respectivamente
INPUT:
	li t1,0xFF200000		
	lw t0,0(t1)			
	andi t0,t0,0x0001		
	beq t0, zero, FIM
	lw t2, 4(t1)
	
	# Para alterar o que ele faz quando houve uma tecla, basta mudar esses parâmetros e procedimentos chamados					
	li t0, 'o'
	beq t2, t0, IMG_OTAVIANO
	
	li t0, 'f'
	beq t2, t0, IMG_FROGGER
	
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
	
PRINT_HARD_BLOCKS:
	# Esses comandos são necessários para que funções que chamem funções funcionem corretamente
	addi sp, sp, -4     # reserva espaço na pilha
    	sw ra, 4(sp)         # salva return address

loop_phb:
	# Printa o hardblock na posição a1 (x) e a2 (y) inicial
	li a3, 0
	call PRINT 
	li a3, 1
	call PRINT

	# Printa o softblock ao redor do hardblock
	
	# É necessário guardar esses valores na memória, pois para printar o softblock eles também são necessários
	la t0, IMAGE_ORIGINAL
	sw a0, 0(t0)
	sw a1, 4(t0)
	sw a2, 8(t0)

	call PRINT_SOFT_BLOCKS

	# Retornar os parâmetros originais
	la t0, IMAGE_ORIGINAL
	lw a0, 0(t0)
	lw a1, 4(t0)
	lw a2, 8(t0)

	addi a1, a1, 32
	
	li t4, 288

	# Fica preso nesse loop até a coluna chegar na largura do background - 32
	blt a1, t4, loop_phb
	
	li a1, 40
	
	li t5, 224
	
	# Fica preso nesse loop até linha chegar na altura do background - 16
	addi a2, a2, 32
	bgt t5, a2, loop_phb

	li a2, 32
	
	lw ra, 4(sp)         # restaura return address
    	addi sp, sp, 4     # desloca o stack pointer
		
	ret
	
PRINT_SOFT_BLOCKS:
	# Seta os parâmetros inicias necessários para printar o softblock
	la a0, soft_block
	li t0, 16
	sub a1, a1, t0
	sub a2, a2, t0 
	
	addi sp, sp, -4     # reserva espaço na pilha
    	sw ra, 4(sp)         # salva return address

loop_psb:
	# Código para printar o softblock ao redor do hardblock

	# Primeiro verifica se o softbloco a ser printado não está na mesma posição do hardblock. Se estiver na mesma posição, não printa
	la t0, IMAGE_ORIGINAL
	lw t1, 4(t0)

	lw t2, 8(t0)

	xor t1, a1, t1
	xor t2, a2, t2

	or t1, t1, t2

	beq t1, zero, skip
	
	# Código que decide se o softblock será printado ou não
	# Ele pega um número entr 0 e 8 e se for 0 ele printa
	
	# É necessário guardar os valores em a0 (endereço da imagem a ser printado) e a1 (coordenada x da imagem a ser printada)
	# pois o ecall usa eles
	mv t4, a0 
	mv t5, a1  

	li a1, 8
	li a7, 42
	ecall
	mv t1, a0
	
	mv a0, t4
	mv a1, t5
	
	bne t1, zero, skip
	
	# Printa os softblock
	li a3, 0
	call PRINT
	li a3, 1
	call PRINT

skip:	
	addi a1, a1, 16

	# Pega a coordenada x do hardblock, subtrai 16 e soma 48.
	# Se a coordenada x do softblock a ser printado for igual a esse número, passa para a próxima linha
	# Isso é importante para delimitar a área de print do softblock como sendo no quadro 3x3 blocos de centro no hardblock
	la t0, IMAGE_ORIGINAL
	lw t0, 4(t0)
	li t4, 16
	sub t0, t0, t4

	addi t4, t0, 48

	blt a1, t4, loop_psb
	
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
	bgt t5, a2, loop_psb

	la t0, IMAGE_ORIGINAL
	lw a2, 8(t0)
	
	lw ra, 4(sp)         # restaura return address
    	addi sp, sp, 4     # desloca o stack pointer
	ret


.data
.include "images/mapa_fase1.data"
.include "images/hard_block.data"
.include "images/soft_block.data"
.include "images/tijolo_16x16.data"

.include "images/otaviano.data"
.include "images/frogger.data"


		

