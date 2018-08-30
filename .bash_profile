# ALIAS (run 'source ~/.bash_profile' to activate)

  # Vagrant Alias
  alias vg=/usr/local/bin/vagrant

  # Sublime Alias
  alias subl="/Users/hfranco/bin/subl -n"

  # Colorize grep
  alias grep="grep --color=always"

  # Git aliases
  alias gm="git checkout master"
  alias gf="git fetch"
  alias gp="git pull"
  alias gs="git status"

  # Color Directory
  alias ls="ls -G"

  alias ll="ls -l"

  # Color cat
  alias cat="pygmentize -g"

  # SSH
#  alias ssh="ssh -lhfranco"

  # twidge show 20 most recent updates
  alias trecent="twidge lsrecent -su"

  alias ga="gitansible"
# Export

  # Show fullpath on terminal
#  export PS1='\u@\H [\w]$ '
 
  # Set JAVA_HOME
#  export JAVA_HOME=$(/usr/libexec/java_home)

  # Make working directory appear in the window title
#  export PROMPT_COMMAND='echo -ne "\033]0;$PWD\007"'

  # Set EC2_HOME
  export EC2_HOME=/usr/local/ec2/ec2-api-tools-1.7.1.3

  # Add the default location of MySQL binary to your shell environment
  #export PATH=/usr/local/mysql/bin:$PATH

# http://code-worrier.com/blog/autocomplete-git/
if [ -f ~/.git-completion.bash ]; then
    . ~/.git-completion.bash
fi

##
# Your previous /Users/hfranco/.bash_profile file was backed up as /Users/hfranco/.bash_profile.macports-saved_2017-02-13_at_12:02:07
##

# MacPorts Installer addition on 2017-02-13_at_12:02:07: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.


# Setting PATH for Python 2.7
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
export PATH

# Setting PATH for Python 3.6
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.6/bin:${PATH}"
export PATH

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
