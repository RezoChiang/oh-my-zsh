function prompt_char {
	if [ $UID -eq 0 ]; then echo "#"; else echo $; fi
}

if [ "$(typeset -f shrink_path)" = "" ]; then
    PROMPT='%(!.%{$fg_bold[red]%}.%{$fg_bold[green]%}%n@)%m %{$fg_bold[blue]%}%(!.%1~.%~) $(git_prompt_info)%_$(prompt_char)%{$reset_color%} '
else
    PROMPT='%(!.%{$fg_bold[red]%}.%{$fg_bold[green]%}%n@)%m %{$fg_bold[blue]%}$(shrink_path -f) $(git_prompt_info)%_$(prompt_char)%{$reset_color%} '
fi

ZSH_THEME_GIT_PROMPT_PREFIX="("
ZSH_THEME_GIT_PROMPT_SUFFIX=") "
