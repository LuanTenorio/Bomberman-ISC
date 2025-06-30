.data
	IMAGE_ORIGINAL: .word 0, 0, 0 # Guarda o endereço da imagem e posições iniciais x e y respectivamente
	
	CONTADOR_MUSICA: .word 0
	
	#Posições iniciais do bomberman 
	BOMBER_POS: .half 24, 48
	OLD_BOMBER_POS: .half 24, 48

	BOMBER_VIDA: .byte 3
	
	PONTUACAO: .word 0, 0 	# 1º pontuação, 2º espaço auxiliar

# s11 = guarda o tempo para a Música
#
# --- Contexto dos argumentos passados para as funções PRINT
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
	call PRINT_HARD_BLOCKS # Quando cada hardblock é printado, o softblock é pintado junto
	
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

	# O personagem move de acordo com o input
	call INPUT

	# Inverte o frame (trabalharemos com o frame escondido enquanto o seu oposto é mostrado)
skip_gl:	
	xori s0, s0, 1

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
	
	li t0, 'd'
	beq t2, t0, MOVE_DIREITA
	
	li t0, 'a'
	beq t2, t0, MOVE_ESQUERDA
	
	li t0, 'w'
	beq t2, t0, MOVE_CIMA
	
	li t0, 's'
	beq t2, t0, MOVE_BAIXO
	
FIM: 	ret

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
	
	lw ra, 4(sp)       # restaura return address
    	addi sp, sp, 4     # desloca o stack pointer
    	
    	ret
	
#PRINT_HARD_BLOCKS:
	# Esses comandos são necessários para que funções que chamem funções funcionem corretamente
#	addi sp, sp, -4      # reserva 16 bytes (mesmo que só vá usar 4)
#	sw ra, 0(sp)         # salva ra no topo da área alocada

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
	
	lw ra, 0(sp)         # restaura ra
	addi sp, sp, 4       # libera os 16 bytes da stack
	ret
		
	ret
	
PRINT_SOFT_BLOCKS:
	# Seta os parâmetros inicias necessários para printar o softblock
	la a0, soft_block
	li t0, 16
	sub a1, a1, t0
	sub a2, a2, t0 
		
	addi sp, sp, -4      # reserva 16 bytes (mesmo que só vá usar 4)
	sw ra, 0(sp)         # salva ra no topo da área alocada
	
loop_psb:
	# Código para printar o softblock ao redor do hardblock

	# Primeiro verifica se o softbloco a ser printado não está na mesma posição do hardblock. Se estiver na mesma posição, não printa
	la t0, IMAGE_ORIGINAL
	lw t1, 4(t0)

	lw t2, 8(t0)

	xor t1, a1, t1
	xor t2, a2, t2

	or t1, t1, t2

	beq t1, zero, skip_psb
	
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
	
	bne t1, zero, skip_psb
	
	# Printa os softblock
	li a3, 0
	call PRINT
	li a3, 1
	call PRINT

skip_psb:	
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
	
	lw ra, 0(sp)         # restaura ra
	addi sp, sp, 4       # libera os 16 bytes da stack
	ret
	
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
	
	
PRINT_CARACTERE:
	addi sp, sp, -4      # reserva 4 bytes  no stack pointer
	sw ra, 0(sp)         # salva ra no topo da área alocada	
	
	li a0, 0	
		
	li t0, 0
	beq a4, t0, print_0
	
	li t0, 1
	beq a4, t0, print_1
	
	li t0, 2
	beq a4, t0, print_2
	
	li t0, 3
	beq a4, t0, print_3
	
	li t0, 4
	beq a4, t0, print_4
	
	li t0, 5
	beq a4, t0, print_5
	
	li t0, 6
	beq a4, t0, print_6
	
	li t0, 7
	beq a4, t0, print_7
	
	li t0, 8
	beq a4, t0, print_8
	
	li t0, 9
	beq a4, t0, print_9

print_0:
	la a0, alg_zero
	j fim_pc	

print_1:
	la a0, alg_um
	j fim_pc
	
print_2:
	la a0, alg_dois
	j fim_pc
	
print_3:
	la a0, alg_tres
	j fim_pc
	
print_4:
	la a0, alg_quatro
	j fim_pc
	
print_5:
	la a0, alg_cinco
	j fim_pc							

print_6:
	la a0, alg_seis
	j fim_pc
	
print_7:
	la a0, alg_sete
	j fim_pc
	
print_8:
	la a0, alg_oito
	j fim_pc
	
print_9:
	la a0, alg_nove
	j fim_pc
	
fim_pc:
	beq a0, zero, fim_pc2
	li a3, 0
	call PRINT
	li a3, 1
	call PRINT

fim_pc2:
	lw ra, 0(sp)         # restaura ra
	addi sp, sp, 4       # libera os 4 bytes da stack
	ret

# ============================
# Função principal de controle da música
# ============================
TOCAR_MUSICA:
    li a7, 30
    ecall                  # a0 ← tempo atual
	
	addi sp, sp, -4      # reserva 16 bytes (mesmo que só vá usar 4)
	sw ra, 0(sp)         # salva ra no topo da área alocada

    la t2, CONTADOR_MUSICA
    lw t2, 0(t2)           # t2 ← índice da nota atual

    la a5, NOTAS
    li t4, 8
    mul t3, t2, t4
    add a5, a5, t3         # a5 ← endereço da nota atual

    bltu a0, s11, skip_tm  # se a0 < s11, ainda não é hora → sai
    call tocar_nota        # senão, toca a nota

skip_tm:
	lw ra, 0(sp)         # restaura ra
	addi sp, sp, 4       # libera os 16 bytes da stack
    ret

# ============================
# Função que toca uma nota
# ============================
tocar_nota:
    addi sp, sp, -4        # reserva espaço na pilha
    sw ra, 0(sp)           # salva ra da função atual

    la t0, NUM_NOTAS
    lw t0, 0(t0)

    la t2, CONTADOR_MUSICA
    lw t2, 0(t2)

    bne t2, t0, tocar
    li t2, 0
    la t5, CONTADOR_MUSICA
    sw t2, 0(t5)

    la a5, NOTAS
    li t4, 8
    mul t3, t2, t4
    add a5, a5, t3

tocar:
    lw a0, 0(a5)
    lw a1, 4(a5)
    li a2, 30
    li a3, 127
    li a7, 31
    ecall

    la t0, CONTADOR_MUSICA
    lw t2, 0(t0)
    addi t2, t2, 1
    sw t2, 0(t0)

    li a7, 30
    ecall
    mv s11, a0
    lw t3, 4(a5)
    add s11, s11, t3

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

.data
.include "images/chao_do_mapa.data"
.include "images/mapa_fase1.data"
.include "images/hard_block.data"
.include "images/soft_block.data"
.include "images/tijolo_16x16.data"
.include "images/mapa_de_colisao.data"
.include "images/vida.data"
.include "images/algarismos.data"

.include "images/alg_zero.data"
.include "images/alg_um.data"
.include "images/alg_dois.data"
.include "images/alg_tres.data"
.include "images/alg_quatro.data"
.include "images/alg_cinco.data"
.include "images/alg_seis.data"
.include "images/alg_sete.data"
.include "images/alg_oito.data"
.include "images/alg_nove.data"

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


		

