global _start


section .data
    hashtag_space db "# "
    hashtag_space_len equ $ - hashtag_space

    space_space db "  "
    space_space_len equ $ - space_space


    newline db 0x0a
    newline_len equ $ - newline


    index DD 0
    index2 DD 0


    msg_error_too_many_arguments db "too many arguments", 0x0a
    len_msg_error_too_many_arguments equ $ - msg_error_too_many_arguments

    msg_show_usage db "Usage: spiral <size> <gap>", 0x0a
    len_msg_show_usage equ $ - msg_show_usage

    msg_parse_number_error db "invalid digit found in argument(s)", 0x0a
    len_msg_parse_number_error equ $ - msg_parse_number_error

    first_part_bool DD 1



section .bss

    first_part_height DD ?
    second_part_height DD ?
    i_ DD ?
    i_modulo DD ?
    x_ DD ?
    outer_loop_start DD ?
    outer_loop_2_start DD ?
    size DD ?
    gap DD ?

section .text
_start:

    ; https://gist.github.com/Gydo194/730c1775f1e05fdca6e9b0c175636f5b?permalink_comment_id=4396982#gistcomment-4396982

    pop   rbx               ; Pop the number of arguments from the stack.

    pop   rsi               ; Discard the program name, since we only want      ; the command line arguments.

    dec   rbx               ; If there are no extra command line argments,      ; just exit directly!

    jz    show_usage

    mov r9, 0

top:


    cmp r9, 2
    je error_too_many_arguments

    ; Calculate the string len.
    ;
    ; The return value of strlen
    ; goes in rax.
    mov   rdi, [rsp]
    call  strlen




    pop rsi
    mov rdi, rsi



    call atoi

    cmp r9, 0
    je set_a_

    inc rax
    mov [gap], rax

    jmp set_h_
    set_a_:
        mov [size], rax
    set_h_:


    inc r9

    ; If `dec r8` is not zero, goto top.
    dec   rbx
    jnz   top


    call write_spiral
    ; call write_spiral_recursion


    mov eax, 1      ; sys_exit system call
    mov ebx, 0      ; exit status is 0
    int 0x80        ; perform system call



;;;;;;;;;;;;;;
;   Procedures
;;;;;;;;;;;;;;


calculate_first_part_height:
    mov eax, [gap]
    mov ebx, 2
    mul ebx
    mov ebx, eax

    mov ebp, [gap]
    add ebp, [size]
    mov edi, ebp
    add edi, [gap]

    ; ebp is index
    ; edi is loop stop
    calculate_first_part_loop:
        cmp ebp, edi
        jge calculate_first_part_loop_end

        mov edx, 0
        mov eax, ebp
        div ebx
        add ecx, eax

        inc ebp
        jmp calculate_first_part_loop


    calculate_first_part_loop_end:
    ret







; https://gist.github.com/tnewman/63b64284196301c4569f750a08ef52b2
atoi:
    mov rax, 0                      ; Set initial total to 0

    convert:
        movzx rsi, byte [rdi]                       ; Get the current character
        test rsi, rsi                               ; Check for \0
        je done

        cmp rsi, 48                                 ; Anything less than 0 is invalid
        jl error_

        cmp rsi, 57                                 ; Anything greater than 9 is invalid
        jg error_

        sub rsi, 48                                 ; Convert from ASCII to decimal
        imul rax, 10                                ; Multiply total by 10
        add rax, rsi                                ; Add current digit to total

        inc rdi                                     ; Get the address of the next character
        jmp convert

    error_:

        mov eax, 4                                  ; sys_write system call
        mov ebx, 1                                  ; stdout file descriptor
        mov ecx, msg_parse_number_error             ; bytes to write
        mov edx, len_msg_parse_number_error         ; number of bytes to write
        int 0x80                                    ; perform system call

        mov eax, 1                                  ; sys_exit system call
        mov ebx, 1                                  ; exit status is 1
        int 0x80                                    ; perform system call

    done:
        ret



error_too_many_arguments:
    ; println!("too many arguments\n program size gap");
    mov eax, 4                                          ; sys_write system call
    mov ebx, 1                                          ; stdout file descriptor
    mov ecx, msg_error_too_many_arguments               ; bytes to write
    mov edx, len_msg_error_too_many_arguments           ; number of bytes to write
    int 0x80                                            ; perform system call

    mov eax, 4                                          ; sys_write system call
    mov ebx, 1                                          ; stdout file descriptor
    mov ecx, msg_show_usage                             ; bytes to write
    mov edx, len_msg_show_usage                         ; number of bytes to write
    int 0x80                                            ; perform system call

    mov eax, 1      ; sys_exit system call
    mov ebx, 1      ; exit status is 1
    int 0x80        ; perform system call



show_usage:
    mov eax, 4                                          ; sys_write system call
    mov ebx, 1                                          ; stdout file descriptor
    mov ecx, msg_show_usage                             ; bytes to write
    mov edx, len_msg_show_usage                         ; number of bytes to write
    int 0x80                                            ; perform system call

    mov eax, 1      ; sys_exit system call
    mov ebx, 2      ; exit status is 2
    int 0x80        ; perform system call



strlen:
    xor   eax, eax
s_loop:
    cmp   byte [rdi], 0
    je    return
    inc   rdi
    inc   rax
    jmp   s_loop
return:
    ret



write_spiral:

    call calculate_first_part_height
    mov [first_part_height], ecx
    mov eax, [size]
    sub eax, ecx
    mov [second_part_height], eax

    call write_spiral_part

    mov eax, 0
    mov [first_part_bool], eax

    mov eax, [size]
    sub eax, [gap]
    mov [size], eax

    call write_spiral_part

    ret


write_spiral_recursion:

    mov eax, 1
    cmp [first_part_bool], eax
    je true3
        call write_spiral_part
    jmp false3
    true3:
        call calculate_first_part_height
        mov [first_part_height], ecx
        mov eax, [size]
        sub eax, ecx
        mov [second_part_height], eax

        call write_spiral_part

        mov eax, 0
        mov [first_part_bool], eax

        mov eax, [size]
        sub eax, [gap]
        mov [size], eax

        call write_spiral_recursion
    false3:
    ret


write_spiral_part:

    mov eax, [first_part_bool]
    cmp eax, 1
    je first_part_bool_true
        mov r8d, [second_part_height]
        mov r9d, 0
        mov eax, 0
        mov [outer_loop_start], eax
    jmp first_part_bool_false
    first_part_bool_true:
        mov r8d, 0
        mov r9d, [first_part_height]
        mov eax, 1
        mov [outer_loop_start], eax
    first_part_bool_false:

    ; r8d is index
    ; r9d is loop stop
    outer_outer_loop:

        mov eax, [first_part_bool]
        cmp eax, 1
        je first_part_bool_true_2
            cmp r8d, r9d
            jl end_loop_iterator
        jmp first_part_bool_false_2
        first_part_bool_true_2:
            cmp r8d, r9d
            jge end_loop_iterator
        first_part_bool_false_2:


        ; i_ = r8d / gap
        mov eax, r8d
        mov ebx, [gap]
        mov edx, 0
        div ebx
        mov [i_], eax
        mov [i_modulo], edx


        ; x_ = size+gap*(1-2*i_)
        mov ebx, 2
        mul ebx
        mov ebx, 1
        sub ebx, eax

        mov eax, [gap]
        mul ebx

        add eax, [size]

        mov [x_], eax



        ; outer_loop_2_start = if first_part_bool && i_ == 0 { gap } else { 0 }
        mov eax, [i_]
        cmp eax, 0
        je true_
            mov eax, 0
        jmp both
        true_:
            mov eax, [first_part_bool]
            cmp eax, 1
            je true__
                mov eax, 0
            jmp both
            true__:
                mov eax, [gap]
        both:
            mov [outer_loop_2_start], eax



        mov eax, [outer_loop_start]
        mov [index], eax
        mov esi, [i_]
        outer_loop:
            cmp [index], esi
            jge end_outer_loop


            ; print "# "
            mov eax, 4                      ; sys_write system call
            mov ebx, 1                      ; stdout file descriptor
            mov ecx, hashtag_space          ; bytes to write
            mov edx, hashtag_space_len      ; number of bytes to write
            int 0x80                        ; perform system call

            mov ebp, 1
            mov edi, [gap]
        inner_loop:
            cmp ebp, edi                    ; Compare ebp with edi
            jge end_inner_loop

            ; print "  "
            mov eax, 4                      ; sys_write system call
            mov ebx, 1                      ; stdout file descriptor
            mov ecx, space_space            ; bytes to write
            mov edx, space_space_len        ; number of bytes to write
            int 0x80                        ; perform system call

            inc ebp                         ; ebp += 1
            jmp inner_loop

        end_inner_loop:


            mov eax, [index]
            inc eax
            mov [index], eax
            jmp outer_loop

        end_outer_loop:


        ; if i_modulo == 0
        mov eax, [i_modulo]
        cmp eax, 0
        je true2

            mov eax, [outer_loop_2_start]
            mov ebx, 1                          ; stdout file descriptor
            cmp eax, 0
            je true2_
                ; print "  "
                mov eax, 4                      ; sys_write system call
                mov ecx, space_space            ; bytes to write
                mov edx, space_space_len        ; number of bytes to write
            jmp both2_
            true2_:
                ; print "# "
                mov eax, 4                      ; sys_write system call
                mov ecx, hashtag_space          ; bytes to write
                mov edx, hashtag_space_len      ; number of bytes to write
            both2_:
            int 0x80                            ; perform system call



            mov ebp, [outer_loop_2_start]
            mov edi, [x_]
            sub edi, 2
            outer_loop_2:
                cmp ebp, edi
                jge end_outer_loop_2

                ; print "  "
                mov eax, 4                      ; sys_write system call
                mov ebx, 1                      ; stdout file descriptor
                mov ecx, space_space            ; bytes to write
                mov edx, space_space_len        ; number of bytes to write
                int 0x80                        ; perform system call

                inc ebp                         ; ebp += 1
                jmp outer_loop_2

            end_outer_loop_2:


            ; print "# "
            mov eax, 4                          ; sys_write system call
            mov ebx, 1                          ; stdout file descriptor
            mov ecx, hashtag_space              ; bytes to write
            mov edx, hashtag_space_len          ; number of bytes to write
            int 0x80                            ; perform system call


        jmp both2
        true2:
            mov ebp, [outer_loop_2_start]
            mov edi, [x_]
            outer_loop_3:
                cmp ebp, edi
                jge end_outer_loop_3

                ; print "# "
                mov eax, 4                      ; sys_write system call
                mov ebx, 1                      ; stdout file descriptor
                mov ecx, hashtag_space          ; bytes to write
                mov edx, hashtag_space_len      ; number of bytes to write
                int 0x80                        ; perform system call

                inc ebp                         ; ebp += 1
                jmp outer_loop_3

            end_outer_loop_3:
        both2:


        mov eax, 0
        mov [index], eax
        mov esi, [i_]
        outer_loop_4:
            cmp [index], esi
            jge end_outer_loop_4


            mov ebp, 1
            mov edi, [gap]
        inner_loop_2:
            cmp ebp, edi
            jge end_inner_loop_2

            ; print "  "
            mov eax, 4                          ; sys_write system call
            mov ebx, 1                          ; stdout file descriptor
            mov ecx, space_space                ; bytes to write
            mov edx, space_space_len            ; number of bytes to write
            int 0x80                            ; perform system call

            inc ebp                             ; ebp += 1
            jmp inner_loop_2

        end_inner_loop_2:


            ; print "# "
            mov eax, 4                          ; sys_write system call
            mov ebx, 1                          ; stdout file descriptor
            mov ecx, hashtag_space              ; bytes to write
            mov edx, hashtag_space_len          ; number of bytes to write
            int 0x80                            ; perform system call


            mov eax, [index]
            inc eax
            mov [index], eax
            jmp outer_loop_4

        end_outer_loop_4:


        ; print "\n"
        mov eax, 4                              ; sys_write system call
        mov ebx, 1                              ; stdout file descriptor
        mov ecx, newline                        ; bytes to write
        mov edx, newline_len                    ; number of bytes to write
        int 0x80                                ; perform system call


        mov eax, [first_part_bool]
        cmp eax, 1
        je first_part_bool_true_3
            dec r8d
        jmp first_part_bool_false_3
        first_part_bool_true_3:
            inc r8d
        first_part_bool_false_3:

        jmp outer_outer_loop

    end_loop_iterator:
        ret
