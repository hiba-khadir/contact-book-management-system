; multi-segment executable file template.
         
         
;======================== data segment==============================         
data segment
    

    pkey db "press any key...$"   
    
    ;constants
     
    nameSize equ 10
    max equ 16
    phoneSize equ 10 
    
    contactSize equ nameSize + phoneSize 
    bookSize equ max* contactSize 
    
    
    ;contact list structure         
    contactBook db bookSize dup(0)  ;array of16 contacts(name & phonenum 10bytes each)
    
    count dw 0                      ;dynamic number of contacts 
                   
                  
                                                    
    ;local variables 
    name_buffer db nameSize+1
                db ?
                db nameSize+2 dup(0) 
                  
    phone_buffer db phoneSize+1
                 db ?
                 db phoneSize + 2 dup(0)
                 
                  
            ;search variables             
    found_num dw 0
    found_ind dw 16 dup(?) 
             ;duplicate boolean
    dup_bool db 0
    pushed_bool db 0            
    
    ;input/output messages
     
    ;add 
    enterName db  "Enter the contact's name : $"
    enterPhone db "Enter the contact's phone number : $"  
    
    ;modify
    enterNewName db "Enter the contact's new name : $"
    enterNewNum db  "Enter the contact's new phone number : $"
      
    deleteName db " Enter the contact's name to delete : $" 
    searchName db " Enter the contact's name to search for : $"  
    modifyContact db " Enter the contact's name to modify : $"
    
    ;sucess msgs
    deleted db    "Contact deleted succesfully.",13,10,"$"
    added db      "Contact added succesfuly.$"
    modified db "Contact modified succesfully.",13,10,"$"  
    exit db       "Exit program ....$"
    
    ;error messages 
    
    full db         "Unable to add a contact : contact book is full$"
    notFound db     "Contact not found.$"
    duplicate db    "a Contact with the same name already exists: addition aborted",13,10,"$" 
    
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
         db "--->> Choose an option:  $"
         
          
    modify db "+---------------------------------------------------+",13,10
           db "| 4. Modify a contact                               |",13,10
           db "|     a. Modify the name                            |",13,10
           db "|     b. Modify the phone number                    |",13,10 
           db "|     c. Modify the name and phone number           |",13,10
           db "+---------------------------------------------------+",13,10,"$"
            
            
    dm db 0 
    
    invalid_mg db "Invalid choice : please choose from the above.",13,10,"$" 
    
    
    ;dsiplay
    allContacts db "+------------------- CONTACTS LIST -------------------+$"
    
    name_field db "Name : $"
    number_field db 8 dup(32),"Phone number : $" 
    line db  "+-----------------------------------------------------+",13,10,"$"
    
    newline db 13, 10, "$" 
    indexing db ?
       
ends
     
     
;========================stack segment==============================
stack segment
    dw   256  dup(0)
ends
  
     
;======================== code segment==============================   
code segment
start:
    ; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
              
              
              
;======================= macros ======================
    ; prints a string 
    print macro src 
        
        lea dx, src
        mov ah, 9
        int 21h
        
    print endm
    
;-----------------------------------------------------  
    ;read a string into dest buffer
    read macro dest 
        
        lea dx, dest
        mov ah, 0Ah
        int 21h 
        
    read endm       
    
;------------------------------------------------
    ;convert first byte src to lowerCase     
    lowerCase macro src
    
        LOCAL end_lcase
    
        cmp src, 41h
        jl end_lcase
    
        cmp src, 5Ah
        jg end_lcase
        add src, 20h
    
    end_lcase:
    
        lowerCase endm
;---------------------------------------
          

     
;================================MAIN====================================
    
    ; repeat until the user exists
    mov al ,0           ; initialize user's choice

main_lp:
    
    call display_menu   ; display menu and select the operation exits if al = 6   
    call delay
    
    print newline
    print newline 
    print newline
    print pkey
        
    ;wait for any key....    
    mov ah, 1
    int 21h 
      
    call clear_screen 
    
    jmp main_lp         ;keep looping  

             
;==================system functions :=====================
;---------------------------------------------------    
    ;1- display all the contacts     
    display_all_contacts proc 
        pusha       
        print allContacts
        print newline
        print newline 
        
        mov bx, count   ;size of all contacts
        mov si, 0          
display_lp: 

        cmp si, count                   
        jge end_display_lp
                
        call display_contact
        print newline
        print newline

        ;move to next contact 
        add si, 11 
        
        jmp display_lp
        
end_display_lp:

        ;display a separation line 
        print newline
        print newline
        print line
        
        popa 
        ret
    display_all_contacts endp  
     
;---------------------------------------------    
    ;display one contact at index si 
    
    display_contact proc
        ;display the name 

        print name_field        
        print contactBook[si]

        
        ;display the phone number
        add si, 11   
         
        print number_field
        print contactBook[si] 

        
        ret
    display_contact endp
 
;---------------------------------------
 
 
    ;2- add a contact : 
    
    add_contact proc
          
          push si
          push di
                                                  
          ;check if not full
          mov ax, count
          cmp ax, bookSize
          jge full_msg 
          
          ;user input :
          ;prompt message :
          print newline
          print enterName
          
          ;read the name to the buffer        
          read name_buffer  
          
          ;prompt msg  
          print newline
          print enterphone 
          
          ;read the number to the buffer        
          read phone_buffer  
                                              
          ;normalize the buffer
          mov cl, name_buffer[1]
          mov ch, 0
          mov si, 0
          
     normalize_loop:
     
          lowerCase name_buffer[si+2]
          inc si
          loop normalize_loop
          
          ;add terminator    
          mov al, name_buffer[1] 
          mov ah, 0
          mov di, ax
          add di, 2
          mov name_buffer[di], "$"
          
          pop di
          pop si 
                                     
          call find_pos  ;find insertion position and returns it in dx                             
          ;check if the name already exists
          ;cmp dup_bool, 1
          ;jne insert_call
                   
          ;display the name already exists  
          ;print newline
         ; print duplicate 
          
          ; abort addition 
          ;jmp end_add_contact 
          
insert_call:          
                               
          call insert   ;insert   
           
          mov ax, count  ;move by one contact
          add ax, 22  
          mov count, ax  
          jmp end_full  
          
full_msg: 
          ;display full book message
          print full
          
                     
end_full:    
          ;display added contact message  
          print newline
          print added   
        
end_add_contact:        
          ret
    add_contact endp 
        
        
        
        
        
        
    ;Helper functions
     
;----------find position alphabetical order store in dx---------------- 
    find_pos proc
                 
         mov bx, 0        ;array index 
         
outerLoop: 
         
         cmp bx, count       ;while !EOarray 
         jge endOuterLoop 
         
         ;comparison loop       
         lea si, name_buffer+2
         lea di, contactBook[bx]                 
         
         mov cx, 11
         rep cmpsb
         
         je duplicate_signal
                           
         jl endOuterLoop   ;return bx
         
         add bx, 22   ;move to next contact if !found_pos
         
         jmp outerLoop
   

duplicate_signal:
         mov dup_bool, 1    ;signals a duplicate name
              
         
endOuterLoop:
         mov dx, bx                  
         ret                  
    find_pos endp


;--------------------------------------------------------------------------------    
insert proc
    
       pusha
        
       ;shift the following contacts to the right                
       mov si, count
       
shift_lp:
       cmp si, dx 
       jle end_shift_lp
       
       mov di, 0   
       
copy_lp:
       mov bx, di
       add bx, si
       cmp di, 22
       jge end_copy_lp
             
       mov al, contactBook[bx-22]
       mov contactBook[bx], al
       
       inc di ;move to next char
       jmp copy_lp 
              
end_copy_lp:
       sub si, 22 
       jmp shift_lp 
       
end_shift_lp:
       
       ;insert the name into the position dx       
       lea si, name_buffer + 2    ;si points the first char in buffer  
       mov cl, name_buffer + 1
       mov ch, 0  
       mov di, 0 
       
insert_name_lp:

       cmp di, cx           ;cx has the actual legnth entered
       jge insert_name_done
       
       lowerCase [si]
       mov al, [si]
       mov bx, dx
       add bx, di
       mov contactBook[bx], al
       inc si
       inc di
       
       jmp insert_name_lp
       
          
insert_name_done:
       mov di, cx
       add di, dx  
       mov contactBook[di], "$"


       ;insert the number into postition dx+10
       lea si, phone_buffer + 2     ;si points the first char in buffer  
       add dx, 11

       mov cl, [phone_buffer + 1]
       mov ch, 0  
       mov di, 0 

insert_phone_lp:
       cmp di, cx
       jge insert_phone_done

       mov al, [si]
       mov bx, dx
       add bx, di
       mov contactBook[bx], al
       inc si
       inc di
       
       jmp insert_phone_lp
          
insert_phone_done:
       mov di, cx
       add di, dx  
       mov contactBook[di], "$"
       
       popa
       
       ret 
insert endp





;------------------------------------------------     
     
    
    modify_contact proc
        
        ;prompt msg 
        print modifyContact

        ;read the name to the buffer        
        read name_buffer  
        
        print newline         
        ;search for the name
        call search_contact
        
        cmp found_num, 0
        jle end_modify
                 
        ;what field to modify 
        print Modify         
        
 option_lp:
        ;read user's choice
        mov ah, 1
        int 21h
        
        cmp al, 'a'
        je modify_name
        
        cmp al, 'b'
        je modify_number 
        
        cmp al, 'c'
        je modify_all
        
        ;invalid choice 
        print newline
        print invalid_mg 
        print newline
        
        jmp option_lp
               
 modify_name:
        print enterNewName  
        
        ;read new name
        read name_buffer   
        
        ;replace old name 
        lea si, name_buffer+2 
        mov bx, found_ind
                         
        lea di, contactBook[bx] 
              
        mov cl, [name_buffer+1]
        mov ch, 0
        rep movsb 
        
        ;append '$'
        mov [di], '$'
         
        jmp end_choice
        
 modify_number:
 
        print enterNewNum 
        
        ;read new number
        read phone_buffer   
         
        ;replace old phone number 
        lea si, phone_buffer+2  
        
        mov bx, found_ind         
        lea di, contactBook[bx+11] 
              
        mov cl, [phone_buffer+1]
        mov ch, 0
        rep movsb 
        
        ;append '$'
        mov [di], '$'
        
        jmp end_choice  
        
 modify_all: 
        
        ;name input
        print enterNewName  
        
        ;read new name
        read name_buffer   
        
        print newline
        
        ;replace old name 
        lea si, name_buffer+2 
        
        mov bx, found_ind 
        lea di, contactBook[bx]  
              
        mov cl, [name_buffer+1]
        mov ch, 0
        rep movsb 
        
        ;append '$'
        mov [di], '$'
        
                    
            
        ;phone number input
        print enterNewNum 
        
        ;read new number
        read phone_buffer   
        
        print newline
        
        ;replace old phone number 
        lea si, phone_buffer+2 
        mov bx, found_ind         
        lea di, contactBook[bx+11]   
              
        mov cl, [phone_buffer+1]  
        mov ch, 0
        rep movsb 
        
        ;append '$'
        mov [di], '$' 
               
 end_choice:
        print newline                
        print modified
                            
 end_modify:       
        ret
    modify_contact endp
   

;----3- delete a contact by name -----------
    
    delete_contact proc 
        
        
        ;prompt msg 
        print deleteName 
        
        ;read the name to the buffer        
        read name_buffer   
                    
        call search_contact         
        ;test if the contact was found  
        cmp found_num, 0
        jle end_delete
        
        mov bx, found_ind
        ;shift following contacts to the left
         
        ;traverse the contacts to shift
traversal_lp:                
        cmp bx, count 
        jge deleted_msg
        
        ;shift contacts
        lea si, contactBook[bx+22]
        lea di, contactBook[bx] 
        mov cx, 22 
        rep movsb          
        
        add bx, 22
        jmp traversal_lp

deleted_msg:        
        print deleted 
        sub count, 22
end_delete:    
    
        ret
    delete_contact endp
      
                                                                    
;----------search for a contact -------------
                                            
                                            
    search_contact proc     ;return is in found_ind array
        ;init           
        
        mov found_num, 0
        ;normalise 
        mov cl, name_buffer+1
        mov ch, 0
        mov si, 0 
        
normalise_lp:               
        lowerCase name_buffer[si+2]  
        inc si
        
        loop normalise_lp
        
        
        ;travers the contacts array and search for name
        
        ;set found boolean 
        mov dl, 0
        
        ;if array is empty :  not found 
        cmp count, 0        
        je not_found
       
        
        ;traverse all the list 
        mov ax, count
        mov bl, 22
        div bl 
        
        ;set loop ind cx to num of contacts 
        mov cl, al
        mov ch, 0  
        
        ;initialize array index
        mov bx, 0                
        
          
    traverse_lp:      
        
        ; comparison loop
        
        ;name at index bx  
        lea di, contactBook[bx]
        ;src string
        lea si, name_buffer+2      

   
        ;compare up to first terminator
                        
  comp_lp:
        ;while not end of strings      
        cmp [di],"$"  
        je end_comp_lp  
        
        cmp [si], 0Dh
        je end_comp_lp
        
        ;compare byte by byte :end if not equal
        cmpsb
        jne end_comp_lp
         
        jmp comp_lp

  end_comp_lp:        
        ;test if a match was found
        ;both strings ended          
        cmp [di],"$"  
        jne end_test  
        
        cmp [si], 0Dh
        jne end_test
        
        push si   ;save si's value
        
        mov si, bx
         
        print newline
        mov dl, 1      ;set found boolean to true 
        push dx        ;save dx
        
        call display_contact 
        
        push di
        ;save the index in the found_ind array
        mov di, found_num        
        mov found_ind[di], bx 
        
        pop di
        inc found_num 
        print newline
                    
        pop dx         ;retrieve dx 
        pop si         ;retrieve si         

              
  end_test:
        ;move to next contact in the array                                   
        add bx, 22         
        loop traverse_lp
        
        sub bx, 22
        
        ;not_found_test
        cmp dl, 0
        je not_found               
        jmp end_traverse_lp
               
    
     ;if not found 
    not_found:
        mov dl, 0    
        print notFound
        
    end_traverse_lp:            
        
        ret
    search_contact endp
    
              
     
     
 ;---------------utility functions:--

     
    clear_screen proc
        
        mov ah, 0
        mov al, 3
        int 10h 
        
        ret
    clear_screen endp
     
;--------------------------------------------   
    ;exit the program and display a message
    exit_program proc 
        
        print exit
        
        call delay
          
        mov ax, 4c00h ; exit to operating system.
        int 21h
        

    exit_program endp  
;---------------------------------------------    
    ; creates a time delay 
    delay proc
        mov cx,0Fh
        lea si, dm ;source string   
        rep lodsb 
        ret
    delay endp 
               
;--------------------------MAIN MENU-------------------------------------
    display_menu proc
        

        ;display the menu and prompt message 
        print menu
         
         
    valid_choice_lp:  
        ; read user's choice
        mov ah, 1
        int 21h
    
        ; select the operation performed 
        cmp al, '1'
        jne case2 
        call clear_screen 
        call display_all_contacts 
        jmp end_valid_choice_loop
    
    case2:
        cmp al, '2'
        jne case3 
        call clear_screen
        call add_contact
        jmp end_valid_choice_loop
    
    case3:
        cmp al, '3'
        jne case4 
        call clear_screen
       
        ;prompt mesg 
        print searchName 
       
        ;read the name to the buffer        
        read name_buffer ; 
       
        print newline
        print newline
        
 
        call search_contact         
        jmp end_valid_choice_loop
    
    case4:
        cmp al, '4'
        jne case5
        call clear_screen
        call modify_contact 
        jmp end_valid_choice_loop
    
    case5:
        cmp al, '5'
        jne case6 
        call clear_screen         
        call delete_contact
        jmp end_valid_choice_loop

    case6:
        cmp al, '6'
        jne default 
        call exit_program
        jmp end_valid_choice_loop
        
    default:
        print invalid_mg
        jmp valid_choice_lp
                      
    end_valid_choice_loop:
            
        ret
    display_menu endp     
          
          
  

ends

end start ; set entry point and stop the assembler.
