; multi-segment executable file template.

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
    enterName db "Enter the contact's name : $",13,10 
    enterPhone db "Enter the contact's phone number :$",13,10 
    
    added db "contact added succesfuly.$",13,10  
    exit db 10,10,"Exit program ....$",13,10
    
    ;error messages 
    full db "Unable to add a contact : contact book is full$"
    notFound db "Contact not found.$"
    duplicate db " a Contact with the same name already exists : saved as copy$"  
    
    ;menue
    menu db 13,10,"+----------------------------------------------------+",13,10
         db "|              CONTACT BOOK MAIN MENU                |",13,10
         db "+----------------------------------------------------+",13,10
         db "|  1. View all contacts                              |",13,10
         db "|  2. Add a contact                                  |",13,10
         db "|  3. Search for a contact                           |",13,10
         db "|  4. Modify a contact                               |",13,10
         db "|  5. Delete a contact                               |",13,10 
         db "|----------------------------------------------------|",13,10
         db "|  6. Exit                                           |",13,10
         db "+----------------------------------------------------+",13,10
         db "--->> Choose an option:  $",13,10
         
          
    modify db "+---------------------------------------------------+",13,10
           db "| 4. Modify a contact                               |",13,10
           db "|     a. Modify the name                            |",13,10
           db "|     b. Modify the phone number                    |",13,10
           db "+---------------------------------------------------+",13,10
         
    option db ?
    dm db 0
    invalid_mg db "Invalid choice : please choose from the above ooptions (1-5) $",13,10 
    
    
    ;dsiplay
    allContacts db "+--------------- CONTACTS LIST ---------------+",13,10
    
    name db "| Name : $"
    number db "|Phone number : $"
    lineEnd db "           |$",13,10 
    line db "+---------------------------------------------------+",13,10
    
       
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
    call display_menu

 
      
         
    ;utility functions:     
    clear_screen proc
        ret
    clear_screen endp
     
     
    ;exit the program and display a message
    exit_program proc 
        
        lea dx, exit  ;print exiting message
        mov ah, 9
        int 21h
        
        call delay
          
        mov ax, 4c00h ; exit to operating system.
        int 21h
        

    exit_program endp  
    
    ; creates a time delay 
    delay proc
        mov cx,0Fh
        lea si, dm ;source string   
        rep lodsb 
        ret
    delay endp
      
      
              
    ;placeholders:
    
    ;displays all the contacts     
    display_contacts proc 
        
        lea dx, allContacts
        mov bx, count   ;size of all contacts 
        
    ret
    display_contacts endp  
   
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
    add_contact proc
        ret
    add_contact endp
    
    search_contact proc
        ret
    search_contact endp
    
    modify_contact proc
        ret
    modify_contact endp
    
    delete_contact proc
        ret
    delete_contact endp
      
          
          
          
    display_menu proc
    
        ;display the menu and prompt message 
        lea dx, menu
        mov ah, 9
        int 21h
    
    valid_choice_lp:  
        ; read user's choice
        mov ah, 1
        int 21h
    
        ; select the operation performed 
        cmp al, '1'
        jne case2
        call display_contacts 
        jmp end_valid_choice_loop
    
    case2:
        cmp al, '2'
        jne case3
        call add_contact
        jmp end_valid_choice_loop
    
    case3:
        cmp al, '3'
        jne case4
        call search_contact 
        jmp end_valid_choice_loop
    
    case4:
        cmp al, '4'
        jne case5
        call modify_contact 
        jmp end_valid_choice_loop
    
    case5:
        cmp al, '5'
        jne case6
        call delete_contact
        jmp end_valid_choice_loop

    case6:
        cmp al, '6'
        jne default 
        call exit_program
        jmp end_valid_choice_loop
        
    default:
        lea dx, invalid_mg
        mov ah, 9
        int 21h
        jmp valid_choice_lp
                      
    end_valid_choice_loop:
            
        ret
    display_menu endp  

ends

end start ; set entry point and stop the assembler.
