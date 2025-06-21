# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# for hyprpolkitagent
export QT_QPA_PLATFORM=wayland

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="funky"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git colored-man-pages command-not-found fzf)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

packages-by-date() {
  pacman -Qi |
  grep '^\(Name\|Install Date\)\s*:' |
  cut -d ':' -f 2- |
  paste - - |
  while read pkg_name install_date
  do
  install_date=$(date --date="$install_date" -Iseconds)   
  echo "$install_date   $pkg_name"
  done | sort
}

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# --- System Logs & Power Commands ---
alias error='journalctl -b -p err'                        # View boot errors only
alias bye='sudo shutdown now'                             # Shutdown system immediately
alias brb='sudo reboot now'                               # Reboot system
alias please='sudo'                                       # Type 'please' instead of 'sudo'

# --- Network Info ---
alias myip='curl ipinfo.io/ip'                            # Show public IP address

# --- Terminal Basics ---
alias c='clear'                                           # Clear the terminal screen
alias ls='eza --group-directories-first --icons=always'   # Better ls output with icons

# --- Configuration Shortcuts ---
alias hypredit='nano .config/hypr/hyprland.conf'          # Edit Hyprland config
alias zshedit='nano .zshrc'                               # Edit Zsh config
alias zshreload='source .zshrc'                           # Reload Zsh config

# --- Navigation with ls ---
function cdls() {
	chdir $@
    eza --group-directories-first --icons=always
}
alias cd='cdls'

function zls() {
    z $@
    eza --group-directories-first --icons=always
}
alias z='zls'

# --- Yazi CD on exit ---
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# --- Text File Uploading ---
# FOR FILES:    0x0 < filename
# FOR COMMANDS: command | 0x0
alias 0x0="curl -F 'file=@-' 0x0.st"

# --- YouTube Downloads ---
alias youtube-dl='yt-dlp'
alias yt-dlp-mp3='youtube-dl -x --audio-format mp3 --audio-quality 0 --add-metadata'

# --- Package Management ---
alias pkglist='pacman -Qs --color=always | less -R'
alias listpackages="pacman -Qqe"
alias listpackages-date='packages-by-date'
alias listpackages-detailed="pacman -Qqe | fzf --preview 'pacman -Qil {}' --layout=reverse --bind 'enter:execute(pacman -Qil {} | less)'"
alias killorphans="sudo pacman -Rnu $(pacman -Qtdq)"
alias pacins='sudo pacman -S'
alias pacupg='sudo pacman -Syu'

# --- Flatpak Shortcuts ---
alias zen='flatpak run app.zen_browser.zen'

# --- SSH ---
alias laptop='ssh luki@10.0.140'

# --- Fonts ---
alias fonts='fc-list : family | sort | uniq'
alias findfont='fonts | grep -i'


export PATH=$PATH:/home/luki/.spicetify

# Following line was automatically added by arttime installer
export MANPATH=/home/luki/.local/share/man:$MANPATH

# Following line was automatically added by arttime installer
export PATH=/home/luki/.local/bin:$PATH

eval $(thefuck --alias)

export PATH=$HOME/.config/rofi/scripts:$PATH
