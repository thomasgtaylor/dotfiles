#!/usr/bin/env bash
# Herdr Space PR icons. Requires bash 3.2+, git, jq, authenticated gh, and herdr.
# Run through Herdr's periodic command hook (30s interval, 25s timeout).
# Keep stdout empty: Herdr uses command output as visible tab-bar text.
# Colors belong in config.toml; this script reports only Nerd Font glyphs.
set -euo pipefail

herdr_bin=${HERDR_BIN_PATH:-herdr}
for dependency in "$herdr_bin" git jq gh; do
  command -v "$dependency" >/dev/null || {
    printf 'PR icons: missing dependency: %s\n' "$dependency" >&2
    exit 1
  }
done
export GH_PROMPT_DISABLED=1 GH_NO_UPDATE_NOTIFIER=1

github_branch() {
  local path=$1 branch remote repo
  [[ -n "$path" ]] || return 1
  branch=$(git -C "$path" symbolic-ref --quiet --short HEAD 2>/dev/null) || return 1
  remote=$(git -C "$path" remote get-url origin 2>/dev/null) || return 1
  case "$remote" in
    git@github.com:*) repo=${remote#git@github.com:} ;;
    https://github.com/*) repo=${remote#https://github.com/} ;;
    http://github.com/*) repo=${remote#http://github.com/} ;;
    ssh://git@github.com/*) repo=${remote#ssh://git@github.com/} ;;
    ssh://github.com/*) repo=${remote#ssh://github.com/} ;;
    *) return 1 ;;
  esac
  repo=${repo%/}
  repo=${repo%.git}
  [[ "$repo" =~ ^[^/]+/[^/]+$ ]] || return 1
  jq -cn --arg repo "$repo" --arg branch "$branch" '{repo: $repo, branch: $branch}'
}

select_icon() {
  jq -er --arg owner "$1" --arg branch "$2" '
    map(select(.headRefName == $branch and
      ((.headRepositoryOwner.login // "" | ascii_downcase) == ($owner | ascii_downcase))))
    | sort_by([(.state == "OPEN"), (.updatedAt // ""), .number]) | last
    | if . == null then ""
      elif .state == "OPEN" and .isDraft then "\uf4dd"
      elif .state == "OPEN" then "\uf407"
      elif .state == "MERGED" then "\uf419"
      elif .state == "CLOSED" then "\uf4dc"
      else "" end
  '
}

# A failed snapshot exits without changing metadata. Existing icons expire after 90s.
snapshot=$("$herdr_bin" api snapshot | jq -ce '.result.snapshot')
workspaces=$(jq -c '
  . as $snapshot | .workspaces[] | . as $w |
  {id: .workspace_id, had_icon: ((.tokens // {}) | has("pr_icon")),
   path: (.worktree.checkout_path // (
     $snapshot.panes | map(select(.workspace_id == $w.workspace_id))
     | sort_by([(.focused != true), (.tab_id != $w.active_tab_id)])
     | map(.foreground_cwd // .cwd) | map(select(. != null and . != "")) | .[0]
   ) // "")}
' <<< "$snapshot")

# Herdr prevents overlapping scheduled runs and bounds the whole run to 25 seconds.
while IFS= read -r workspace; do
  [[ -n "$workspace" ]] || continue
  wid=$(jq -r '.id' <<< "$workspace")
  path=$(jq -r '.path' <<< "$workspace")
  icon=
  identity=$(github_branch "$path" || :)
  if [[ -n "$identity" ]]; then
    repo=$(jq -r '.repo' <<< "$identity")
    branch=$(jq -r '.branch' <<< "$identity")
    if ! prs=$(gh pr list --repo "github.com/$repo" --head "$branch" --state all --limit 100 \
      --json number,state,isDraft,headRefName,headRepositoryOwner,updatedAt); then
      printf 'PR icon lookup failed for %s\n' "$repo" >&2
    elif ! icon=$(select_icon "${repo%%/*}" "$branch" <<< "$prs"); then
      printf 'PR icon response was invalid for %s\n' "$repo" >&2
      icon=
    fi
    # A branch/remote switch during the request invalidates its result.
    current_identity=$(github_branch "$path" || :)
    [[ "$current_identity" == "$identity" ]] || icon=
  fi
  if [[ -n "$icon" ]]; then
    "$herdr_bin" workspace report-metadata "$wid" --source user:pr-icons \
      --token "pr_icon=$icon" --ttl-ms 90000 >/dev/null || :
  elif [[ $(jq -r '.had_icon' <<< "$workspace") == true ]]; then
    "$herdr_bin" workspace report-metadata "$wid" --source user:pr-icons \
      --clear-token pr_icon >/dev/null || :
  fi
  # Agent rows read pane metadata; mirror this Space's PR status to its panes.
  while IFS= read -r pid; do
    [[ -n "$pid" ]] || continue
    if [[ -n "$icon" ]]; then
      "$herdr_bin" pane report-metadata "$pid" --source user:pr-icons \
        --token "pr_icon=$icon" --ttl-ms 90000 >/dev/null || :
    else
      "$herdr_bin" pane report-metadata "$pid" --source user:pr-icons \
        --clear-token pr_icon >/dev/null || :
    fi
  done < <(jq -r --arg wid "$wid" '.panes[] | select(.workspace_id == $wid) | .pane_id' <<< "$snapshot")
done <<< "$workspaces"
