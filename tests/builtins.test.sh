#!/bin/bash

### cd and $PWD
cd /
echo $PWD
# stdout: /

### $OLDPWD
cd /
cd $TMP
echo "old: $OLDPWD"
cd -
# stdout-json: "old: /\n/\n"

### pushd/popd
set -o errexit
cd /
pushd $TMP
popd
pwd
# status: 0
# N-I dash/mksh status: 127

### Source
lib=$TMP/spec-test-lib.sh
echo 'LIBVAR=libvar' > $lib
. $lib  # dash doesn't have source
echo $LIBVAR
# stdout: libvar

### time block
# bash and mksh work; dash does't.  TODO: test substring
{ time { sleep 0.01; sleep 0.02; } } 2>_tmp/time.txt
cat _tmp/time.txt | grep --only-matching real
# Just check that we found 'real'.
# This is fiddly:
# | sed -n -E -e 's/.*(0m0\.03).*/\1/'
#
# status: 0
# stdout: real
# BUG dash status: 2
# BUG dash stdout-json: ""

### Exit builtin
exit 3
# status: 3

### Exit builtin with invalid arg 
exit invalid
# Rationale: runtime errors are 1
# status: 1
# OK dash/bash status: 2

### Export sets a global variable
# Even after you do export -n, it still exists.
f() { export GLOBAL=X; }
f
echo $GLOBAL
printenv.py GLOBAL
# stdout-json: "X\nX\n"

### Export sets a global variable that persists after export -n
f() { export GLOBAL=X; }
f
echo $GLOBAL
printenv.py GLOBAL
export -n GLOBAL
echo $GLOBAL
printenv.py GLOBAL
# stdout-json: "X\nX\nX\nNone\n"
# N-I mksh/dash stdout-json: "X\nX\n"

### Export a global variable and unset it
f() { export GLOBAL=X; }
f
echo $GLOBAL
printenv.py GLOBAL
unset GLOBAL
echo $GLOBAL
printenv.py GLOBAL
# stdout-json: "X\nX\n\nNone\n"

### Export existing global variables
G1=g1
G2=g2
export G1 G2
printenv.py G1 G2
# stdout-json: "g1\ng2\n"

### Export existing local variable
f() {
  local L1=local1
  export L1
  printenv.py L1
}
f
printenv.py L1
# stdout-json: "local1\nNone\n"

### Export a variable before defining it
export U
U=u
printenv.py U
# stdout: u
