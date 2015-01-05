# ALIAS (run 'source ~/.bash_profile' to activate)

# RUN source ~/.bash_profile to reload profile

  # Vagrant Alias
  alias vg=/usr/bin/vagrant

  # Colorize grep
  alias grep="grep --color=always"

  # Color Directory
  alias ls="ls -G"

  # Color cat
  alias cat="pygmentize -g"

# Export

  # Set JAVA_HOME
  export JAVA_HOME=$(/usr/libexec/java_home)

  # Make working directory appear in the window title
  export PROMPT_COMMAND='echo -ne "\033]0;$PWD\007"'

  # Set EC2_HOME
  export EC2_HOME=/usr/local/ec2/ec2-api-tools-1.7.1.3

  # Add the default location of MySQL binary to your shell environment
  #export PATH=/usr/local/mysql/bin:$PATH

# http://code-worrier.com/blog/autocomplete-git/
if [ -f ~/.git-completion.bash ]; then
    . ~/.git-completion.bash
fi
