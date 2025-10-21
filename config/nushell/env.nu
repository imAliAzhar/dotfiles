#  ____       _   _
# |  _ \ __ _| |_| |__
# | |_) / _` | __| '_ \
# |  __/ (_| | |_| | | |
# |_|   \__,_|\__|_| |_|


$env.PATH = [
    /bin
    /sbin
    /usr/bin
    /usr/sbin
    /usr/local/bin
    /opt/homebrew/bin
    /usr/local/opt/fzf/bin
    $"($env.HOME)/.bun/bin"
    $"($env.HOME)/.local/bin"
    $"($env.HOME)/.cargo/bin"
]

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

#=============================================================================#



#  ____                            _
# |  _ \ _ __ ___  _ __ ___  _ __ | |_
# | |_) | '__/ _ \| '_ ` _ \| '_ \| __|
# |  __/| | | (_) | | | | | | |_) | |_
# |_|   |_|  \___/|_| |_| |_| .__/ \__|
#                           |_|

def create_right_prompt [] {
    $"(ansi grey)($env.PWD | path basename)"
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = ""
# FIXME: This default is not implemented in rust code as of 2023-09-08.
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = {|| $"(ansi light_yellow)❀  " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

#=============================================================================#



#  __  __ _
# |  \/  (_)___  ___
# | |\/| | / __|/ __|
# | |  | | \__ \ (__
# |_|  |_|_|___/\___|

# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
    # FIXME: This default is not implemented in rust code as of 2023-09-06.
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
]

# Directories to search for plugin binaries when calling register
$env.NU_PLUGIN_DIRS = [
    # FIXME: This default is not implemented in rust code as of 2023-09-06.
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

#=============================================================================#
