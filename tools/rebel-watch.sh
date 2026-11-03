#!/usr/bin/env bash
# Rebel Watch: for each rebel in rebels.json, look for a new upstream release tag.
# New tag -> merge it into the rebel branch on a fresh branch in the fork.
#   clean merge -> push the branch and open a pull request in the fork
#   clashes     -> open an issue in the fork listing the clashing files
# The last upstream tag seen per rebel is kept in rebel-state.json (committed back by the workflow).
# Needs: GH_TOKEN with contents, pull requests and issues (read/write) on the fork repos.
set -euo pipefail
STATE=rebel-state.json
[ -f "$STATE" ] || echo '{}' > "$STATE"
work=$(mktemp -d)
changed=0

latest_tag() { # newest semver-looking tag in a repo, pre-releases included
	git ls-remote --tags --refs "https://github.com/$1.git" | awk '{print $2}' | sed 's#refs/tags/##' \
		| grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+' \
		| sed 's/-/~/' | sort -V | sed 's/~/-/' | tail -1   # ~ makes 4.0.0-rc1 sort before 4.0.0
}

count=$(jq '.rebels | length' rebels.json)
for i in $(seq 0 $((count - 1))); do
	name=$(jq -r ".rebels[$i].name" rebels.json)
	fork=$(jq -r ".rebels[$i].fork" rebels.json)
	upstream=$(jq -r ".rebels[$i].upstream" rebels.json)
	branch=$(jq -r ".rebels[$i].rebelBranch" rebels.json)
	echo "::group::$name"
	tag=$(latest_tag "$upstream" || true)
	seen=$(jq -r --arg f "$fork" '.[$f] // ""' "$STATE")
	echo "upstream $upstream newest tag: ${tag:-none}, last seen: ${seen:-none}"
	if [ -z "$tag" ] || [ "$tag" = "$seen" ]; then echo "Nothing new."; echo "::endgroup::"; continue; fi

	new="rebel-watch/$tag"
	if git ls-remote --exit-code --heads "https://github.com/$fork.git" "$new" >/dev/null 2>&1; then
		echo "Branch $new already exists in $fork; leaving it."
	else
		dir="$work/${fork#*/}"
		git clone -q --branch "$branch" "https://x-access-token:${GH_TOKEN}@github.com/$fork.git" "$dir"
		git -C "$dir" fetch -q "https://github.com/$upstream.git" "refs/tags/$tag:refs/tags/$tag"
		git -C "$dir" config user.name "Rebel Watch"
		git -C "$dir" config user.email "rebel-watch@users.noreply.github.com"
		git -C "$dir" checkout -q -b "$new"
		if git -C "$dir" merge-base --is-ancestor "$tag" "$branch"; then
			echo "The rebel already includes $tag."
		elif git -C "$dir" merge --no-edit -q -m "Rebel Watch: bring in upstream $tag" "$tag"; then
			git -C "$dir" push -q origin "$new"
			gh pr create -R "$fork" --base "$branch" --head "$new" \
				--title "Rebel Watch: upstream $tag is out, rebel rebuilt" \
				--body "Psst. 🍹 $upstream released **$tag**. Rebel Watch merged it into \`$branch\` on this branch with no clashes, and the build runs on it now.

Next: check the build, bump the rebel version, merge, publish. Then offer the changes back to the original developer." >/dev/null
			echo "Pull request opened."
		else
			files=$(git -C "$dir" diff --name-only --diff-filter=U | sed 's/^/- /')
			git -C "$dir" merge --abort
			gh issue create -R "$fork" \
				--title "Rebel Watch: upstream $tag clashes with the rebel" \
				--body "Uh oh. $upstream released **$tag**, and it doesn't merge cleanly into \`$branch\`. These files clash:

$files

Needs a hand-port onto $tag." >/dev/null
			echo "Clashes: issue opened."
		fi
	fi
	jq --arg f "$fork" --arg t "$tag" '.[$f] = $t' "$STATE" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"
	changed=1
	echo "::endgroup::"
done
echo "changed=$changed" >> "${GITHUB_OUTPUT:-/dev/null}"
