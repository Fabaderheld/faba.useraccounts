# Set up the prompt
setopt PROMPT_SUBST
setopt complete_aliases
autoload -U colors && colors
autoload -Uz promptinit
promptinit
prompt adam1


# to add other keys to this hash, see: man 5 terminfo
typeset -A key

key[Home]=${terminfo[khome]}

key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# setup key accordingly
[[ -n "${key[Home]}"     ]]  && bindkey  "${key[Home]}"     beginning-of-line
[[ -n "${key[End]}"      ]]  && bindkey  "${key[End]}"      end-of-line
[[ -n "${key[Insert]}"   ]]  && bindkey  "${key[Insert]}"   overwrite-mode
[[ -n "${key[Delete]}"   ]]  && bindkey  "${key[Delete]}"   delete-char
[[ -n "${key[Up]}"       ]]  && bindkey  "${key[Up]}"       up-line-or-history
[[ -n "${key[Down]}"     ]]  && bindkey  "${key[Down]}"     down-line-or-history
[[ -n "${key[Left]}"     ]]  && bindkey  "${key[Left]}"     backward-char
[[ -n "${key[Right]}"    ]]  && bindkey  "${key[Right]}"    forward-char
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"   beginning-of-buffer-or-history
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}" end-of-buffer-or-history

bindkey "e[1~" beginning-of-line
bindkey "e[4~" end-of-line
bindkey "e[5~" beginning-of-history
bindkey "e[6~" end-of-history
bindkey "e[3~" delete-char
bindkey "e[2~" quoted-insert
bindkey "e[5C" forward-word
bindkey "eOc" emacs-forward-word
bindkey "e[5D" backward-word
bindkey "eOd" emacs-backward-word
bindkey "ee[C" forward-word
bindkey "ee[D" backward-word
bindkey "^H" backward-delete-word

# for non RH/Debian xterm, can't hurt for RH/DEbian xterm
bindkey "eOH" beginning-of-line
bindkey "eOF" end-of-line

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init () {
        printf '%s' "${terminfo[smkx]}"
    }
    function zle-line-finish () {
        printf '%s' "${terminfo[rmkx]}"
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi


function check_last_exit_code() {
  local LAST_EXIT_CODE=$?
  if [[ $LAST_EXIT_CODE -ne 0 ]]; then
    local EXIT_CODE_PROMPT=' '
    EXIT_CODE_PROMPT+="%{$fg[red]%}-%{$reset_color%}"
    EXIT_CODE_PROMPT+="%{$fg_bold[red]%}$LAST_EXIT_CODE%{$reset_color%}"
    EXIT_CODE_PROMPT+="%{$fg[red]%}-%{$reset_color%}"
    echo "$EXIT_CODE_PROMPT"
  fi
}



function get_lz() {
	mountpoint -q /mnt/temp
	if [ $? -eq 0 ]
	then
		LZ_SIZE=$(df -h /mnt/temp | tail -1 | awk '{print $2}')
		LZ_FREE=$(df -h /mnt/temp | tail -1 | awk '{print $4}')
		SIZE_CALC=$(df /mnt/temp | tail -1 | awk '{print $2}')
		FREE_CALC=$(df /mnt/temp | tail -1 | awk '{print $4}')
		let FSP=$SIZE_CALC/100\*20
		if [ $FREE_CALC -lt $FSP ]
		then
			print %{$fg_bold[blue]%}LZ %{$fg_bold[red]%}$LZ_SIZE/$LZ_FREE%{$reset_color%}
		else
			print %{$fg_bold[blue]%}LZ %{$fg_bold[green]%}$LZ_SIZE/$LZ_FREE%{$reset_color%}
		fi
	fi
}

function get_smb() {
	MOUNTP=/mnt/samba/Greyhole\ Trash/
	mountpoint -q $MOUNTP
	if [ $? -eq 0 ]
	then
		SMB_SIZE=$(df -h $MOUNTP | tail -1 | awk '{print $3}')
		SMB_FREE=$(df -h $MOUNTP | tail -1 | awk '{print $5}')
		SIZE_CALC=$(df $MOUNTP | tail -1 | awk '{print $3}')
		FREE_CALC=$(df $MOUNTP | tail -1 | awk '{print $5}')
		#let SIZE_CALC=$SIZE_CALC\*1024
		let FSP=$SIZE_CALC/100
		if [ $FREE_CALC -lt $FSP ]
		then
			print %{$fg_bold[blue]%}SMB %{$fg_bold[red]%}$SMB_SIZE/$SMB_FREE%{$reset_color%}
		else
			print %{$fg_bold[blue]%}SMB %{$fg_bold[green]%}$SMB_SIZE/$SMB_FREE%{$reset_color%}
		fi
	fi
}



function get_root() {
	ROOT_SIZE=$(df -h / | tail -1 | awk '{print $2}')
	ROOT_FREE=$(df -h / | tail -1 | awk '{print $4}')
	SIZE_CALC=$(df / | tail -1 | awk '{print $2}')
	FREE_CALC=$(df / | tail -1 | awk '{print $4}')
	let FSP=$SIZE_CALC/100\*20
	if [ $FREE_CALC -lt $FSP ]
	then
		print %{$fg_bold[blue]%}/ %{$fg_bold[red]%}$ROOT_SIZE/$ROOT_FREE%{$reset_color%}
	else
		print %{$fg_bold[blue]%}/ %{$fg_bold[green]%}$ROOT_SIZE/$ROOT_FREE%{$reset_color%}
	fi
}

	

function get_load() {

	CPU=$(uptime | awk '{print $11}' | grep -o -E "[0-9]+[\.,][0-9][0-9]" | sed -r 's/[\.,][0-9][0-9]//')
	LOAD=$(uptime | awk '{print $11}' | grep -o -E "[0-9]+[\.,][0-9][0-9]")

	if [ -z $CPU ]
	then
		CPU=$(uptime | awk '{print $10}' | grep -o -E "[0-9]+[\.,][0-9][0-9]" | sed -r 's/[\.,][0-9][0-9]//')
		LOAD=$(uptime | awk '{print $10}' | grep -o -E "[0-9]+[\.,][0-9][0-9]")
	fi
	
	if [ $CPU -lt 6 ]
	then
		print %{$fg_bold[blue]%}CPU %{$fg_bold[green]%} $LOAD%{$reset_color%}
		return 0
	fi

	if [ $CPU -gt 10 ]
	then
		print %{$fg_bold[blue]%}CPU %{$fg_bold[red]%} $LOAD%{$reset_color%}
		return 0
	fi

	if [ $CPU -gt 5 ]
	then
		print %{$fg_bold[blue]%}CPU %{$fg_bold[yellow]%} $LOAD%{$reset_color%}
		return 0	
	fi


}

function get_gh(){
	which greyhole 2>&1 >/dev/null
	if [ $? -gt 0 ]
	then
		return 1
	else	
	
		TMP=$(greyhole -q | grep Total)
		GH_WRITE=$(echo $TMP | awk '{print $2}')
		GH_DELETE=$(echo $TMP | awk '{print $3}')
		GH_RENAME=$(echo $TMP | awk '{print $4}')

		print %{$fg_bold[blue]%}GH %{$fg_bold[green]%}$GH_WRITE%{$fg_bold[blue]%}/%{$fg_bold[red]%}$GH_DELETE%{$fg_bold[blue]%}/%{$fg_bold[yellow]%}$GH_RENAME%{$reset_color%}
	fi
}

which greyhole 2>&1 >/dev/null
if [ $? -eq 0 ]
then
	RPROMPT='[$(get_load)  $(get_root) $(get_lz) $(get_smb) $(get_gh)] $(check_last_exit_code)'
else
	RPROMPT='[$(get_load)  $(get_root)] $(check_last_exit_code)'
fi
	



setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

function autoshutdown()
{
        if [ ! -e /var/spool/autoshutdown/shutdown_off ]
        then
                touch /var/spool/autoshutdown/shutdown_off
                #chmod 777 /tmp/shutdown_off
                chown :remoteadmin /var/spool/autoshutdown/shutdown_off
                echo "autoshutdown turned off"


        elif [ -e /var/spool/autoshutdown/shutdown_off ]
        then
                rm /var/spool/autoshutdown/shutdown_off
                echo "autoshutdown turned on"
        fi



}

function series-move() 
{
	if [ "$1" = "-t" ]
	then
		MODE="test"
	else
		MODE="move"
	fi

	filebot --action $MODE  -rename -no-xattr --log all --log-file /tmp/filebot.log --db TheTVDB --format "/mnt/samba/serien/{n.sortName()}/Season_{s.pad(2)}/{n.space('.')}.{S00E00}.{t.space('.').replace('&','and')}{'.'+vf.match(/720[pP]|1080[pP]/)}{'.'+source.replace('HD.TV','HDTV')}{if (media.Audio_Language_List == 'German English' || media.Audio_Language_List == 'English German' || media.Audio_Language_List == 'English Deutsch' || media.Audio_Language_List == 'Deutsch English' || media.Audio_Count >= '2') '.DL' }" -r -non-strict $1

}





alias -g ls='ls --color=auto'
alias -g ll='ls -alFh'
alias -g la='ls -A'
alias -g l='ls -CF'
alias -g mkdir='mkdir -p'
alias -g youtube-dl='youtube-dl -o "%(title)s.%(ext)s"'
alias -g freespace="df -h /dev/sda1"
alias -g freespace-all="df -h /dev/sd{a..z}1"
alias -g lz="df -h /mnt/temp"
alias -g autoshutdownstatus='cat /var/log/syslog | grep -v CRON | grep AutoShutdown'
alias -g wake-nas='wakeonlan 00:14:FD:10:F4:F0'
alias -g mountt='mount | column -t | sort'
alias -g less="less -R"
alias -g grep='grep --color=auto'
alias -g fgrep='fgrep --color=auto'
alias -g egrep='egrep --color=auto'
alias -g sort='sort -h'
alias -g greyhole-trash='du /mnt/drive{1..10}/gh/.gh_trash -hs | sort -h'

export ZSH=$HOME/.oh-my-zsh

plugins=(git knife ssh-agent)

source $ZSH/oh-my-zsh.sh



zstyle :omz:plugins:ssh-agent agent-forwarding on



export PATH=/opt/puppetlabs/bin/:$PATH

keychain id_rsa id_dsa
. ~/.keychain/`uname -n`-sh
