.text
# ============================
# Função principal de controle da música
# ============================
#	- a4 = endereço da música
#	- a5 = numero de notas
#
TOCAR_MUSICA:
	addi sp, sp, -4      # reserva 16 bytes (mesmo que só vá usar 4)
	sw ra, 0(sp)         # salva ra no topo da área alocada

	la t2, CONTADOR_MUSICA
	lw t2, 0(t2)           # t2 ← índice da nota atual

  	li t4, 8
   	mul t3, t2, t4
	add a4, a4, t3         # a4 ← endereço da nota atual = (8*contador de notas) + endereço inicial
	
	li a7, 30
	ecall                  # a0 ← tempo atual
	
	la t0, CONTADOR_MUSICA
	lw t0, 4(t0)

	bltu a0, t0, skip_tm  # se a0 < t0, ainda não é hora → sai
	
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

	lw t1, 0(a5)

	la t2, CONTADOR_MUSICA
	lw t2, 0(t2)

	bne t2, t1, tocar
	li t2, 0
	la t5, CONTADOR_MUSICA
	sw t2, 0(t5)

	li t4, 8
	mul t3, t2, t4
	add a4, a4, t3

tocar:
	lw a0, 0(a4)
	lw a1, 4(a4)
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

	lw t3, 4(a4)
	add a0, a0, t3

	# Armazena o tempo da música tocada para ter controle do tempo
	la t0, CONTADOR_MUSICA
	sw a0, 4(t0)

	lw ra, 0(sp)
	addi sp, sp, 4
	ret
