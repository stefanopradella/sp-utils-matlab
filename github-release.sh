#!/usr/bin/env bash
# Requires Bash, git, and GitHub CLI authenticated with `gh auth login`.
# Push the release tag to GitHub first.
set -eo pipefail

usage() {
    printf 'Usage: %s --repo OWNER/REPO --tag TAG --notes NOTES.md --title TITLE --files FILES.txt [--dry-run]\n' "${0##*/}"
    printf 'Asset paths are relative to the project root; blank lines and # comments are ignored.\n'
    printf '\nExample (preview):\n  %q \\\n' "$0"
    printf '%s\n' \
        '    --repo OWNER/REPO \' \
        '    --tag v1.2.3 \' \
        '    --notes release-notes.md \' \
        '    --title "v1.2.3" \' \
        '    --files release-files.txt \' \
        '    --dry-run'
    printf '\nReplace OWNER/REPO and v1.2.3. Remove --dry-run to publish.\n'
    printf 'Requires gh auth login and a release tag already pushed to GitHub.\n'
}

fail() {
    printf 'github-release: %s\n' "$*" >&2
    exit 1
}

dryRun=false
repo=
tag=
notesFile=
title=
filesFile=
if [[ $# == 0 ]]; then
    usage
    exit 0
fi
while [[ $# != 0 ]]; do
    case $1 in
        --help) usage; exit 0 ;;
        --dry-run) dryRun=true; shift ;;
        --repo|--tag|--notes|--title|--files)
            [[ $# -ge 2 && $2 != --* ]] || fail "Missing value for $1."
            case $1 in
                --repo) repo=$2 ;;
                --tag) tag=$2 ;;
                --notes) notesFile=$2 ;;
                --title) title=$2 ;;
                --files) filesFile=$2 ;;
            esac
            shift 2
            ;;
        *) fail "Unknown argument: $1. Use --help for usage." ;;
    esac
done

[[ -n $repo ]] || fail '--repo is required (OWNER/REPO).'
[[ -n $tag ]] || fail '--tag is required.'
[[ -n $notesFile ]] || fail '--notes is required.'
[[ -n $title ]] || fail 'The release title must not be empty.'
[[ -n $filesFile ]] || fail '--files is required.'
[[ $notesFile == *.md && -f $notesFile && -r $notesFile && -s $notesFile ]] ||
    fail "Release notes must be a readable, nonempty .md file: $notesFile"
[[ -f $filesFile && -r $filesFile ]] || fail "Cannot read file list: $filesFile"
[[ $notesFile == /* ]] || notesFile=$PWD/$notesFile
[[ $filesFile == /* ]] || filesFile=$PWD/$filesFile

command -v git >/dev/null || fail 'git is required.'
projectRoot=$(git -C "$(dirname -- "$filesFile")" rev-parse --show-toplevel) ||
    fail 'The file list must be inside a Git project.'
cd -- "$projectRoot"
git check-ref-format "refs/tags/$tag" >/dev/null || fail "Invalid tag: $tag"

assets=()
while IFS= read -r file || [[ -n $file ]]; do
    file=${file%$'\r'}
    [[ -n $file && $file != \#* ]] || continue
    [[ $file != /* ]] || fail "Use a project-relative asset path: $file"
    # gh interprets # as an asset label separator, even inside quoted paths.
    [[ $file != *'#'* ]] || fail "Asset paths cannot contain #: $file"
    [[ -f $file && -r $file ]] || fail "Missing or unreadable asset: $file"
    for asset in "${assets[@]}"; do
        [[ ${asset##*/} != "${file##*/}" ]] || fail "Duplicate asset filename: ${file##*/}"
    done
    assets+=("./$file")
done < "$filesFile"
[[ ${#assets[@]} != 0 ]] || fail 'The file list contains no assets.'

releaseCommand=(gh release create --repo "$repo" --title "$title" --notes-file "$notesFile"
    --verify-tag -- "$tag" "${assets[@]}")
if "$dryRun"; then
    printf 'cd %q\n' "$projectRoot"
    printf '%q ' "${releaseCommand[@]}"
    printf '\n'
    exit 0
fi

command -v gh >/dev/null || fail 'Install GitHub CLI (gh), then run: gh auth login'
"${releaseCommand[@]}"
