## 
#   Navigate directory history using <back> and <forward>. <back>  moves back to directories 
#   that the user has changed to in the past, and <forward> undoes <back>. See
#   bottom of file to determin <back> and <forward> keybindings.
# 

dirhistory_past=($PWD)
dirhistory_future=()
export dirhistory_past
export dirhistory_future

export DIRHISTORY_SIZE=30

# Pop the last element of dirhistory_past. 
# Pass the name of the variable to return the result in. 
# Returns the element if the array was not empty,
# otherwise returns empty string.
function pop_past() {
  eval "$1='$dirhistory_past[$#dirhistory_past]'"
  if [[ $#dirhistory_past -gt 0 ]]; then
    dirhistory_past[$#dirhistory_past]=()
  fi
}

function pop_future() {
  eval "$1='$dirhistory_future[$#dirhistory_future]'"
  if [[ $#dirhistory_future -gt 0 ]]; then
    dirhistory_future[$#dirhistory_future]=()
  fi
}

# Push a new element onto the end of dirhistory_past. If the size of the array 
# is >= DIRHISTORY_SIZE, the array is shifted
function push_past() {
  if [[ $#dirhistory_past -ge $DIRHISTORY_SIZE ]]; then
    shift dirhistory_past
  fi
  if [[ $#dirhistory_past -eq 0 || $dirhistory_past[$#dirhistory_past] != "$1" ]]; then
    dirhistory_past+=($1)
  fi
}

function push_future() {
  if [[ $#dirhistory_future -ge $DIRHISTORY_SIZE ]]; then
    shift dirhistory_future
  fi
  if [[ $#dirhistory_future -eq 0 || $dirhistory_futuret[$#dirhistory_future] != "$1" ]]; then
    dirhistory_future+=($1)
  fi
}

# Called by zsh when directory changes
chpwd_functions+=(chpwd_dirhistory)
function chpwd_dirhistory() {
  push_past $PWD
  # If DIRHISTORY_CD is not set...
  if [[ -z "${DIRHISTORY_CD+x}" ]]; then
    # ... clear future.
    dirhistory_future=()
  fi
}

function dirhistory_cd(){
  DIRHISTORY_CD="1"
  cd $1
  unset DIRHISTORY_CD
}

# Move backward in directory history
function dirhistory_back() {
  local cw=""
  local d=""
  # Last element in dirhistory_past is the cwd.

  pop_past cw 
  if [[ "" == "$cw" ]]; then
    # Someone overwrote our variable. Recover it.
    dirhistory_past=($PWD)
    return
  fi

  pop_past d
  if [[ "" != "$d" ]]; then
    dirhistory_cd $d
    push_future $cw
  else
    push_past $cw
  fi
}


# Move forward in directory history
function dirhistory_forward() {
  local d=""

  pop_future d
  if [[ "" != "$d" ]]; then
    dirhistory_cd $d
    push_past $d
  fi
}


# Bind keys to history navigation
function dirhistory_zle_dirhistory_back() {
  # Erase current line in buffer
  zle kill-buffer
  dirhistory_back 
  zle accept-line
}

function dirhistory_zle_dirhistory_future() {
  # Erase current line in buffer
  zle kill-buffer
  dirhistory_forward
  zle accept-line
}

# to figure out the escape codes use the shell builtin 'read'
# for example in osx pressing ctrl-leftarrow results in
# $ read
# ^[[1;5D
#
# note that ^[ sequence is equivalent to the [Esc] key, which is represented 
# by \e in the shell

zle -N dirhistory_zle_dirhistory_back

# alt-left as <back> (original plugin configuration)
# bindkey "\e[3D" dirhistory_zle_dirhistory_back # xterm
# bindkey "\e[1;3D" dirhistory_zle_dirhistory_back # xterm
# bindkey "\e\e[D" dirhistory_zle_dirhistory_back # putty
# bindkey "\eO3D" dirhistory_zle_dirhistory_back # gnu screen

# ctrl-left 
bindkey "\e[1;5D" dirhistory_zle_dirhistory_back

zle -N dirhistory_zle_dirhistory_future

# alt-right as <forward> (original plugin configuration)
#bindkey "\e[3C" dirhistory_zle_dirhistory_future
#bindkey "\e[1;3C" dirhistory_zle_dirhistory_future
#bindkey "\e\e[C" dirhistory_zle_dirhistory_future
#bindkey "\eO3C" dirhistory_zle_dirhistory_future

# ctrl-right
bindkey "\e[1;5C" dirhistory_zle_dirhistory_future




