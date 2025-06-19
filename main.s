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

SETUP_MUSICA:
    la t0, NUM_NOTAS   # endereço da quantidade de notas
    lw t0, 0(s0)       # lê o número de notas
    la t1, NOTAS       # endereço das notas
    li t2, 0           # contador de notas
    li t3, 30          # instrumento: guitar
    li t4, 127         # volume máximo

MUSICA_LOOP:
    beq t2, t0, fim    # fim da música?
    lw a0, 0(t1)       # carrega nota MIDI
    lw a1, 4(t1)      # carrega duração
    li a7, 31          # syscall 31: toca nota
    ecall

    mv a0, a1          # pausa = duração da nota
    li a7, 32          # syscall 32: espera
    ecall

    addi t1, t1, 8     # próxima nota
    addi t2, t2, 1     # incrementa contador
    j MUSICA_LOOP

fim:
    li a7, 10          # syscall 10: finaliza
    ecall


.data
.include "images/mapa_fase1.data"
.include "images/hard_block.data"
.include "images/soft_block.data"
.include "images/tijolo_16x16.data"

.include "images/otaviano.data"
.include "images/frogger.data"

# Número de notas (cada par nota+duração = 1 nota lógica)
NUM_NOTAS: .word 56

# Tema principal + repetição com variações
NOTAS:
.word 76,300, 76,300, 84,300, 84,300, 
      83,300, 83,300, 81,300, 81,300,
      79,400, 79,200, 81,400, 79,400,
      76,400, 76,400, 0,600, 76,300,
      81,300, 81,300, 79,300, 79,300,
      77,300, 77,300, 76,300, 76,300,
      74,400, 74,200, 76,400, 74,400,
      72,400, 72,400, 0,600, 76,300,

      76,300, 76,300, 76,300, 76,300,
      79,300, 79,300, 81,600, 0,400


		

