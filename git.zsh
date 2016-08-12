alias gs='git status -sb'
alias gd='git diff'
alias gdc='git diff --cached'
alias gdoriginmaster='git diff origin/master'
alias gl='git log --decorate'
alias glogS='git log -p -S '
alias glgrep='git log --grep '
alias gf='git fetch'
alias gcommit='git commit -v -S'
alias gcheckout='git checkout '
alias gshow='git show '
alias gpush='git push '
alias greset='git reset '
alias gpull='git pull --rebase'
alias gclone='git clone '
alias gstash='git stash '
alias gadd='git add '
alias gtags='git tag --list | sort -V'
alias gpushtags='git push origin --tags'
alias gtags-latest='git tag --list | sort -V | tail -n 1'
alias gci-status='hub ci-status '

# Initiate _git which exposes the _git-* completions
_git

# Retrieve local and remote branches sorted by last commit to the branch
fbranch() {
  format="%(HEAD) %(refname:short)\
%09[%(color:green)%(committerdate:relative)]\
%(color:yellow) %(authorname) "
  local branches=$(git for-each-ref --sort=committerdate refs/heads refs/remotes --format=$format)
  local branch=$(echo $branches | fzf --ansi --exact --tac)
  # Get the branch name without all the other noise
  local branch_name=$(echo $branch | cut -c 3- | awk '{print $1}')
  echo $branch_name
}

gcheckoutcommit() {
  local commit=`fcommit`
  [[ -n $commit ]] && print -z git checkout $@ $commit
}

# TODO: Remove duplicate entries if branch exists locally
gcheckoutbranch() {
  local branch_name=$(fbranch)
  if [[ $branch_name =~ ^origin ]]; then
    # Strip the origin part. If we don't do this it won't checkout a new branch but will be in
    # detached state
    branch_name=$(echo $branch_name | sed -e 's/^origin\///')
  fi
  [[ -n $branch_name ]] && print -z git checkout $@ $branch_name
}

alias gcc=gcheckoutcommit
alias gcb=gcheckoutbranch
compdef _git-checkout gcheckoutcommit gcheckoutbranch

grebasecommit() {
  local commit=`fcommit`
  [[ -n $commit ]] && print -z git rebase -i $@ $commit
}

grebasebranch() {
  branch=`fbranch`
  [[ -n $branch ]] && print -z git rebase $@ $branch
}

compdef _git-rebase grebasecommit grebasebranch

# TODO: Use fzf
goneline() {
  n=${1:-10}
  git log --pretty=oneline --decorate=short | tail -n $n
}

gresetcommit() {
  commit=`fcommit`
  [[ -n $commit ]] && print -z git reset $@ $commit
}

gresetbranch() {
  branch=`fbranch`
  [[ -n $branch ]] && print -z git reset $@ `fbranch`
}

compdef _git-reset gresetcommit gresetbranch

gsha1() {
  print -z `fcommit`
}

_local_branch() {
  git symbolic-ref --short HEAD
}

_remote_branch() {
  remote=$(git remote)
  if [ $? != 0 ]; then
    return 1 # Returning $? will return the output of the if test. lol...
  fi

  if [ $(echo $remote | wc -l) = 1  ]; then
    branch=$(_local_branch)
    echo "$remote $branch"
  else
    echo 'More than 1 remote, specify which one to pull from'
    git remote
    return 1
  fi
}

gpullbranch() {
  branch=$(_remote_branch)
  [ $? = 0 ] && print -z git pull $@ $branch
}
compdef _git-pull gpullbranch

gpushbranch() {
  branch=$(_remote_branch)
  [ $? = 0 ] && print -z git push $@ $branch
}
compdef _git-push gpushbranch

alias gplb=gpullbranch
alias gpsb=gpushbranch

gcherry() {
  current_branch=$(_local_branch)
  unmerged_branch=$(git branch --no-merged $current_branch | cut -c 3- | fzf)
  commits=$(git rev-list $unmerged_branch --not $current_branch --no-merges --pretty=oneline --abbrev-commit | fzf -m)
  num_commits=$(echo $commits | wc -l)

  if [[ $num_commits -gt '2' ]]; then
    echo "Select 1 to 2 commits, starting at the oldest commit"
  elif [[ $num_commits -eq '1' ]]; then
    commit=$(echo $commits | awk '{print $1}')
    print -z git cherry-pick $commit
  elif [[ $num_commits -eq '2' ]]; then
    first=$(echo $commits | awk '{if (NR==1) print $1}')
    second=$(echo $commits | awk '{if (NR==2) print $1}')
    print -z git cherry-pick $first^..$second
  fi
}

gchangedfilesinbranch() {
  local changed_files=$(git --no-pager diff origin/master --name-only)
  local selected_files=$(echo $changed_files | fzf -m)
  local oneline=$(echo $selected_files | tr '\n' ' ')
  LBUFFER="${LBUFFER} $oneline"
  zle redisplay
}
zle -N gchangedfilesinbranch
bindkey -M vicmd '\-' gchangedfilesinbranch
