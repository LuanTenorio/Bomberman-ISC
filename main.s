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
	la a0, otaviano
	li a1, 0
	li a2, 0
	li a3, 0
	call PRINT
	li a3, 1
	call PRINT
	
GAME_LOOP: 
	# Importante chamar o INPUT antes de tudo, pois ele define os parâmetros do que irá ser printado
	call INPUT

	# Inverte o frame (trabalharemos com o frame escondido enquanto o seu oposto é mostrado)
	xori s0, s0, 1

	call PRINT
	
	# Altera o frame mostrado
	li t0, 0xFF200604
	sw s0, 0(t0)
	
	j GAME_LOOP

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

.data
.include "images/otaviano.data"
.include "images/frogger.data"


		

