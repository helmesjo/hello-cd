function(replace_in_file FILE OLD NEW)
    file(READ ${FILE} FILE_CONTENT)
    string(REPLACE ${OLD} ${NEW} FILE_CONTENT_NEW ${FILE_CONTENT})
    file(WRITE ${FILE} ${FILE_CONTENT_NEW})
endfunction()

# If variables are defined, persume we are in script mode
if(FILE AND OLD AND NEW)
    
    replace_in_file(
        ${FILE} 
        ${OLD} 
        ${NEW}
    )

    return()
endif()