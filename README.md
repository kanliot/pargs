How to Pipe arguments to a bash script.
...or bash aliases or bash functions.# pargs
How to Pipe arguments to a bash script.    
...or bash aliases or bash functions.

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
    pargs calls COMMAND with the intial arguments, followed by the arguments 
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


Bugs: `pargs sudo customthing` (for functions and scripts in ~/bin) will not work since sudo needs normal commands, and doesn't use the $PATH for the user, but $PATH for root. Sudo should work inside scripts though.    
Blank lines are currently ignored.  Because most likely lists of "" "" "" is not what is desired.    
`pargs echo '$variable'` will not work since $variable will be single quoted for the echo command. 
