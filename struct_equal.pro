PRO struct_equal,paramA,paramB,tol=tol,last_tag=last_tag
IF N_Elements(tol) EQ 0 THEN tol=1e-8

; if object is a structure or a pointer, continue iterating until get to objects that can be compared
type=size(paramA,/type)
IF type EQ 8 THEN BEGIN ;structure type
    tagsA=tag_names(paramA)
    tagsB=tag_names(paramB)
    ; check that tag names are the same
    IF array_equal((tagsA)[sort(tagsA)], (tagsB)[sort(tagsB)]) NE 1 THEN BEGIN
        print, last_tag
        print, 'structures do not have the same tags'
        print, 'structure 1 has tags:'
        print, tag_names(paramA)
        print, 'structure 2 has tags:'
        print, tag_names(paramB)
    ENDIF ELSE BEGIN
        FOR t_i=0L,N_tags(paramA)-1 DO BEGIN
            last_tag=tagsA[t_i]
            tol_comp=0
            ; find location of tag in paramB
            ind=WHERE(STRCMP(tagsB,tagsA[t_i]) EQ 1)
            type1=size(paramA.(t_i),/type)
            type2=size(paramB.(ind),/type)
            ; check that size of structures is the same
            IF array_equal(size(paramA.(t_i)), size(paramB.(ind))) NE 1 THEN BEGIN
                print,last_tag
                print,"the parameters have different sizes:"
                print,size(paramA.(t_i))
                print,size(paramB.(ind))
            ; check that types are the same
            ENDIF ELSE IF type1 NE type2 THEN BEGIN
                print,last_tag
                print,"the parameters have different types:"
                print,type1
                print,type2            
            ENDIF ELSE BEGIN
                ; continue iterating if structure is structure type or pointer type
                IF (type1 EQ 8) OR (type1 EQ 10) THEN BEGIN
                    struct_equal,paramA.(t_i),paramB.(ind),tol=tol,last_tag=last_tag
                ENDIF ELSE BEGIN
                    ; if structure is a numeric type do a tolerance comparison
                    IF ((type1 NE 7) AND (type1 NE 11)) THEN BEGIN
                        tol_comp=1
                        max_diff = MAX(ABS(paramA.(t_i)-paramB.(ind)),/NAN)
                        comp=(max_diff LT tol)
                        ; check if both arrays are full of NaNs
                        IF (FINITE(max_diff) EQ 0) AND ((FINITE(MAX(paramA.(t_i),/NAN)) EQ 0) AND (FINITE(MAX(paramB.(ind),/NAN)) EQ 0)) THEN BEGIN
                            comp=1
                        ENDIF  
                    ; otherwise do a direct comparison. this works even if objects being compared are not arrays
                    ENDIF ELSE BEGIN 
                        comp=ARRAY_EQUAL(paramA.(t_i),paramB.(ind))               
                    ENDELSE
                    IF comp eq 0 THEN BEGIN
                        print,last_tag
                        print,"the parameters do not match"
                        IF tol_comp EQ 1 THEN BEGIN
                            print,"max_diff:"
                            print,max_diff
                        ENDIF
                    ENDIF
                ENDELSE
            ENDELSE
        ENDFOR
    ENDELSE
ENDIF ELSE IF type EQ 10 THEN BEGIN ;pointer type
    ptr_i=where(Ptr_valid(paramA),n_valid)
    ptr_b=where(Ptr_valid(paramB),n_validb)
    ; check for null pointers
    IF n_valid NE n_validb THEN BEGIN
        print,last_tag
        print,"the parameters do not match"
    ENDIF ELSE BEGIN
        FOR p_i=0L,n_valid-1 DO BEGIN
            tol_comp=0
            type1=size(*paramA[ptr_i[p_i]],/type)
            type2=size(*paramB[ptr_i[p_i]],/type)
            ; check that objects are the same size
            IF array_equal(size(*paramA[ptr_i[p_i]]), size(*paramB[ptr_i[p_i]])) NE 1 THEN BEGIN
                print,last_tag
                print,"the parameters have different sizes:"
                print,size(*paramA[ptr_i[p_i]])
                print,size(*paramB[ptr_i[p_i]])
            ; check that objects are the same 
            ENDIF ELSE IF type1 NE type2 THEN BEGIN
                print,last_tag
                print,"the parameters have different sizes:"
                print,type1
                print,type2
            ENDIF ELSE BEGIN
                ; if have a structure or pointer, keep iterating through
                IF (type1 EQ 8) OR (type1 EQ 10) THEN BEGIN
                    struct_equal,*paramA[ptr_i[p_i]],*paramB[ptr_i[p_i]],tol=tol,last_tag=last_tag
                ENDIF ELSE BEGIN
                    ; if have a number array compare using the tolerance
                    IF ((type1 NE 7) AND (type1 NE 11)) THEN BEGIN
                        tol_comp=1
                        max_diff = MAX(ABS(*paramA[ptr_i[p_i]]-*paramB[ptr_b[p_i]]),/NAN)
                        comp=(max_diff LT tol)
                        ; check that both elements aren't actually full of NaNs
                        IF (FINITE(max_diff) EQ 0) AND ((FINITE(MAX(*paramA[ptr_i[p_i]],/NAN)) EQ 0) AND (FINITE(MAX(*paramB[ptr_b[p_i]],/NAN)) EQ 0)) THEN BEGIN
                            comp=1
                        ENDIF    
                    ; otherwise do a direct comparison. this works even if not an array               
                    ENDIF ELSE BEGIN
                        comp=ARRAY_EQUAL(*paramA[ptr_i[p_i]],*paramB[ptr_b[p_i]])
                    ENDELSE
                    IF comp eq 0 THEN BEGIN
                        print,last_tag
                        print,"the parameters do not match"
                        IF tol_comp EQ 1 THEN BEGIN
                            print, "max_diff:"
                            print,max_diff
                        ENDIF
                    ENDIF
                ENDELSE
            ENDELSE
        ENDFOR
    ENDELSE
ENDIF ELSE BEGIN
    message, "must submit a structure or pointer "
ENDELSE
END