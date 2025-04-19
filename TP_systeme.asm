;multi-segment executable file template.

data segment
    
    ; add your data here!
    pkey db "press any key...$"
       
    ;constants 
    nameSize equ 10
    max equ 16
    phoneSize equ 10 
    bookSize equ max*20
    
    ; contact list structure     
        
    contactBook db bookSize dup(0)  ;array of16 contacts containing a name & phonenum 10bytes each
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
    
    ;error messages 
    full db "Unable to add a contact : contact book is full$"
    notFound db "Contact not found.$"
    duplicate db " a Contact with the same name already exists : saved as copy$"
       
ends
   
   
                      
                      
                      
stack segment
    dw   256  dup(?)
ends



code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax  
    
    ;initialization 
    mov count, 0

    call add_contact 
            
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ;wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h  ;exit to operating system.
    int 21h  
      
      
      
      
    ; system functionalities 
    
    ;1-add a contact : 
    
    add_contact proc 
        
          ;check if not full
          mov ax, count
          cmp ax, bookSize
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
          
                      
          call find_pos                    
          call insert   ;insert   
          
          mov ax, count  ;move by one contact
          adc ax, 20  
          mov count, ax  
          jmp end_full  
          
full_msg: 
          ;display full book message
          lea dx, full
          mov ah, 9
          int 21h
          
                     
end_full:    
          ;display added contact message
          lea dx, added 
          mov ah, 9
          int 21h    
        
        
          ret
    add_contact endp 
        
        
        
        
        
        
    ;Helper functions
     
;----------find position alphabetical order store in dx---------------- 
    find_pos proc
         mov si, 0        ;array index 
         mov al, 0        ;initialize found boolean
         mov ah, 0        ;innerloop control boolean
         
outerLoop:
         mov bx, count
         cmp si, bx       ;while conditions
         jge endOuterLoop 
           
         cmp al, 0        ;store a found boolean in al
         jne endOuterLoop 
                
         mov di, 0 
innerLoop:
         cmp di,10        ;inner while conditions
         jge endInnerLoop  
         
         cmp ah, 0
         jne endInnerLoop
         
         ;compare
         mov bx, si
         add bx, di 
         mov dl, contactBook[bx]   ;di'th char of name at si 
         mov cl, dl    ;temp  
         call lowerCase     ;normalize dl 
              
         mov dl, name_buffer[di+2]
         call lowerCase    ;normalize buffer

         cmp cl,dl
         
         ;case1:name[i] < contact[j].name[i]          
  
         jge elseif 
         
         mov al,1
         mov ah,1
         jmp endif  
     
elseif:   
         ;case2 :name[i] > contact[j].name[i]
         jle else
         
         add si, 20   ;move by a contact (20bytes)
         mov ah, 1    ;exit innerloop
         jmp endif          
else:    
         ;case3 : the same char
         inc di
endif: 
         jmp innerLoop

endInnerLoop:
         
         cmp di, 10
         jl endmsg 
         
         ;display the name already exists
         lea dx, duplicate
         mov ah, 9
         int 21h                
endmsg:
         jmp outerLoop 
         
endOuterLoop:         
         mov dx, si  ;insert position
         
         
         ret                  
    find_pos endp





;--------------------------------------------------------------------------------    
;insert data in name_buffer and phone_buffer in the contactBook at offset DX
insert proc 
       ;shift the following contacts to the right  
       
       mov bx, count       
       mov si, bx
       
shift_lp:
       cmp si, dx 
       jle end_shift_lp
       
       mov di, 0   
copy_lp:
       mov bx, di
       add bx, si
       cmp di, 20
       jge  end_copy_lp
             
       mov al, contactBook[bx-20]
       mov contactBook[bx], al
       
       inc di ;move to next char
       jmp copy_lp 
              
end_copy_lp:
       sub si, 20 
       jmp shift_lp 
       
end_shift_lp:
       
       
       lea si, name_buffer + 2  ;si points the first char in buffer  
       mov al, [name_buffer + 1]
       mov ah, 0
       mov cx, nameSize+1  
       mov di, 0
insert_loop:
       cmp di, ax
       jge insert_done

       mov al, [si]
       mov bx, dx
       add bx, di
       mov contactBook[bx], al
       inc si
       inc di
       
       loop insert_loop
          
insert_done:
       ret 
insert endp 
       
  
;------------------------------------------------     
     lowerCase proc
        cmp dl, 61h
        jl no_transform
        cmp dl, 7Ah
        jg no_transform
        sub dl, 20h 
        
no_transform:
        
        ret
     lowerCase endp  
;------------------------------------------------     
     

ends     
end start    ; set entry point and stop the assembler.
