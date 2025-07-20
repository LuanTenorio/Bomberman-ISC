.data
INIMIGO:
    .word 1     # status (0 = morto, 1 = ativo)
    .word 40    # x
    .word 40    # y
    .word 1     # velocidade
    .word 0     # direcao (0 = parado, 1=cima, 2=baixo, 3=esquerda, 4=direita)

.text
# ============================
# Função para movimentar o inimigo
# ============================
MOVIMENTAR_INIMIGO:
    addi sp, sp, -4
    sw ra, 0(sp)

    # Verifica se o inimigo está ativo
    mv s4, a0  # s4 = endereço do inimigo 
    lw t0, 12(s4)
    beq t0, zero, end_mi  

    # Verifica o tipo do inimigo
    lw t0, 8(s4)

    li t1, 1
    bne t0, t1, mi_tipo_2
mi_tipo_1:
    lw t2, 16(s4)    # Direção do inimigo

    lw a4, 0(s4)     # a1 = x
    lw a5, 4(s4)     # a2 = y

    # Verifica direção e move de acordo
    li t3, 1
    beq t2, t3, mover_cima
    
    li t3, 2  
    beq t2, t3, mover_baixo
    
    li t3, 3
    beq t2, t3, mover_esquerda
    
    li t3, 4
    beq t2, t3, mover_direita
    
    j verificar_posicao

mover_cima:
    lw a5, 4(s4)     # y atual
    addi a5, a5, -1  # y--
    j verificar_posicao

mover_baixo:
    lw a5, 4(s4)     # y atual
    addi a5, a5, 1   # y++
    j verificar_posicao

mover_esquerda:
    lw a4, 0(s4)     # x atual
    addi a4, a4, -1  # x--
    j verificar_posicao

mover_direita:
    lw a4, 0(s4)     # x atual
    addi a4, a4, 1   # x++
    j verificar_posicao

verificar_posicao:
    call PEGA_CELULA_MAPA_COLISAO
    
    # Verifica se a célula está ocupada
    li t0, 1
    beq a0, t0, reverter_movimento  # hard_block
    
    li t0, 2
    beq a0, t0, reverter_movimento  # soft_block
    
    li t0, 4
    beq a0, t0, reverter_movimento  # bomba
    
    li t0, 5
    beq a0, t0, reverter_movimento  # explosão
    
    # Se chegou aqui, pode mover
    # Primeiro limpa posição antiga (coloca 0)
    lw a1, 0(s4)     # x atual
    lw a2, 4(s4)     # y atual
    
    # Calcula posição antiga baseada na direção
    lw t1, 16(s4)    # direção do inimigo
    
    li t2, 1
    beq t1, t2, limpar_baixo   # se foi para cima, limpa embaixo
    
    li t2, 2  
    beq t1, t2, limpar_cima    # se foi para baixo, limpa em cima
    
    li t2, 3
    beq t1, t2, limpar_direita # se foi para esquerda, limpa à direita
    
    li t2, 4
    beq t1, t2, limpar_esquerda # se foi para direita, limpa à esquerda
    
    j atualizar_nova_posicao

limpar_cima:
    addi a2, a2, 1   # posição antiga estava acima
    j limpar_posicao_antiga

limpar_baixo:
    addi a2, a2, -1  # posição antiga estava abaixo
    j limpar_posicao_antiga

limpar_esquerda:
    addi a1, a1, 1   # posição antiga estava à esquerda
    j limpar_posicao_antiga

limpar_direita:
    addi a1, a1, -1  # posição antiga estava à direita
    j limpar_posicao_antiga

limpar_posicao_antiga:
    # Converte para coordenadas do mapa
    li a3, 0         # valor 0 (vazio)
    call ALTERA_CELULA_MAPA_COLISAO

atualizar_nova_posicao:
    # Agora coloca o inimigo na nova posição
    mv a1, a4
    mv a2, a5
    li a3, 6         # valor 6 (inimigo)
    call ALTERA_CELULA_MAPA_COLISAO
    j mi_tipo_2

reverter_movimento:
    # Reverte o movimento baseado na direção
    lw t1, 16(s4)    # direção do inimigo
    
    li t2, 1
    beq t1, t2, reverter_cima
    
    li t2, 2
    beq t1, t2, reverter_baixo
    
    li t2, 3
    beq t1, t2, reverter_esquerda
    
    li t2, 4
    beq t1, t2, reverter_direita
    
    j mi_tipo_2

reverter_cima:
    lw t4, 4(s4)     # y atual
    addi t4, t4, 1   # y++ (reverte o movimento para cima)
    sw t4, 4(s4)
    j mi_tipo_2

reverter_baixo:
    lw t4, 4(s4)     # y atual
    addi t4, t4, -1  # y-- (reverte o movimento para baixo)
    sw t4, 4(s4)
    j mi_tipo_2

reverter_esquerda:
    lw t4, 0(s4)     # x atual
    addi t4, t4, 1   # x++ (reverte o movimento para esquerda)
    sw t4, 0(s4)
    j mi_tipo_2

reverter_direita:
    lw t4, 0(s4)     # x atual
    addi t4, t4, -1  # x-- (reverte o movimento para direita)
    sw t4, 0(s4)
    j mi_tipo_2


mi_tipo_2:
    lw a1, 0(s4)  # a1 = x
    lw a2, 4(s4)  # a1 = y
    call PEGA_CELULA_MAPA_COLISAO

end_mi:
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

SET_INIMIGOS:
    addi sp, sp, -4
    sw ra, 0(sp)

    li a1, 6    # Colocar 6 no mapa de colisão
    li a2, 0    # Onde for 0
    li a3, 9    # Depois da linha 9 
    call ALTERA_MAPA_COLISAO
 
    sh a1, 0(a0)    # posição x do mapa de colisão
    sh a2, 2(a0)    # posição y do mapa de colisão

    lw ra, 0(sp)
    addi sp, sp, 4
    ret