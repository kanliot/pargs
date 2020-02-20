# pargs
How to Pipe arguments to a bash script.    
...or bash aliases or bash functions.

#### $ pargs
`pargs` is a drop in script for people who want to pipe lines of arguments to bash code, in the format of a simple to use command.

We, can always call bash code like [this,](https://stackoverflow.com/questions/11003418/calling-shell-functions-with-xargs) But
do we really want to?

Why not make it really easy?   And it should work- as soon as we export our bash function or 
update our alias in `~/.bash_aliases`


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
    
    Four examples: 
    
##### Each line is a url:
     pargs < url_list.txt youtube-dl --get-title	
##### ffprobe needs single arg:
     find -type f -regex '.*mp4'|pargs -1 ffprobe	
##### Use the ll alias for ls to list all media files with full path: 
     find -type f -printf "$PWD/%P\n"|grep -aiE '(\.mp4|\.webm)$'|pargs ll
##### Use the ll alias, but inside a bash function that was exported from the current shell:
     dope () { ll "$@";}; export -f dope; find -regex .*webm|pargs dope