#!/bin/sh
set -eu

# Resolve everything relative to this script, not the caller's directory.
repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
target=${1:-school}
if [ "$#" -gt 0 ]; then shift; fi
main_file=
case "$target" in
  school) project_directory=$repository_root/00-使用例/01-学校形式-upLaTeX; main_file=実験報告書.tex ;;
  school-platex) project_directory=$repository_root/00-使用例/02-学校形式-pLaTeX; main_file=実験報告書.tex ;;
  report) project_directory=$repository_root/00-使用例/03-数式とグラフ; main_file=main.tex ;;
  english) project_directory=$repository_root/00-使用例/04-欧文; main_file=main.tex ;;
  bibliography) project_directory=$repository_root/00-使用例/05-biblatexとBiber; main_file=main.tex ;;
  /*) project_directory=$target ;;
  *) project_directory=$repository_root/$target ;;
esac

clean=no
explicit_file=no
for argument in "$@"; do
  case "$argument" in
    --clean) clean=yes ;;
    *.tex)
      if [ "$explicit_file" = yes ]; then
        printf '%s\n' 'Specify only one root TeX file.' >&2; exit 2
      fi
      main_file=$argument; explicit_file=yes ;;
    *) printf '%s\n' 'Arguments must be a root .tex filename or --clean.' >&2; exit 2 ;;
  esac
done
if [ ! -d "$project_directory" ]; then
  printf 'Project folder not found: %s\n' "$project_directory" >&2; exit 2
fi
if [ -z "$main_file" ]; then
  if [ -f "$project_directory/main.tex" ]; then
    main_file=main.tex
  else
    source_count=0
    for source_path in "$project_directory"/*.tex; do
      [ -f "$source_path" ] || continue
      source_count=$((source_count + 1))
      main_file=${source_path##*/}
    done
    if [ "$source_count" -ne 1 ]; then
      printf '%s\n' 'Specify the root .tex filename for this project.' >&2; exit 2
    fi
  fi
fi
if [ ! -f "$project_directory/.latexmkrc" ] || [ ! -f "$project_directory/$main_file" ]; then
  printf '%s\n' 'The root TeX file and .latexmkrc must exist in the project folder.' >&2; exit 2
fi
if [ "$clean" = yes ]; then set -- -c; else set --; fi

export TEXLIVE_WINDOWS_TRY_EXTERNAL_PERL=0
exec latexmk -norc -r "$project_directory/.latexmkrc" -cd "$@" "$project_directory/$main_file"
