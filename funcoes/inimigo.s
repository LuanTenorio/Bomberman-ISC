.data
.include "../images/inimigo.data"

INIMIGO:
    .word 0     # status (0 = morto, 1 = ativo)
    .word 40    # x
    .word 40    # y
    .word 1     # velocidade
    .word 0     # direcao (0 = parado, 1=cima, 2=baixo, 3=esquerda, 4=direita)

# ============================
# Função principal do inimigo: move e ataca se encostar
# ============================
.text
INIMIGO_ATUALIZAR:
    addi sp, sp, -4
    sw ra, 0(sp)

    la t0, INIMIGO
    lw t1, 0(t0)       # status
    beq t1, zero, skip_ia

    lw a1, 4(t0)       # x
    lw a2, 8(t0)       # y

    # Renderiza inimigo na posição atual
    la a0, inimigo
    li a3, 0
    call PRINT

    # Move em direção ao jogador
    call INIMIGO_MOVER

    # Verifica colisão com jogador e tira vida se necessário
    call INIMIGO_COLISAO_JOGADOR

skip_ia:
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# ============================
# Função para movimentar o inimigo na direção do jogador
# ============================
INIMIGO_MOVER:
    addi sp, sp, -4
    sw ra, 0(sp)

    la t0, INIMIGO
    lw t1, 4(t0)       # inimigo x
    lw t2, 8(t0)       # inimigo y

    la t3, BOMBER_POS
    lw t4, 0(t3)       # jogador x
    lw t5, 4(t3)       # jogador y

    li t6, 4           # velocidade

    # Move na horizontal se necessário
    bgt t1, t4, move_esquerda
    blt t1, t4, move_direita

    # Move na vertical se necessário
    bgt t2, t5, move_cima
    blt t2, t5, move_baixo

    j fim_mov

move_esquerda:
    sub t1, t1, t6
    j salvar_mov

move_direita:
    add t1, t1, t6
    j salvar_mov

move_cima:
    sub t2, t2, t6
    j salvar_mov

move_baixo:
    add t2, t2, t6

salvar_mov:
    sw t1, 4(t0)
    sw t2, 8(t0)

fim_mov:
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# ============================
# Verifica colisão entre inimigo e jogador
# Se colidir, chama TIRAR_VIDA
# ============================
INIMIGO_COLISAO_JOGADOR:
    addi sp, sp, -4
    sw ra, 0(sp)

    la t0, INIMIGO
    lw t1, 4(t0)   # inimigo x
    lw t2, 8(t0)   # inimigo y

    la t3, BOMBER_POS
    lw t4, 0(t3)   # jogador x
    lw t5, 4(t3)   # jogador y

    # Checa se x está no intervalo de colisão
    li t6, 16
    sub t7, t1, t4
    abs t7, t7
    bge t7, t6, skip_colisao

    # Checa se y está no intervalo de colisão
    sub t7, t2, t5
    abs t7, t7
    bge t7, t6, skip_colisao

    # Colidiu: tira vida do jogador
    call TIRAR_VIDA

skip_colisao:
    lw ra, 0(sp)
    addi sp, sp, 4
    ret