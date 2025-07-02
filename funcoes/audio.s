.data
# Número de notas (cada par nota+duração = 1 nota lógica)
NUM_NOTAS: .word 40

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

.text
# ============================
# Função principal de controle da música
# ============================
TOCAR_MUSICA:
	addi sp, sp, -4      # reserva 16 bytes (mesmo que só vá usar 4)
	sw ra, 0(sp)         # salva ra no topo da área alocada

    	la t2, CONTADOR_MUSICA
    	lw t2, 0(t2)           # t2 ← índice da nota atual

    	la a5, NOTAS
  	li t4, 8
   	mul t3, t2, t4
    	add a5, a5, t3         # a5 ← endereço da nota atual
    	
    	li a7, 30
    	ecall                  # a0 ← tempo atual
    	
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

    	la t1, NUM_NOTAS
    	lw t1, 0(t1)

    	la t2, CONTADOR_MUSICA
    	lw t2, 0(t2)
	
    	bne t2, t1, tocar
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
