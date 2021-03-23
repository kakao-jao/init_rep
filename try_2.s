	.arch armv8-a
	.data
	.align 0
n:
	.byte	0x3
m:
	.byte	0x4
	.align 2
mas:
	.4byte	83,	12,	42,	22,	9,	95,	1,	66,	10,	9,	-4,	13

	.global _start, heapy
	.type	heapy,	%function
	.type	_start,	%function
	.align 2
	.text

_start:
	adr		x0,	n
	ldrb	w1, [x0], #1
	ldrb	w2, [x0]
	
	mov		w3,	w2
	mov		x22, #2
	mov		x21, #1
	lsl		w3, w3,	w22
	
	mov		w5, #0
	udiv	w8, w2, w22
	sub		w8, w8, w21
	sub		w9, w2, w21
	adr		x4, mas

	b		LOOP1
LOOP1_END:
	// j = w5
	// i = w6
	// tmp = x7
	// m/2 - 1 = w8
	// m -1 = w9
	// raw_shift = w3

	mov		x0, #0
	mov		x8, #93
	svc		#0
	.size	_start, (. - _start)

LOOP1:
	cmp		w5, w1	// j != n
	beq		LOOP1_END
	mov		w6, w8	// i = m/2-1
	mov		w20, w2
LOOP2:
	cmp		w6, wzr
	blt		PRE_LOOP3
	// w26 - i, x4 - raw, w20 - cur_n
	mov		w26, w6	// heapy.i = i
	bl		heapy
	sub		w6, w6, w21
	b		LOOP2

PRE_LOOP3:
	mov		w6, w9
LOOP3:
	cmp		w6, wzr
	blt		POST_LOOP1		
	// swap
	ldr		w7,	[x4, w6, sxtw #2]	// tmp = raw[i]
	ldr		w19, [x4]	// tmp2 = raw[0]
	str		w7, [x4]
	str		w19, [x4, w6, sxtw #2]

	mov		w26, #0
	mov		w20, w6
	bl		heapy
	sub		w6, w6, w21
	b		LOOP3

POST_LOOP1:
	add		w5, w5, w21
	add		x4, x4, w3, sxtw
	b		LOOP1

heapy:
	// raw - x4
	// n - w0
	// m - w2
	// tmp_adr - x19
	// cur_n - w20
	// #1 - x21
	// #2 - x22
	// raw[i] - x23
	// raw[largest] - x24
	// tmp - w25
	// i - w26
	// largest - w27
	// l - w28
	// r - w29
	str		x30, [SP, #-8]!
	mov		w27, w26
	madd	w28, w27, w22, w21	// l = 2*i+1
	add		w29, w28, w21		// r = 2*i+2
	cmp		w28, w20
	blt		IF0		// w28 < w2

IF0_END:
	cmp		w29, w20
	blt		IF1

IF1_END:
	cmp		w27, w26
	bne		IF2

	b		HEAPY_END

IF0:
	ldr		w23, [x4, w28, sxtw #2] // raw[l]
	ldr		w24, [x4, w27, sxtw #2] // raw[largest]
	cmp 	w23, w24	// raw[l] > raw[largest[
	csel	w27, w28, w27, lt	// raw[l] > raw[largest]
	b		IF0_END

IF1:
	ldr		w23, [x4, w29, sxtw #2]	// raw[r]
	ldr		w24, [x4, w27, sxtw #2]	// raw[largest]
	cmp		w23, w24
	csel	w27, w29, w27, lt
	b		IF1_END

IF2:
	// swap
	ldr		w25, [x4, w27, sxtw #2]		// tmp = raw[largest]
	ldr		w19, [x4, w26, sxtw #2]		// tmp2 = raw[i]
	str		w19, [x4, w27, sxtw #2]		// raw[largest] = tmp2
	str		w25, [x4, w26, sxtw #2]		// raw[i] = tmp
	mov		w26, w27
	bl		heapy
HEAPY_END:
	ldr		x30, [sp], #8
	ret
	.size heapy, .-heapy
