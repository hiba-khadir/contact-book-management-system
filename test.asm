; multi-segment executable file template.

data segment
    
    ; add your data here!
    pkey db "press any key...$"
       
    ;constants 
    nameSize equ 10
    max equ 16
    phoneSize equ 10 
    
    ; contact list structure     
        
    contactBook db 320 dup(0)  ;array of16 contacts containing a name & phonenum 10bytes each
    count dw 0                 ;number of contacts 
    
    ;local variables 
    name_buffer db 13
                db ?
                db 12 dup(0) 
                  
    phone_buffer db 13
                 db ?
                 db 12 dup(0)
    
    ;input/output messages
    enterName db "Enter the contact's name : $" 
    enterPhone db "Enter the contact's phone number :$" 
    added db "contact added succesfuly.$" 
    newline db 10h
    
    ;error messages 
    full db "Unable to add a contact : contact book is full$"
    notFound db "Contact not found.$"
    duplicate db " a Contact with the same name already exists : saved as copy$"
       
ends



stack segment
    dw   256  dup(0)
ends



code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

    ; add your code here
    ;check if not full  
      mov ax, count 
      cmp ax, 320
      jge full_msg 
      
      ;user input :
      ;prompt message :
      lea dx, enterName 
      mov ah, 9
      int 21h 
     
      
      ;read the name to the buffer        
      lea dx, name_buffer ; 
      mov ah, 0Ah
      int 21h
      
      
      ;prompt msg
      lea dx, enterPhone
      mov ah, 9
      int 21h 
      
      ;read the number to the buffer        
      lea dx, phone_buffer ; 
      mov ah, 0Ah
      int 21h
      
              
      call insert   ;insert   
      
      add count, 20  ;move by one contact   
      jmp end_full  
      
full_msg: 
      ;display full book message
      lea dx, full
      mov ah, 9
      int 21h
      
      lea dx, newline
      mov ah, 9 
      int 21h             
end_full:    
      ;display added contact message
      lea dx, added 
      mov ah, 9
      int 21h    
    
               
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h 
              
              
insert proc 
       
       lea si, name_buffer + 2  ;si points the first char in buffer  
       mov al, [name_buffer + 1]
       mov cx, 10
       mov di, 0
insert_loop:
       cmp di, ax
       jge insert_done

       mov al, [si]
       mov contactBook[di], al
       inc si
       inc di
       
       loop insert_loop
          
           
insert_done:
       ret 
insert endp
 
                
                
  
ends

end start ; set entry point and stop the assembler.
