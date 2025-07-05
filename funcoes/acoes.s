# ============================
# Funções de ações do personagem
# ============================
#	- Funções de movimento
#  	- Funções de colisão
# 	- SET_BOMBA

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
    	

	call VERIFICA_COLISAO_HORIZONTAL

	li a1, 1 # Se a7 for 1, houve colisão
	beq a7, a1, FIM_MOVIMENTO_HORIZONTAL
  
	#carrega e altera a posição antiga do bomber
	la t0, BOMBER_POS # carreaga a posição atual no mapa de pixeis
	la t1, OLD_BOMBER_POS
	lw t2, 0(t0)
	sw t2, 0(t1)

	#soma e atualiza a posição
	lh a1, 0(t0)
	add a1, a1, s10
	sh a1, 0(t0)
	
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
    	
	call VERIFICA_COLISAO_VERTICAL # Chama a função de verificação de colisão vertical

	li a1, 1 # Se a7 for 1, houve colisão
	beq a7, a1, FIM_MOVIMENTO_VERTICAL

	#carrega e altera a posição antiga do bomber
	la t0, BOMBER_POS # carreaga a posição atual no mapa de pixeis
	la t1, OLD_BOMBER_POS
	lw t2, 0(t0)
	sw t2, 0(t1)

	#soma e atualiza a posição
	lh t1, 2(t0)
	add t1, t1, s10
	sh t1, 2(t0)		

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

	# li t4, 0
	# sw t4, 0(s5) # Zera a célula antiga do mapa de colisão

	# li t4, 3
	# sw t4, 0(t3) # Atualiza a célula atual do mapa de colisão com o valor do bomberman

	# Não houve colisao
	li a7, 0
	j FIM_VERIFICA_COLISAO_VERTICAL

COLISAO_VERTICAL_OCORREU:
	li a7, 1

FIM_VERIFICA_COLISAO_VERTICAL:
	ret	

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

	la t0, BOMBA

	lw t1, 8(t0) # t1 = Tempo da bomba

	li a7, 30
	ecall

	lw t2, 20(t0) # t2 = tempo de explosão (ms)
	sub t1, t1, t2 # t1 = Tempo restante da bomba (ms)
	bgt t1, a0, skip_eb # Se o tempo atual for maior que o tempo restante da bomba, explode a bomba

	call EXPLODIR_BOMBA

skip_eb:
	lw t1, 8(t0) # t1 = Intervalo da bomba (ms)
	bgt t1, a0, skip_ab # Se o tempo atual for maior que o tempo da bomba, explode a bomba

	call APAGAR_BOMBA

skip_ab:
	lw ra, 0(sp)       # restaura return address
	addi sp, sp, 4     # desloca o stack pointer
	ret


APAGAR_BOMBA:
	addi sp, sp, -4     # reserva espaço na pilha
	sw ra, 0(sp)         # salva return address

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

	la t0, BOMBA
	lw t1, 12(t0) # t1 = Posição X da bomba
	lw t2, 16(t0) # t2 = Posição Y da bomba

	mv a5, t1
	mv a6, t2
	call TRANSFORMA_COORDENADAS # Transforma as coordenadas de pixel para coordenadas do mapa de colisão
	mv t3, a5 # t3 = endereço da célula da bomba no mapa de colisão

	addi t1, t3, -16	 # t1 = endereço da célula esquerda da bomba
	addi t2, t3, 16	 # t2 = endereço da célula direita da bomba
	addi t4, t3, -320 # t4 = endereço da célula acima da bomba
	addi t5, t3, 320  # t5 = endereço da célula abaixo da bomba

	li t6, 5 # Valor da explosão no mapa de colisão

	bne t1, zero, skip_eb1  	# Celula a esquerda diferente de zero, printa explosão
	sh t6, 0(t1)		# Carrega o valor da célula da bomba

skip_eb1:
	bne t2, zero, skip_eb2  	# Celula a direita diferente de zero, printa explosão
	sh t6, 0(t2)		# Carrega o valor da célula da bomba

skip_eb2:
	bne t4, zero, skip_eb3  	# Celula acima diferente de zero, printa explosão
	sh t6, 0(t4)		# Carrega o valor da célula da bomba

skip_eb3:
	bne t5, zero, skip_eb4  	# Celula abaixo diferente de zero, printa explosão
	sh t6, 0(t5)		# Carrega o valor da célula da bomba

skip_eb4:
	lw ra, 0(sp)       # restaura return address
	addi sp, sp, 4     # desloca o stack pointer
	ret 