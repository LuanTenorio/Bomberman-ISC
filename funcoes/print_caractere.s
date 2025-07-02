.text
# ============================
# Função responsável por printar um caractere na tela
# ============================
# Argumentos:
#	a0 = endereço da imagem
# 	a1 = x
# 	a2 = y
# 	a3 = frame 0 ou 1
#	a4 = caractere a ser impresso
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

.data	
.include "../images/algarismos/alg_zero.data"
.include "../images/algarismos/alg_um.data"
.include "../images/algarismos/alg_dois.data"
.include "../images/algarismos/alg_tres.data"
.include "../images/algarismos/alg_quatro.data"
.include "../images/algarismos/alg_cinco.data"
.include "../images/algarismos/alg_seis.data"
.include "../images/algarismos/alg_sete.data"
.include "../images/algarismos/alg_oito.data"
.include "../images/algarismos/alg_nove.data"

.include "../images/algarismos/algarismos.data"