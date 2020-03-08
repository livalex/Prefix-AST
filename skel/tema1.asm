%include "io.inc"

extern getAST
extern freeAST

section .data
    multiplier dd 10
    flag db 0
    make_neg dd -1
    traverse_result: times 2500 dd 0
    size dd 0

section .bss
    ; La aceasta adresa, scheletul stocheaza radacina arborelui
    root: resd 1

section .text
global main

traverse_tree:
    push ebp
    mov ebp, esp
    
    mov edx, [ebp + 8]
    
    ; Dereference so we can store the node
    mov ebx, [edx]
    push ebx
    ; Check if there is something further
    cmp ebx, dword 0 
    je ending
    mov ecx, [ebx]
    mov eax, [ecx]
    
    xor ecx, ecx
    
    ; Check for sign
    cmp eax, '+'
    je continue_normal
    cmp eax, '-'
    je continue_normal
    cmp eax, '*'
    je continue_normal
    cmp eax, '/'
    je continue_normal
    
    ; Conver the number to int and
    ; Store the result in traverse_result
    call atoi
    pop ebx ; restore ebx value
    push ecx
    xor ecx, ecx
    mov ecx, dword[size]
    mov dword[traverse_result + ecx * 4], eax
    add dword[size], 1
    pop ecx
    jmp continue_atoi
    
    ; If the operator is not a number
    ; Continue normal
continue_normal:
    push ecx
    xor ecx, ecx
    mov ecx, dword[size]
    mov dword[traverse_result + ecx * 4], eax
    add dword[size], 1
    pop ecx
    jmp continue_atoi
    
continue_atoi:
    ; Go on the left child and make the
    ; Recursive call
    add ebx, 4
    push ebx
    call traverse_tree
    
    ;Same thing but on the right child
    pop ebx ; ebx is altered
    push ebx
    add ebx, 4
    push ebx
    call traverse_tree
    pop ebx    
    
ending:
    leave
    ret
    
    
    
atoi:
    push ebp
    mov ebp, esp
    
    mov ebx, [ebp + 8]
    mov ebx, [ebx] ; working on adresses
    mov byte[flag], 0
    
    xor eax, eax
    xor ecx, ecx
    
    ; Check for sign
    cmp byte[ebx + ecx], '-'
    jne make_number_int
    
    inc ecx
    mov byte[flag], 1
    
make_number_int:
    ; Compare the char to see if it's the end
    cmp byte[ebx +  ecx], 0
    je next_step
    ; Store here the char
    mov dl, [ebx + ecx]
    ; oOnvert it
    sub dl, '0'
    imul eax, [multiplier]
    ; Transforms dl to edx
    movzx edx, dl
    add eax, edx
    inc ecx
    jmp make_number_int
    
next_step:
    cmp byte[flag], 1
    jne end
    
    ; Make sure the number is negative
    imul eax, dword[make_neg]

end:
    leave
    ret
    
show_result:
    push ebp
    mov ebp, esp
    
    xor eax, eax
    xor ebx, ebx
    xor edx, edx
    xor ecx, ecx
    
    mov ecx, [size]
    
check_elements:
    ; Check for the end
    cmp ecx, 0
    je final_lines
    dec ecx
    
    ; Check if it's a sign
    cmp dword[traverse_result + 4 * ecx], '*'
    je begin_multiplication
    cmp dword[traverse_result + 4 * ecx], '/'
    je begin_division
    cmp dword[traverse_result + 4 * ecx], '+'
    je begin_addition
    cmp dword[traverse_result + 4 * ecx], '-'
    je begin_substraction
    
    ; If not push it on the stack
    push dword[traverse_result + 4 * ecx]
    jmp check_elements
    
begin_multiplication:
    ; Pop the two operands and make
    ; The operation needed
    ; Same thing for the rest
    pop ebx
    pop edx
        
    imul ebx, edx
    push ebx
    
    jmp check_elements
        
begin_division:
    xor edx, edx

    pop eax
    pop ebx
    
    cdq
    idiv ebx
    
    push eax
    
    jmp check_elements
    
begin_addition:
    pop ebx
    pop edx
    
    add ebx, edx
    
    push ebx
    
    jmp check_elements
    
begin_substraction:
    pop ebx
    pop edx
    
    sub ebx, edx
    push ebx
    
    jmp check_elements
   
final_lines:
    ; Final result
    pop eax
    PRINT_DEC 4, eax
    
    leave
    ret
    

main:
    ; NU MODIFICATI
    push ebp
    mov ebp, esp
    
    ; Se citeste arborele si se scrie la adresa indicata mai sus
    call getAST
    mov [root], eax
    
    
    
    ; Implementati rezolvarea aici:
    ; Function calls
    mov eax, root
    push eax
    call traverse_tree
    pop eax
    
    mov eax, traverse_result
    push eax
    push traverse_result
    call show_result
    pop eax

    ; NU MODIFICATI
    ; Se elibereaza memoria alocata pentru arbore
    push dword [root]
    call freeAST
    
    xor eax, eax
    leave
    ret