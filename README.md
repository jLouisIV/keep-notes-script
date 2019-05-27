# Google Takeout Keep notes file converter

This is a simple Bash script that converts the Keep .html files from Google Takeout into usable Markdown files. These files (along with other Google account data) can be exported from https://takeout.google.com/settings/takeout.



## How to run the script?
1. Move the script into the extracted Takeout archive folder (which will have a subfolder 'Keep')
2. Make sure that the script is executable

```sh
chmod +x keep-notes-script.sh
```

3. Run the script

```sh
./keep-notes-script.sh
```



## What type of notes are supported?

Because of how the data is stored in the .html files, this script only extracts text and numbered lists. Other types of data (i.e. checkboxes) won't cause errors, but very little of their content will be extracted.



## Does the script preserve tags?

Yes, the script will save notes with a single tag to a file of that tag name. Any notes with two or more tags will be saved to the 'MULTIPLE_TAGS' file and notes without any tags will be saved to the 'NOTES_NOT_TAGGED' file. Notes tagged with all characters that are not either alphanumeric, spaces, dashes, or underscores will be saved to the 'TAG_WITHOUT_VALID_CHARS' file.



## How are pinned notes dealt with?

Whether or not notes were pinned was not accounted for to decrease overhead. To bring pinned notes to the top of the exported Markdown files, the script would have had to read all the notes twice. Also, a standard way to signify that a note was pinned would make the Markdown files less clean and therefore less usable.



## Why are notes saved as Markdown files?

So that note titles could be marked as headings to differentiate them from a note's content. 



## How long does the script take to run?

On an i7-8750H CPU @2.20GHz, the time it took to process 2,809 notes which contained 136,819 words was: real 1m12.148s, user 0m55.015s, sys 0m34.377s.



## Does the script run in macOS?

As this script was written and tested in Linux (specifically Ubuntu 18.04.2 LTS) it uses GNU sed not BSD/macOS sed. To get the script to run on macOS follow these steps:

1. If you don't already have it, install Homebrew https://brew.sh/
```sh
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

2. Install GNU sed

```sh
brew install gnu-sed
```

3. Find and replace 'sed' with 'gsed' within the script

When testing this the content of the notes was successfully extracted however, 'spanspan' was appended to file names derived from tags and entirely replaced the name of the 'TAG_WITHOUT_VALID_CHARS' file.
