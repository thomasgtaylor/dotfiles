#!/usr/bin/env bash
# Herdr PR status icon. Requires bash 3.2+, git, jq, authenticated gh, and herdr.
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

select_pr() {
  jq -c --arg owner "$1" --arg branch "$2" '
    map(select(.headRefName == $branch and
      ((.headRepositoryOwner.login // "" | ascii_downcase) == ($owner | ascii_downcase))))
    | sort_by([(.state == "OPEN"), (.updatedAt // ""), .number]) | last
  '
}

select_icon() {
  jq -er '
      if . == null then ""
      elif .state == "OPEN" and .isDraft then "\uf4dd"
      elif .state == "OPEN" then "\uf407"
      elif .state == "MERGED" then "\uf419"
      elif .state == "CLOSED" then "\uf4dc"
      else "" end
  '
}

# gh api --paginate emits one array per page; read all pages before choosing.
# Submitted Comment reviews supersede earlier change requests by that reviewer.
# Ordinary PR comments are not reviews. Approvals persist until a later change
# request or dismissal; a dismissal must not revive an older verdict. GitHub marks
# stale approvals DISMISSED where configured. Other review states on older
# commits need another review, indicated by the eye icon.
# GitHub marks human accounts as User and app/bot accounts as Bot.
select_review_icon() {
  jq -sr --arg head "$1" '
    add | map(select(.submitted_at != null and .state != "PENDING" and
      .user.type == "User")) as $reviews
    | [$reviews | group_by(.user.id // (.user.login | ascii_downcase))[]
       | sort_by([.submitted_at, .id]) as $history
       | ($history | map(select(.state == "APPROVED" or
           .state == "CHANGES_REQUESTED" or .state == "DISMISSED")) | last) as $verdict
       | if $verdict.state == "APPROVED" then $verdict else $history | last end
       | select(. != null)] as $verdicts
    | if any($verdicts[]; .state == "CHANGES_REQUESTED" and .commit_id == $head) then "\ueb43"
      elif any($verdicts[]; .state == "CHANGES_REQUESTED" and .commit_id != $head) then "\uea70"
      elif any($verdicts[]; .state == "APPROVED") then "\ueab2"
      elif any($verdicts[]; .state == "COMMENTED" and .commit_id == $head) then "\uea6b"
      elif any($verdicts[]; .state != "APPROVED" and .commit_id != $head) then "\uea70"
      else "" end
  '
}

# A failed snapshot exits without changing metadata. Existing icons expire after 90s.
snapshot=$("$herdr_bin" api snapshot | jq -ce '.result.snapshot')
workspaces=$(jq -c '
  . as $snapshot | .workspaces[] | . as $w |
  {id: .workspace_id,
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
  review_icon=
  identity=$(github_branch "$path" || :)
  if [[ -n "$identity" ]]; then
    repo=$(jq -r '.repo' <<< "$identity")
    branch=$(jq -r '.branch' <<< "$identity")
    if ! prs=$(gh pr list --repo "github.com/$repo" --head "$branch" --state all --limit 100 \
      --json number,state,isDraft,headRefName,headRepositoryOwner,updatedAt,headRefOid); then
      printf 'PR icon lookup failed for %s\n' "$repo" >&2
    elif ! pr=$(select_pr "${repo%%/*}" "$branch" <<< "$prs") ||
         ! icon=$(select_icon <<< "$pr"); then
      printf 'PR icon response was invalid for %s\n' "$repo" >&2
      icon=
    # Closed, merged, and draft states take precedence over reviews.
    elif [[ $(jq -r '.state == "OPEN" and (.isDraft | not)' <<< "$pr") == true ]]; then
      number=$(jq -r '.number' <<< "$pr")
      if ! review_icon=$(gh api --hostname github.com --paginate \
        "repos/$repo/pulls/$number/reviews?per_page=100" | select_review_icon "$(jq -r .headRefOid <<< "$pr")"); then
        printf 'PR review lookup failed for %s#%s\n' "$repo" "$number" >&2
        review_icon=
      fi
      [[ -z "$review_icon" ]] || icon=$review_icon
    fi
    # A branch/remote switch during the request invalidates its result.
    current_identity=$(github_branch "$path" || :)
    if [[ "$current_identity" != "$identity" ]]; then
      icon=
      review_icon=
    fi
  fi

  # Render one relevant icon, and clear the legacy separate review token.
  metadata=(--source user:pr-icons --ttl-ms 90000 --clear-token pr_review_icon)
  if [[ -n "$icon" ]]; then
    metadata+=(--token "pr_icon=$icon")
  else
    metadata+=(--clear-token pr_icon)
  fi
  "$herdr_bin" workspace report-metadata "$wid" "${metadata[@]}" >/dev/null || :
  # Agent rows read pane metadata; mirror this Space's PR status to its panes.
  while IFS= read -r pid; do
    [[ -n "$pid" ]] || continue
    "$herdr_bin" pane report-metadata "$pid" "${metadata[@]}" >/dev/null || :
  done < <(jq -r --arg wid "$wid" '.panes[] | select(.workspace_id == $wid) | .pane_id' <<< "$snapshot")
done <<< "$workspaces"
