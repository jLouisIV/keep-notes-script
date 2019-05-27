#!/bin/bash
#A simple bash script that converts the Keep .html files from Google Takeout into usable Markdown files


#These variables are globally used throughout the script and determine various attributes of the output
#The extension that will be used for all outputted note files
FILE_EXTENSION="md"
#All notes that are not tagged will be output to this file
DEFAULT_OUT_FILE="NOTES_NOT_TAGGED"
#The location where all note files will be written to
NOTE_OUTPUT_DIRECTORY=$(pwd)

#_create_files creates all the files that the script will later write the content of the notes to
function _create_files {
    local flag=0
    for tag_FILE in ./*.html; do
        TAG_LINE=$(grep -n '<span class="chip label"><span class="label-name">' "$tag_FILE" | cut -f1 -d:)
        if [ -n "$TAG_LINE" ]; then
            TAG_LINE=${TAG_LINE//'\n'/' '}
            if [ $(echo $TAG_LINE | grep -o " " | wc -l) -gt 0 ] ; then
                TAG="MULTIPLE_TAGS"
            else
                TAG=$(sed -n $TAG_LINE"p" "$tag_FILE")
                TAG=${TAG//'<span class="chip label"><span class="label-name">'/''}
                TAG=${TAG//'</span>'/''}
                TAG=$(echo $TAG | tr -cd '[a-zA-Z0-9] _-')
                if [ -z "$TAG" ]; then
                    TAG="TAG_WITHOUT_VALID_CHARS"
                else
                    TAG=${TAG//' '/'_'}
                fi
            fi
            #Overwrites the content of all files to ensure that all files are empty before writing to them
            #Note that the function could even overwrite files that were just created by _create_files, this is to decrease the overhead that would be required to keep track of previous tag names
            echo -n > "${NOTE_OUTPUT_DIRECTORY}/${TAG}.$FILE_EXTENSION"
        elif [ "$flag" -eq 0 ]; then
            echo -n > "${NOTE_OUTPUT_DIRECTORY}/${DEFAULT_OUT_FILE}.$FILE_EXTENSION"
            flag=1
        fi        
    done
}

#_parse_files runs sequentially through all the .html files (in the 'Keep' folder) and executes the _read_note and the _write_note functions sequentially against each file's content
function _parse_files {
    local TITLE_LINE=""
    local TITLE=""
    local CONTENT_LINE=""
    local CONTENT=""
    local TAG_LINE=""
    local TAG=""
    for read_FILE in ./*.html; do
        _read_note
        _write_note
    done
}

#_read_note stores the title, content, and tags from the notes in variables to be written by the _write_note function
function _read_note {    
    TITLE_LINE=$(grep -n '<div class="title">' "$read_FILE" | cut -f1 -d:)
    if [ -n "$TITLE_LINE" ]; then
        TITLE=$(sed -n $TITLE_LINE"p" "$read_FILE")
    fi
    CONTENT_LINE=$(grep -n '<div class="content">' "$read_FILE" | cut -f1 -d:)
    if [ -n "$CONTENT_LINE" ]; then
        CONTENT=$(sed -n $CONTENT_LINE"p" "$read_FILE")
    fi  
    TAG_LINE=$(grep -n '<span class="chip label"><span class="label-name">' "$read_FILE" | cut -f1 -d:)
    if [ -n "$TAG_LINE" ]; then
        TAG_LINE=${TAG_LINE//'\n'/' '}
        if [ $(echo $TAG_LINE | grep -o " " | wc -l) -gt 0 ] ; then
            TAG="MULTIPLE_TAGS"
        else
            TAG=$(sed -n $TAG_LINE"p" "$read_FILE")
            TAG=${TAG//'<span class="chip label"><span class="label-name">'/''}
            TAG=${TAG//'</span>'/''}
            TAG=$(echo $TAG | tr -cd '[a-zA-Z0-9] _-')
            if [ -z "$TAG" ]; then
                TAG="TAG_WITHOUT_VALID_CHARS"
            else
                TAG=${TAG//' '/'_'}
            fi
        fi
    fi  
}

#_write_note outputs the title and content of notes into the appropriate files
function _write_note {
    local out_FILE=""
    if [ -n "$TAG_LINE" ]; then
        out_FILE="${TAG}.$FILE_EXTENSION"
    else
        out_FILE="${DEFAULT_OUT_FILE}.$FILE_EXTENSION"
    fi
    if [ -n "$TITLE_LINE" ]; then
        echo $TITLE >> "${NOTE_OUTPUT_DIRECTORY}/$out_FILE"
    fi
    if [ -n "$CONTENT_LINE" ]; then
        echo $CONTENT >> "${NOTE_OUTPUT_DIRECTORY}/$out_FILE"
    fi
    echo -e '\n\n' >> "${NOTE_OUTPUT_DIRECTORY}/$out_FILE"
}

#_clean_files strips the written output of all the residual html elements from the original note
#This process is applied to all files with the specified 'FILE_EXTENSION' within the directory that the script is run from - if the 'FILE_EXTENSION' variable is set to 'html' this will destroy the .html file used to browse all the contents of the Takeout archive
function _clean_files {
    for clean_FILE in ${NOTE_OUTPUT_DIRECTORY}/*.$FILE_EXTENSION; do
        sed -i 's/<\/div>//g' "$clean_FILE"
        sed -i 's/<div class="content">//g' "$clean_FILE"
        sed -i 's/<div class="title">/# /g' "$clean_FILE"
        sed -i "s/&#39;/'/g" "$clean_FILE"
        sed -i 's/<br><br>/\n/g' "$clean_FILE"
        sed -i 's/<br>/\n/g' "$clean_FILE"
    done
}

#Runs the script if there is a subdirectory named 'Keep' which has at least one .html file in it
if cd ./Keep ; then
    if ls ./*.html > /dev/null ; then
        _create_files
        _parse_files
        _clean_files
    else
        echo "./Keep does not contain any .html notes"
    fi

else
    echo "Place the script in the root of the 'Takeout' folder"    
fi
