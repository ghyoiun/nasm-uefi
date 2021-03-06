; Copyright 2018-2019 Brian Otto @ https://hackerpulp.com
; 
; Permission to use, copy, modify, and/or distribute this software for any 
; purpose with or without fee is hereby granted, provided that the above 
; copyright notice and this permission notice appear in all copies.
; 
; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH 
; REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY 
; AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, 
; INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM 
; LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE 
; OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR 
; PERFORMANCE OF THIS SOFTWARE.

; we use the same calling conventions as UEFI
; see http://www.uefi.org/sites/default/files/resources/UEFI Spec 2_7_A Sept 6.pdf#G6.1000069

apiVerifySignature:
    ; get the signature for the loaded EFI_SYSTEM_TABLE
    mov rcx, [ptrSystemTable]
    mov rcx, [rcx + EFI_SYSTEM_TABLE.Hdr + EFI_TABLE_HEADER.Signature]
    
    ; get the signature defined in the UEFI spec
    ; see http://www.uefi.org/sites/default/files/resources/UEFI Spec 2_7_A Sept 6.pdf#G8.1001773
    mov rdx, EFI_SYSTEM_TABLE_SIGNATURE
    
    ; set our error code
    mov rax, EFI_LOAD_ERROR
    
    ; compare the signatures and return the error code when they don't match
    cmp rdx, rcx
    jne error
    
    mov rax, EFI_SUCCESS
    
    ret

apiOutputHeader:
    ; clear the screen
    call efiClearScreen
    
    ; write the header
    mov rcx, strHeader
    call efiOutputString
    
    ; write the firmware vendor
    mov rcx, [ptrSystemTable]
    mov rcx, [rcx + EFI_SYSTEM_TABLE.FirmwareVendor]
    call efiOutputString
    
    ; write the v
    mov rcx, strHeaderV
    call efiOutputString
    
    ; write the firmware revision
    mov rcx, [ptrSystemTable]
    mov rcx, [rcx + EFI_SYSTEM_TABLE.FirmwareRevision]
    call funIntegerToAscii
    
    ret

apiGetFrameBuffer:
    ; locate the first EFI_GRAPHICS_OUTPUT_PROTOCOL
    ; and allocate a frame buffer
    call efiLocateProtocol
    
    ; get the base address of the frame buffer 
    mov rcx, [ptrInterface]
    mov rcx, [rcx + EFI_GRAPHICS_OUTPUT_PROTOCOL.Mode]
    mov rcx, [rcx + EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE.FrameBufferBase]
    
    mov [ptrFrameBuffer], rcx
    
    ret

apiExitUEFI:
    call efiGetMemoryMap
    call efiExitBootServices
    
    ret

apiLoadKernel:
    ; verify we have reached this point
    ; by resetting the machine
    ; mov rax, [ptrSystemTable]
    ; mov rax, [rax + EFI_SYSTEM_TABLE.RuntimeServices]
    ; call [rax + EFI_RUNTIME_SERVICES.ResetSystem]
    
    ; set the 1st argument to our frame buffer
    mov rcx, [ptrFrameBuffer]
    
    ; set the 2nd argument to our start position
    mov rdx, 0
    
    ; set the 3rd argument to our end position
    ; this should be in multiples of 4
    mov r8, 1024 * 100
    
    call funDrawLine
    
    ret