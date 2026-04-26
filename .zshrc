# zsh generic config（PATH設定）
# Homebrew (Intel Mac) のコマンドを使えるようにする
export PATH="/usr/local/bin:$PATH"
# ローカルインストールのコマンドを使えるようにする
export PATH="$HOME/.local/bin:$PATH"

# Zplug（zshプラグインマネージャー）
# Zplug を読み込む
source /usr/local/opt/zplug/init.zsh
# 非同期処理ライブラリ（pure テーマが必要とする）
zplug "mafredri/zsh-async", from:github
# シンプルなプロンプトテーマ
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme
# 追加の補完定義（多くのコマンドの補完を強化）
zplug "zsh-users/zsh-completions"
# 入力中のコマンドを色分け（正しければ緑、間違いは赤）
zplug "zsh-users/zsh-syntax-highlighting", defer:2
# 過去の履歴から入力候補をグレーで表示
zplug "zsh-users/zsh-autosuggestions"
# 未インストールのプラグインがあればインストールするか確認
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi
# 全プラグインを有効化
zplug load

# zsh generic config（シェル設定・エイリアス・ユーティリティ関数）
# 言語を日本語に設定
export LANG=ja_JP.UTF-8
# デフォルトエディタを Neovim に設定
export EDITOR=nvim
# 設定ファイルの場所を指定（~/.config）
export XDG_CONFIG_HOME=~/.config
# pure テーマのプロンプト記号を $ に変更
export PURE_PROMPT_SYMBOL="$"
# fzf のデフォルト表示を画面上部20%に設定
export FZF_DEFAULT_OPTS='--height 20% --reverse'
# ディレクトリ名だけで cd できる（例: ~/Documents と打つだけ）
setopt auto_cd
# cd 時に前のディレクトリをスタックに積む（cd - で戻れる）
setopt auto_pushd
# ビープ音を無効化
setopt nobeep
# エイリアスでも補完を有効にする
setopt complete_aliases
# ファイル一覧を詳細表示（色付き）
alias ll="ls -lG"
# 隠しファイルも含めた詳細表示（色付き）
alias la="ls -laG"
# カレントディレクトリの .env を環境変数として読み込む
alias load='set -a; source ./.env; set +a;'
# .zshrc を再読み込み
alias reload='source ~/.zshrc'
# ghq 管理のリポジトリを fzf で選んで移動
alias repo='cd $(ghq list -p | fzf)'
# パイプで行数カウント（例: ls C → ls | wc -l）
alias -g C='| wc -l'

# カレントディレクトリ以下からファイル名で検索（大文字小文字無視）
function ffind() {
  command find . -iname "$1"
}

# ランダムなパスワード文字列を生成
function keygen() {
  local length=12
  echo "$(openssl rand -base64 $length)"
}

# UUID を小文字で生成
function uuid() {
  uuidgen | tr \[:upper:\] \[:lower:\]
}

# ローカルIPアドレス（IPv4）を表示
function ipv4() {
  ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
}

# グローバルIPアドレスを表示
function gip() {
  curl -s http://checkip.amazonaws.com
}

# zsh history（コマンド履歴の設定）
# 複数ターミナル間で履歴を共有
setopt share_history
# 重複するコマンドを履歴から削除
setopt hist_ignore_all_dups
# スペースで始まるコマンドは履歴に残さない
setopt hist_ignore_space
# 履歴検索時に重複を表示しない
setopt hist_find_no_dups
# 余分な空白を削除して履歴に保存
setopt hist_reduce_blanks
# 履歴ファイルの保存先
HISTFILE="$HOME/.zsh_history"
# メモリ上の履歴件数
HISTSIZE=100000
# ファイルに保存する履歴件数
SAVEHIST=100000
# 履歴検索でカーソルを末尾に移動する機能を読み込む
autoload history-search-end
# ↑方向の履歴検索を登録
zle -N history-beginning-search-backward-end history-search-end
# ↓方向の履歴検索を登録
zle -N history-beginning-search-forward-end history-search-end
# Ctrl+P で過去の履歴を検索
bindkey "^P" history-beginning-search-backward-end
# Ctrl+N で新しい履歴を検索
bindkey "^N" history-beginning-search-forward-end

# Git
alias fixup='git commit --fixup'
alias autosquash='git rebase -i --autosquash'
alias branch='git branch'
alias branchrename='git branch -m'
alias switch='git switch'
alias add='git add'
alias restore='git restore --staged'
alias commit='git commit -m'
alias commitamend='git commit --amend'
alias push='git push origin $(git branch --show-current)'
alias forcepush='git push --force-with-lease --force-if-includes origin $(git branch --show-current)'
alias pull='git pull origin'
alias merge='git merge'
alias mergeabort='git merge --abort'
alias checkout='git checkout -b'
alias stashlist='git stash list'
alias branchlist='git branch --list'
alias stash='git stash -m'
alias status='git status'
alias resetsoft='git reset --soft HEAD^'
alias resethard='git reset --hard HEAD^'
alias logoneline='git log --oneline'

stashapply() {
	git stash apply "stash@{${1:-0}}"
  }

stashdrop() {
    git stash drop "stash@{${1:-0}}"
  }

# Docker
# Docker CLI のタブ補完を有効化
fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit
compinit
alias -g DI='docker images | fzf | awk "{print \$3}"'
alias -g DC='docker ps | fzf | awk "{print \$1}"'
alias dsh='docker run --rm -it $(DI) sh'
alias dat='docker attach $(DC)'
alias drm='docker rm $(docker ps -aq)'
alias drmi='docker rmi $(docker images -f "dangling=true" -q)'
alias drmv='docker volume rm $(docker volume ls -qf dangling=true)'
alias attach='docker attach $(docker ps | grep app-1 | cut -c1-3)'
alias up='docker compose up'
alias down='docker compose down'
alias stop='docker compose stop'
alias build='docker compose build'

function cleanup {
  rm -f tmp/pids/server.pid && \
  docker container prune -f && \
  docker volume rm $(docker volume ls -q -f name=redis-data | fzf)
}

# rbenv（Rubyバージョン管理）を有効にする
export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"

# Ruby
alias rubocop='docker compose run --rm app bundle exec rubocop -a'
alias rspec='f() { docker compose run --rm -e "RAILS_ENV=test" app bundle exec rspec "$@"; [ -f  coverage/index.html ] && open coverage/index.html; }; f'
alias console='docker compose run --rm app bin/rails c'
alias routes='docker compose run --rm app bin/rails routes'
alias ridgepole='docker compose run --rm app bin/rake ridgepole:apply'
alias ridgepolet='docker compose run --rm -e "RAILS_ENV=test" app bin/rake ridgepole:apply'
alias run='docker compose run --rm app'

# fzf の設定を読み込む
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zoxide の設定を読み込む
eval "$(zoxide init zsh)"

# マシン固有の設定を読み込む（最後に読み込むことで他の設定を上書きできる）
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
