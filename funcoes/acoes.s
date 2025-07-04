# ============================
# Funções de ações do personagem
# ============================
#	- Funções de movimento
#  	- Funções de colisão

.text
MOVE_ESQUERDA:
	li s10, -16
	j MOVE_HORIZONTAL
	
MOVE_DIREITA:
	li s10, 16
	j MOVE_HORIZONTAL
	
#s10 eh o argumento da direção
MOVE_HORIZONTAL:
	addi sp, sp, -4     # reserva espaço na pilha
    	sw ra, 0(sp)         # salva return address
    	
	#carrega e altera a posição antiga do bomber
	la t0, BOMBER_POS # carreaga a posição atual no mapa de pixeis
	la t1, OLD_BOMBER_POS
	lw t2, 0(t0)
	sw t2, 0(t1)

	call VERIFICA_COLISAO_HORIZONTAL

	li a1, 1 # Se a7 for 1, houve colisão
	beq a7, a1, FIM_MOVIMENTO_HORIZONTAL
  
	#soma e atualiza a posição
	lh a1, 0(t0)
	add a1, a1, s10
	sh a1, 0(t0)
	
	call PRINT_BOMBERMAN

FIM_MOVIMENTO_HORIZONTAL:
	lw ra, 0(sp)       # restaura return address
    	addi sp, sp, 4     # desloca o stack pointer
	
	ret

VERIFICA_COLISAO_HORIZONTAL:
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
    	sw ra, 0(sp)         # salva return address
    	
	#carrega e altera a posição antiga do bomber
	la t0, BOMBER_POS # carreaga a posição atual no mapa de pixeis
	la t1, OLD_BOMBER_POS
	lw t2, 0(t0)
	sw t2, 0(t1)

	call VERIFICA_COLISAO_VERTICAL # Chama a função de verificação de colisão vertical

	li a1, 1 # Se a7 for 1, houve colisão
	beq a7, a1, FIM_MOVIMENTO_VERTICAL

	#soma e atualiza a posição
	lh t1, 2(t0)
	add t1, t1, s10
	sh t1, 2(t0)
	
	call PRINT_BOMBERMAN
	
FIM_MOVIMENTO_VERTICAL:
	lw ra, 0(sp)       # restaura return address
    	addi sp, sp, 4     # desloca o stack pointer

	ret
	
VERIFICA_COLISAO_VERTICAL:
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
	ret	