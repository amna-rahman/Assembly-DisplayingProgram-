[org 0x0100]

    jmp start

    section .data
        ; Data section
        name db 'Name: Amna', 0               ; Name string
        vuid db 'VUID: 220406761', 0          ; VUID string
        vuid_asc db 'VUID sorted: 001224667', 0   ; Ascending sorted VUID string
        vuid_desc db 'VUID sorted: 766422100', 0  ; Descending sorted VUID string
        current_values db vuid - vuid          ; Difference between sorted and unsorted VUID

    start:
        ; print name on the 1st row of the screen
        mov ah, 0x0e                          ; BIOS teletype function
        mov al, 0                             ; Display page
        int 0x10                              ; Call BIOS video service
        mov si, name                          ; Load address of name string into SI
        call print_string_color               ; Call subroutine to print string with color

       

        ; keyboard interrupt service routine
        mov ax, 0                             ; Initialize AX to 0
        mov es, ax                            ; Set ES to IVT base
        cli                                  ; Disable interrupts
        mov word [es:9*4], kbisr              ; Store offset at n*4
        mov [es:9*4+2], cs                    ; Store segment at n*4+2
        sti                                  ; Enable interrupts

        ; wait for Esc key to be pressed
    l1:
        mov ah, 0                             ; Service 0 – get keystroke
        int 0x16                              ; Call BIOS keyboard service
        cmp al, 27                            ; Check if the Esc key is pressed
        jne l1                               ; If not, check for the next key

        mov ax, 0x4c00                        ; Terminate program
        int 0x21                              ; Call DOS service

    kbisr:
        push ax
        push es
        mov ax, 0xb800                        ; Video memory segment
        mov es, ax                            ; Set ES to video memory segment
        in al, 0x60                           ; Read a char from the keyboard port
        cmp al, 0x2a                          ; Check if the key is the left shift
        jne .nextcmp                          ; If not, try the next comparison
        mov al, 0x0a                          ; Line feed

        ; print 'VUID' on the 2nd row of the screen
        mov ah, 0x0e                          ; BIOS teletype function
        mov al, 0x0d                          ; Carriage return
        int 0x10                              ; Call BIOS video service
        mov al, 0x0a                          ; Line feed
        int 0x10                              ; Call BIOS video service
        mov si, vuid                          ; Load address of VUID string into SI
        call print_string_color               ; Call subroutine to print string with color

        ; print 'VUID ASC' on the 3rd row of the screen
        mov ah, 0x0e                          ; BIOS teletype function
        mov al, 0x0d                          ; Carriage return
        int 0x10                              ; Call BIOS video service
        mov al, 0x0a                          ; Line feed
        int 0x10                              ; Call BIOS video service
        mov si, vuid_asc                      ; Load address of ascending sorted VUID string into SI
        call print_string_color               ; Call subroutine to print string with color

        jmp .nomatch                          ; Leave the interrupt routine

    .nextcmp:
        cmp al, 0x36                          ; Check if the key is the right shift
        jne .nomatch                          ; If not, leave the interrupt routine

        mov si, name                          ; Load address of name string into SI
        call print_string_color               ; Call subroutine to print string with color

        ; print 'VUID' on the 2nd row of the screen
        mov ah, 0x0e                          ; BIOS teletype function
        mov al, 0x0d                          ; Carriage return
        int 0x10                              ; Call BIOS video service
        mov al, 0x0a                          ; Line feed
        int 0x10                              ; Call BIOS video service
        mov si, vuid                          ; Load address of VUID string into SI
        call print_string_color               ; Call subroutine to print string with color

        ; print 'VUID DESC' on the 3rd row of the screen
        mov ah, 0x0e                          ; BIOS teletype function
        mov al, 0x0d                          ; Carriage return
        int 0x10                              ; Call BIOS video service
        mov al, 0x0a                          ; Line feed
        int 0x10                              ; Call BIOS video service
        mov si, vuid_desc                     ; Load address of descending sorted VUID string into SI
        call print_string_color               ; Call subroutine to print string with color

    .nomatch:
        mov al, 0x20                          ; EOI - End of Interrupt
        out 0x20, al                          ; Send EOI to PIC
        pop es
        pop ax
        iret                                  ; Return from interrupt

    print_string_color:
        lodsb                                 ; Load a byte from SI into AL
        cmp al, 0                             ; Check for a null terminator
        je .done                              ; If found, exit the subroutine
        mov ah, 0x0e                          ; BIOS teletype function
        mov bh, 0                             ; Display page
        int 0x10                              ; Call BIOS video service
        jmp print_string_color                ; Continue printing the string

    .done:
        ret      
