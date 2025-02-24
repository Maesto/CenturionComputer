PROG  BEGIN    X'0100'      ; Set where program lives in memory
TOP   LDAB=    X'01'        ; Load 01 into A reg. byte
      STAB/    X'F140'      ; Store 01 in F140 -> Select D0/P1 (fixed)
      LDAB=    X'03'        ; Load 03 into A reg. byte
      STAB/    X'F148'      ; Store 03 in F148 -> Perform RTZ
      XFR=     X'0100',Y    ; Set max delay count to DC into Y reg.
      JSR/     DELY         ; Jump to DELY subroutine
      XFR=     X'3200',Z    ; Set max cylinder count into Z reg.
      CLR      X            ; Set current cylinder count to 0000 in X reg.
LOOP  STX/     X'F141'      ; Store cylinder count in sector address reg.
      LDAB=    X'02'        ; Load 02 into A reg. byte
      STAB/    X'F148'      ; Seek to cylinder sector address
      XFR=     X'0010',Y    ; Set max delay count to DC into Y reg.
      JSR/     DELY         ; Jump to DELY subroutine
      LDAB=    X'02'        ; Load 02 into A reg. byte
      STAB/    X'F143'      ; Store 02 in F143 -> Setup up format write bitmask
      DLY                   ; 4.55ms delay
      LDAB=    X'06'        ; Load 06 into A reg. byte
      STAB/    X'F148'      ; Store 06 in F148 -> Format write step 1
      DLY                   ; 4.55ms delay
      LDAB=    X'05'        ; Load 05 into A reg. byte
      STAB/    X'F148'      ; Store 05 in F148 -> Format write step 2
      XFR=     X'0010',Y    ; Set max delay count to DC into Y reg.
      JSR/     DELY         ; Jump to DELY subroutine
      LDAB=    X'00'        ; Load 00 into A reg. byte
      STAB/    X'F148'      ; Store 00 in F148 -> Read command
      XFR=     X'0010',Y    ; Set max delay count to DC into Y reg.
      JSR/     DELY         ; Jump to DELY subroutine
      LDAB/    X'F144'      ; Store Hawk Status Register 144 into A
      BNZ      ERR          ; Branch if not zero to ERR
      LDAB=    X'AE'        ; Load "." into A
      STAB/    X'F201'      ; Store A into F201 -> MUX port 1
      JMP      INCR         ; Jump to INCR label
ERR   LDBB=    X'10'        ; Load 10 into B reg. byte
      ANDB     AL,BL        ; BL = AL & BL	
      BZ       ER1          ; Branch is zero to ER1
      LDAB=    X'C6'        ; Load "F" into A
      STAB/    X'F201'      ; Store A into F201 -> MUX port 1
      JMP      INCR         ; Jump to INCR label
ER1   LDBB=    X'20'        ; Load 20 into B reg. byte
      ANDB     AL,BL        ; BL = AL & BL		
      BZ       ER2          ; Branch is zero to ER2
      LDAB=    X'D3'        ; Load "S" into A
      STAB/    X'F201'      ; Store A into F201 -> MUX port 1
      JMP      INCR         ; Jump to INCR label
ER2   LDBB=    X'40'        ; Load 40 into B reg. byte
      ANDB     AL,BL        ; BL = AL & BL		
      BZ       ER3          ; Branch is zero to ER3
      LDAB=    X'C3'        ; Load "C" into A
      STAB/    X'F201'      ; Store A into F201 -> MUX port 1
      JMP      INCR	        ; Jump to INCR label
ER3   LDAB=    X'D4'        ; Load "T" into A
      STAB/    X'F201'      ; Store A into F201 -> MUX port 1
INCR  XFR      X,Y          ; Transfer counter into Y
      SUB      Z,Y          ; Subtracts Z-Y -> 0x190 - Counter
      BNZ      INC2         ; Branch if Not Zero to INC2
      JMP/     TOP          ; If Zero, restart whole program
INC2  INR      X            ; Increment counter
      DLY                   ; 4.55ms delay
      JMP/     LOOP         ; Loop
DELY  DLY                   ; 4.55ms delay
      DCR      Y            ; Decrement Y value
      BNZ      DELY         ; Branch if Not Zero to DELY
      RSR                   ; Return from Subroutine