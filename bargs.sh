#!/bin/bash

# bargs copyright kanliot@github  2020 https://github.com/kanliot/pargs
# this file should be SOURCED, or added to ~/.bash_aliases.   it won't see your bash functions unless you export them.
# you *CAN* use this as a xargs or pargs replacement, with normal commands (but not your functions and aliases), by running this as a command with bash.

# uncomment for a failsafe.  this is BASH.  you can't use this to run zsh scripts. 
#if [ $0 -ne /bin/bash ]; then
#return
#fi


_bargs () 
{ 
# this function grabs a command as the first argument
# alternatively, takes two optional arguments -1 and -i must be in order.  see bargs() 
# each optional argument is optional.  
# then executes the command and rest of arguments, followed by the line read from stdin
# it ignores errors returned from command, and 199 stdin argument is done at a time
# does not ignore blank lines. oops, now it does. 
# uses perl to generate an error message, as the functions you call probably won't return an error messge
# bugs? `$ bargs cd < file` doesn't work.  adding a if [ $1 = cd ]; then cd `readline`; fi is on the todo list
(
unset NOERROR
SINGLE=199
test "$1" = -1 && { SINGLE=1; shift;}
test "$1" = -i && { NOERROR=1;shift;}


 while :; do
	mapfile -n $SINGLE -t 
	test 0 = ${#MAPFILE[@]} && exit 0;
	arf=(); 
	for a in "${MAPFILE[@]}"
	do test -z "$a" && continue; # don't want empty args
		arf+=("$a")
	done
	test 0 = ${#arf[@]} && continue; 
#        declare -p arf;
	if [ "$NOERROR" ]
	then 0</dev/tty eval "$@" '"${arf[@]}"';
	else 0</dev/tty eval "$@" '"${arf[@]}"'; 
		last=$?;
		test $last = 0 || { perl -E'say "bargs. command error:",$!=shift@ARGV';exit $last;}
	fi
    done)
}

bargs () { # helper function for _bargs.  always outputs -1 and -i in order as required.

unset opt_ignore opt_single
test $# = 0 && { echo >&2 bargs: no args; return 1;}  # no arguments is an error
for a 
	do if [[ $a =~ ^-[i1]{1,2}$ ]] 
		then # "matches: $a";
			shift
		case "$a" in
			--ignore) opt_ignore=1;;
			-ii) opt_ignore=1;;
			-i) opt_ignore=1;;

			--single) opt_single=1;;
			-11) opt_single=1;;
			-1) opt_single=1;;

			-1i)opt_ignore=1; opt_single=1;;
			-i1)  opt_ignore=1; opt_single=1;;
		esac 
	else break;
	fi
done
hash 2>/dev/null "$1" || alias "$1" 1>/dev/null 2>/dev/null || { echo >&2 bargs: "'$1'" is not a command/func/alias; return 1;} # check that first argument is command/alias by calling `hash`, then `alias`


_bargs ${opt_single:+-1} ${opt_ignore:+-i} "$@"
unset opt_ignore opt_single
}


bargs "$@"
