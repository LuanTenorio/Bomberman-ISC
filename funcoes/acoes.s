# ============================
# Funções de ações do personagem
# ============================
#	- Funções de movimento
#  	- Funções de colisão
# 	- SET_BOMBA
#	- VERIFICAR_BOMBA
# 	- APAGAR_BOMBA
#	- EXPLODIR_BOMBA
#	- PRINT_EXPLOSAO

.text
MOVE_ESQUERDA:
	li s10, -16
	
    la   t0, BOMBERMAN_1
    lw   t1, 12(t0) # Carrega o 4 ponteiro da tabela
    la   t2, CURRENT_BOMBER_POSITION_SPRITE 
    sw   t1, 0(t2) # Salva o endereço do sprite

	j MOVE_HORIZONTAL
	
MOVE_DIREITA:
	li s10, 16

# Atualiza o sprite
    la   t0, BOMBERMAN_1
    lw   t1, 4(t0) # Carrega o 2 ponteiro da tabela
    la   t2, CURRENT_BOMBER_POSITION_SPRITE
    sw   t1, 0(t2) # Salva o endereço do sprite
	
	j MOVE_HORIZONTAL
	
#s10 eh o argumento da direção
MOVE_HORIZONTAL:
	addi sp, sp, -4     # reserva espaço na pilha
    sw ra, 0(sp)         # salva return address

	call VERIFICA_COLISAO_HORIZONTAL

	li a1, 1 # Se a7 for 1, houve colisão
	beq a7, a1, FIM_MOVIMENTO_HORIZONTAL
  
	#carrega e altera a posição antiga do bomber
	la t0, BOMBER_POS # carreaga a posição atual no mapa de pixeis

	#soma e atualiza a posição
	lh a1, 0(t0)
	add a1, a1, s10
	sh a1, 0(t0)
	
FIM_MOVIMENTO_HORIZONTAL:
	lw ra, 0(sp)       # restaura return address
    addi sp, sp, 4     # desloca o stack pointer
	ret

VERIFICA_COLISAO_HORIZONTAL:
	addi sp, sp, -4     # reserva espaço na pilha
	sw ra, 0(sp)         # salva return address

	# Carrega a posição atual do bomberman em pixel
	la t0, BOMBER_POS
	lh t1, 0(t0) # t1 = x_atual (pixel)
	lh t2, 2(t0) # t2 = y_atual (pixel)

	# Calcula a posição X futura
	add t1, t1, s10 # t1 = x_futuro (pixel)

	mv a5, t1
	mv a6, t2
	call TRANSFORMA_COORDENADAS
	mv t3, a5 # t3 = endereço da célula no mapa de colisão

	# Carrega o valor da celula do mapa de colisao
	lh t6, 0(t3) # t6 = valor da celula

	# Verifica se há colisao (valor != 0)
	beq t6, zero, skip_vch	# Se a célula for zero, não houve colisão
	li a7, 1 # Houve colisão
	j end_vch

skip_vch:
	li t4, 3
	sh t4, 0(t3) # Move o bomberman para a célula de colisão

	# Carrega a posição atual do bomberman
	la t0, BOMBER_POS
	lh t1, 0(t0) # t1 = x_atual
	lh t2, 2(t0) # t2 = y_atual
	
	mv a5, t1
	mv a6, t2
	call TRANSFORMA_COORDENADAS
	mv t3, a5 # t3 = endereço da célula no mapa de colisão

	li t4, 0
	sh t4, 0(t3) # Limpa a posição antiga do bomberman
	# Não houve colisao
	li a7, 0

end_vch:
	lw ra, 0(sp)       # restaura return address
	addi sp, sp, 4     # desloca o stack pointer
	ret

MOVE_CIMA:
	li s10, -16

	# Atualiza o sprite
    la   t0, BOMBERMAN_1
    lw   t1, 0(t0) # Carrega o 1 ponteiro da tabela
    la   t2, CURRENT_BOMBER_POSITION_SPRITE
    sw   t1, 0(t2) # Salva o endereço do sprite

	j MOVE_VERTICAL
	
MOVE_BAIXO:
	li s10, 16

	# Atualiza o sprite
    la   t0, BOMBERMAN_1
    lw   t1, 8(t0) # Carrega o 3 ponteiro da tabela
    la   t2, CURRENT_BOMBER_POSITION_SPRITE
    sw   t1, 0(t2) # Salva o endereço do sprite

	j MOVE_VERTICAL
	
#s10 eh o argumento da direção
MOVE_VERTICAL:
	addi sp, sp, -4     # reserva espaço na pilha
    sw ra, 0(sp)         # salva return address
    	
	call VERIFICA_COLISAO_VERTICAL # Chama a função de verificação de colisão vertical

	li a1, 1 # Se a7 for 1, houve colisão
	beq a7, a1, FIM_MOVIMENTO_VERTICAL

	#carrega e altera a posição antiga do bomber
	la t0, BOMBER_POS # carreaga a posição atual no mapa de pixeis

	#soma e atualiza a posição
	lh t1, 2(t0)
	add t1, t1, s10
	sh t1, 2(t0)		

FIM_MOVIMENTO_VERTICAL:
	lw ra, 0(sp)       # restaura return address
    addi sp, sp, 4     # desloca o stack pointer
	ret
	
VERIFICA_COLISAO_VERTICAL:
	addi sp, sp, -4     # reserva espaço na pilha
	sw ra, 0(sp)         # salva return address

	# Carrega a posição atual do bomberman em pixel
	la t0, BOMBER_POS
	lh t1, 0(t0) # t1 = x_atual (pixel)
	lh t2, 2(t0) # t2 = y_atual (pixel)

	# Calcula a posição X futura
	add t2, t2, s10 # t2 = y_futuro (pixel)

	mv a5, t1
	mv a6, t2
	call TRANSFORMA_COORDENADAS
	mv t3, a5 # t3 = endereço da célula no mapa de colisão

	# Carrega o valor da celula do mapa de colisao
	lh t6, 0(t3) # t6 = valor da celula

	# Verifica se há colisao (valor != 0)
	beq t6, zero, skip_vcv	# Se a célula for zero, não houve colisão
	li a7, 1 # Houve colisão
	j end_vcv

skip_vcv:
	li t4, 3
	sh t4, 0(t3) # Move o bomberman para a célula de colisão

	# Carrega a posição atual do bomberman
	la t0, BOMBER_POS
	lh t1, 0(t0) # t1 = x_atual
	lh t2, 2(t0) # t2 = y_atual
	
	mv a5, t1
	mv a6, t2
	call TRANSFORMA_COORDENADAS
	mv t3, a5 # t3 = endereço da célula no mapa de colisão

	li t4, 0
	sh t4, 0(t3) # Limpa a posição antiga do bomberman
	# Não houve colisao
	li a7, 0

end_vcv:
	lw ra, 0(sp)       # restaura return address
	addi sp, sp, 4     # desloca o stack pointer
	ret

# ============================
# Função responsável por colocar uma bomba no mapa de colisão
# ============================
# Usa a posição atual do bomberman para colocar a bomba
SET_BOMBA:
	addi sp, sp, -4     # reserva espaço na pilha
	sw ra, 0(sp)         # salva return address

	la t0, BOMBA
	lw t1, 8(t0) # t1 = Tempo de auxilio para a bomba

	li a7, 30
	ecall

	blt a0, t1, skip_set_bomba # Se a0 for menor que t1, não coloca bomba

	li a7, 30
	ecall

	lw t1, 4(t0) # t1 = intervalo da bomba (ms)
	add t1, a0, t1 # Adiciona o intervalo ao tempo atual 
	sw t1, 8(t0) # Atualiza o tempo da bomba

	la t0, BOMBER_POS
	lh t1, 0(t0) # t1 = x_atual
	lh t2, 2(t0) # t2 = y_atual
	
	mv a5, t1
	mv a6, t2
	call TRANSFORMA_COORDENADAS
	mv t3, a5

	# Carrega o valor da celula do mapa de colisao
	li t6, 4 # Valor da bomba no mapa de colisão
	sh t6, 0(t3) # t6 = valor da celula

	la t0, BOMBER_POS
	lh t1, 0(t0) # t1 = x_atual
	lh t2, 2(t0) # t2 = y_atual
	
	la t0, BOMBA
	sw t1, 12(t0) # Atualiza a posição X da bomba
	sw t2, 16(t0) # Atualiza a posição Y da bomba
	li t1, 1
	sw t1, 0(t0) # Atualiza o status da bomba (1 =

	# Adiciona 1 ponto pela colocação da bomba
	la t0, PONTUACAO
	lw t1, 0(t0) 
	addi t1, t1, 1 
	sw t1, 0(t0) 

skip_set_bomba:
	lw ra, 0(sp)       # restaura return address
	addi sp, sp, 4     # desloca o stack pointer
	ret


VERIFICAR_BOMBA:
	addi sp, sp, -4     # reserva espaço na pilha
	sw ra, 0(sp)         # salva return address

	# Verifica se a bomba está colocada
	# Se a bomba não estiver colocada, não faz nada
	la t0, BOMBA
	lw t1, 0(t0) # Status da bomba
	beq t1, zero, skip_ab 

	la t0, BOMBA
	la a0, bomba_1
	lw a1, 12(t0) # a1 = Posição X da bomba
	lw a2, 16(t0) # a2 = Posição Y da bomba
	call PRINT

	la t0, BOMBA

	li a7, 30
	ecall

	lw t1, 8(t0) # t1 = Tempo da bomba

	lw t2, 20(t0) # t2 = tempo de explosão (ms)
	sub t1, t1, t2 # t1 = Tempo restante da bomba (ms)
	bltu a0, t1, skip_eb # Se o tempo atual for maior que o tempo restante da bomba, explode a bomba

	call EXPLODIR_BOMBA

skip_eb:
	la t0, BOMBA

	li a7, 30
	ecall

	lw t1, 8(t0) # t1 = Intervalo da bomba (ms)
	bgtu t1, a0, skip_ab # Se o tempo atual for maior que o tempo da bomba, explode a bomba
	la t0, BOMBA
	li t1, 0
	sw t1, 0(t0) # Zera o status da bomba (0 = bomba não colocada, 1 = bomba colocada)	
	call APAGAR_BOMBA

skip_ab:
	lw ra, 0(sp)       # restaura return address
	addi sp, sp, 4     # desloca o stack pointer
	ret


APAGAR_BOMBA:
	addi sp, sp, -4     # reserva espaço na pilha
	sw ra, 0(sp)         # salva return address

	# Limpa a área ao redor da bomba

	li a3, 0 # Sprite vazio

	li a7, -2 # Direção da explosão (esquerda)
	call PRINT_EXPLOSAO # Chama a função de impressão da explosão

	li a7, 2 # Direção da explosão (direita)
	call PRINT_EXPLOSAO # Chama a função de impressão da explosão

	li a7, -38 # Direção da explosão (cima)
	call PRINT_EXPLOSAO # Chama a função de impressão da explosão

	li a7, 38 # Direção da explosão (baixo)
	call PRINT_EXPLOSAO # Chama a função de impressão da explosão

	mv a0, a3 # Passa o sprite vazio para a função de impressão
	call PRINT_DEGUB

	# Limpa a célula da bomba no mapa de colisão

	la t0, BOMBA
	lw t1, 12(t0) # t1 = Posição X da bomba
	lw t2, 16(t0) # t2 = Posição Y da bomba

	mv a5, t1
	mv a6, t2
	call TRANSFORMA_COORDENADAS # Transforma as coordenadas de pixel para coordenadas do mapa de colisão
	mv t3, a5 # t3 = endereço da célula da bomba no mapa de colisão

	li t6, 0
	sh t6, 0(t3) # Zera a célula da bomba no mapa de colisão

	lw ra, 0(sp) 	  # restaura return address
	addi sp, sp, 4 # Desloca o stack pointer
	ret

EXPLODIR_BOMBA:
	addi sp, sp, -4     # reserva espaço na pilha
	sw ra, 0(sp)         # salva return address	

	li a3, 5 # Sprite da explosão

	li a7, 0 # Direção da explosão (0 = bomba)
	call PRINT_EXPLOSAO # Chama a função de impressão da explosão	

	li a7, -2 # Direção da explosão (esquerda)
	call PRINT_EXPLOSAO # Chama a função de impressão da explosão

	li a7, 2 # Direção da explosão (direita)
	call PRINT_EXPLOSAO # Chama a função de impressão da explosão

	li a7, -38 # Direção da explosão (cima)
	call PRINT_EXPLOSAO # Chama a função de impressão da explosão

	li a7, 38 # Direção da explosão (baixo)
	call PRINT_EXPLOSAO # Chama a função de impressão da explosão

	lw ra, 0(sp)       # restaura return address
	addi sp, sp, 4     # desloca o stack pointer
	ret

# ============================
# Função de impressão da explosão
# ============================
# Argumentos:
# 		- a3: sprite a ser printado (5 = explosao, 0 = vazio)
# 		- a7: direção da explosão (-2 = esquerda, 2 = direita, -38 = cima, 38 = baixo)
PRINT_EXPLOSAO:
	addi sp, sp, -4     # reserva espaço na pilha
	sw ra, 0(sp)         # salva return address
	
	la t0, BOMBA
	lw t1, 12(t0) # t1 = Posição X da bomba
	lw t2, 16(t0) # t2 = Posição Y da bomba

	mv a5, t1
	mv a6, t2
	call TRANSFORMA_COORDENADAS # Transforma as coordenadas de pixel para coordenadas do mapa de colisão
	mv t3, a5 # t3 = endereço da célula da bomba no mapa de colisão
	add t3, t3, a7

	mv a7, t3 # Passa o endereço da célula da bomba para a5

	# SWITCH DE ELEMENTOS QUE SÂO AFETADOS PELA EXPLOSÃO:

	mv t6, a3 

	# Espaço vazio (0) pode ser explodido
	lh t1, 0(t3)		# Carrega o valor da célula da bomba esquerda
	bne t1, zero, next_eb1   # Se a célula não for zero, não altera
	sh t6, 0(t3)

next_eb1:
	# Softblock (2) pode ser explodido
	li t4, 2
	bne t1, t4, next_eb2  	# Se a célula não for 2 (softblock), não altera
	sh t6, 0(t3)		# Carrega o valor da célula da bomba

next_eb2:
	# sprite de explosão (5) pode ser explodido
	li t4, 5
	bne t1, t4, next_eb3   # Se a célula não for 5 (explosão), não altera
	sh t6, 0(t3)

next_eb3:
	# Bomberman (3) perde vida quando atingido pela explosão
	li t4, 3
	bne t1, t4, skip_eb4   # Se a célula não for 3 (bomberman), não altera
	call TIRAR_VIDA

skip_eb4:
	lw ra, 0(sp)       # restaura return address	
	addi sp, sp, 4     # desloca o stack pointer
	ret 

# ============================
# Função responsável por tirar vida do bomberman
# ============================
TIRAR_VIDA:
	addi sp, sp, -4     # reserva espaço na pilha
	sw ra, 0(sp)         # salva return address

	la t0, BOMBER_VIDA

	lw t1, 12(t0) 	# Status do dano do bomberman
	bne t1, zero, skip_tv # Se o bomberman já levou dano, não tira vida novamente

	# Tira vida do bomberman
	lw t1, 0(t0) # Carrega a vida do bomberman
	addi t1, t1, -1 # Diminui a vida do bomberman
	sw t1, 0(t0) # Atualiza a vida do bomberman

	# Atualiaza o status de dano do bomberman
	# 0 = não levou dano, 1 = levou dano
	li t1, 1
	sw t1, 12(t0)

	# Atualiza o tempo auxiliar do intervalo de dano
	li a7, 30
	ecall

	lw t2, 4(t0) # t2 = intervalo de dano (ms)
	add t1, a0, t2 # Adiciona o tempo atual ao tempo auxiliar
	sw t1, 8(t0) # Atualiza o tempo auxiliar do intervalo de dano

	j skip_tv2

skip_tv:
	# Verifica se o intervalo de imunidade passou, caso sim, atualiza o status de dano para 0
	# Se o status de dano for 0, o bomberman pode levar dano novamente
	la t0, BOMBER_VIDA

	li a7, 30
	ecall
	lw t1, 8(t0) # t1 = tempo auxiliar do intervalo de dano
	bltu a0, t1, skip_tv2 # Se o tempo atual for menor que o tempo auxiliar, não atualiza o status de dano
	
	li t1, 0
	sw t1, 12(t0) # Atualiza o status do dano (0 = não levou dano, 1 = levou dano)

	mv a0, t1
	call PRINT_DEGUB

skip_tv2:
	lw ra, 0(sp)       # restaura return address
	addi sp, sp, 4     # desloca o stack pointer
	ret