## pargs
#### How to Pipe arguments to a bash script    ...or bash aliases or bash functions.


#### $ pargs
`pargs` is a script for people who want to pipe lines of arguments to bash functions or aliases.

If we want the hard way, we can always call bash code from xargs like [this,](https://stackoverflow.com/questions/11003418/calling-shell-functions-with-xargs) But
do we really want to?

Why not make it really easy?    
`$ cat lines_of_data | pargs some_bash_function`    
And it works with any new bash function- as soon as we export our bash function or 
update our alias in `~/.bash_aliases`

##### Installation: 
Install `pargs` by downloading the single script, making it executable and putting it in `~/bin`    
The script should work on any Linux with bash installed.


    USAGE: pargs [options]... COMMAND [command options and arguments]... 
    	pargs reads each line of STDIN as an argument to pass to COMMAND
    
    ( The first non-option is always read as the COMMAND then it's args )
    pargs callsees COMMAND with the intial arguments, followed by the arguments 
    from STDIN. 
    
    Here's a typical xargs example:
     $ echo x|xargs echo
    Which opens xargs with the output from the first echo, and calls the 
    second echo with a single argument 'x'.
    
    Here's a typical pargs example:
     $ echo type|pargs type 
    Which opens pargs with the output from echo, and calls the 'type' 
    bash built-in with a single argument 'type'. 
    
    Unlike xargs, the command arguments to 'pargs' can be an normal command, 
    bash function or alias.
    
    This program calls bash, tells bash to source ~/.bash_aliases, then always
    calls your command, function, or alias.  Exported bash functions work on
    exported bash variables, but only if they've been exported.
    
    	-1 		same as --max-args=1 in xargs or GNU parallel.  
    			pargs will read all input lines, but calls command
    			repetitively with a single argument, instead of 
    			multiple arguments.
    
    	-i 		The program will ignore errors.  Since 240 lines 
    			are passed as args at once, this is only useful if
    			your program ignores errors as well.
    
    	--help		Prints this message.
    
#### Examples: 
    
##### Each line is a url:
     pargs < url_list.txt youtube-dl --get-title	
##### ffprobe needs single arg:
     find -type f -regex '.*mp4'|pargs -1 ffprobe	
##### Use the ll alias for ls to list all media files with full path: 
     find -type f -printf "$PWD/%P\n"|grep -aiE '(\.mp4|\.webm)$'|pargs ll
##### Use the ll alias, but inside a bash function that was exported from the current shell:
     dope () { ll "$@";}; export -f dope; find -regex .*webm|pargs dope
##### unicode
     echo HON\ _\ หมาโหด\ ดุด้วย\ \!\!\!\!\ HPR\ GAMER\ Replay\ \[\ Gemini\ \]\ \[zStN\]Koomanp\ 👌-uh6DJ-0h-i8.webm |pargs diff -s HON\ _\ หมาโหด\ ดุด้วย\ \!\!\!\!\ HPR\ GAMER\ Replay\ \[\ Gemini\ \]\ \[zStN\]Koomanp\ 👌-uh6DJ-0h-i8.webm 
##### use the output of `locate` to show an abbreviated version of video metadata
     mlocate -ir the.two.towers|grep -iE 'mp4|mkv'|pwhat -i1 2>&1 ffprobe |perl -ne 'print if /Stream|Input|Duration/'
#### use a youtube playlist to move every file with the youtube ID to the current directory
     fn () { find 2>/dev/null -type f -printf "$(pwd)/%P\n"|grep -ai --; } export -f fn; youtube-dl --get-id 'https://www.youtube.com/watch?v=6eq48cz0Skk&list=PLx6N3LVwgba0rcUWHxuD2ivRCgcLmKEjp'|pargs -1 fn |pargs mv -t . 
#### use a youtube playlist to rename each file with 01, 02, 03... prefixes in order
     fn () { find 2>/dev/null -type f -printf "$(pwd)/%P\n"|grep -ai --; } export -f fn; youtube-dl --get-id 'https://www.youtube.com/watch?v=6eq48cz0Skk&list=PLx6N3LVwgba0rcUWHxuD2ivRCgcLmKEjp'|pargs -1 fn |pargs tracknumber2.pl
#### find + move to trash
     find expression # then select lines with mouse to put on Xwindows 'primary selection' 
     xclip -o|pargs trashcan.sh  # trascan.sh is something like trash-cli, just moves all dirs or files to a trash folder.
     xsel|xargs -d\\n mv -vt /mnt/good_trash/  # same as above but with GNU xargs, and xsel instead of xclip, and an ad hoc trash directory instead of the GNOME trash system
#### select lines with mouse, put every line into an argument for arbitrary command
     ~~(xclip outputs each line  selected with the mouse for use with your command)
     xclip -o|pargs something.sh
     xclip -o|xargs -d\\n something.sh  # don't need pargs if it's a normal command
     alias selection-as-arguments='xclip -o|pargs'  # use same as above, easier to type

#### use xargs to pass a long url to a command so you don't have to single-quote it by hand.
     alias get_vid='xsel -b |xargs -d "\n"  youtube-dl -q -f 18 --no-playlist -- 2>/dev/null;echo xargs returns $?' 
     ( same thing in two parts with pargs ) 
     alias cl-args='xclip -o -selection clipboard|pargs'
     ( put below line into  ~/.bash_aliases so that pargs can call it, or export the bash function) 
     function get_18 { youtube-dl -q -f18 --no-playlist -- "$@" 2>/dev/null ||echo unknown failure&true; }  # silent failure is a bug
#### use find to match '.\*Waldge.\*.mp3', but pass to a bash function to select only files before a certain total duration.  This effects a sleep function for mpv.  The bash function simply calls mediainfo to get the time of a file in ms.  It keeps a running total of the seconds, but just prints each file in the argument list until the total exceeds the bash variable sleepyminutes
     export sleepyminutes=39; sleepy_accum () { (sleepyseconds=$((sleepyminutes * 60)); for a; do ss=`mediainfo --Inform='General;%Duration%' "$a"`; ((sleepy_a = sleepy_a +  (ss / 1000)));echo "$a"; if [[ "$sleepy_a" -gt "$sleepyseconds" ]]; then exit;fi;done;) }; export -f sleepy_accum; mpv --playlist=<(find -regex .*Waldge.*mp3 -printf "$PWD/%P\n" |pargs sleepy_accum)
>Nothing really to see here. You can replace the process substitution with `findXXX|mpv --playlist=-` and using `while read;do` in the above bash script would make the pargs call unnecessary.    
>So actually pargs isn't exactly vital here, but we're using pargs to use a script written for `script arg1 arg2 arg2...` and pargs allows us to use the script without refactoring the script into a bash loop with `while read`. So it's a normal use case.

#### FYI 
* As mentioned above, pargs always operates like `xargs --delimiter='\n'`.    
* pargs doesn't calculate the maximum command length from the environment like xargs, but instead keeps it rather low.    
* if standard input is nothing but empty data lines, pargs simply exits without error. xargs runs the exact same way if  called with `xargs --no-run-if-empty`.    
* Blank lines are currently ignored.  Because empty arguments of "" "" "" is not what is desired.    
* xargs always stops command execution when the command encounters an error.  pargs works the same, but allows an option to ignore error: `-i`    
* `pargs echo '$variable'` will not work since pargs will single quote `$variable` for the echo command.  You can use exported **variables**, but each exported **variable** you use will need to be used in a wrapper function or script, and not progammatically in the argument list for the command called by pargs.


Bugs: `pargs sudo customthing` (for functions and scripts in ~/bin) will not work since sudo needs normal commands, and doesn't use the $PATH for the user, but $PATH for root. Sudo should work inside scripts though.    


