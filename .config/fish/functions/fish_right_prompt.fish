function fish_right_prompt
    string join "" -- $(set_color brblack) $(prompt_pwd --full-length-dirs 2) $(fish_git_prompt) $(set_color normal) " "
end
