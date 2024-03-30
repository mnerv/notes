#!/usr/bin/env sh

# Configs
script_name=$0
build_dir=build
input_file=""

# Arg flags
is_skip_bitex=false
is_dry_run=false
is_no_cache=false
is_no_spin=false

# State flags
is_cached=false
has_input=false
is_clean=false

# Path variables
filepath=""
filename=""
name=""
ext=""
rel_location=""
latex_build_dir=""
pdf_dir=""
pdf_latex_dir=""
abs_latex_build_dir=""
abs_pdf_dir=""
file_deps=""

help() {
  cat << EOF
usage: $arg0 [options] <file.tex>

options:
    -h, --help               Show this menu.
    --dry-run                Dry run the commands.
    --build-dir=<directory>  Specify build directory.
    --skip-bibtex            Skip generating bibtex.
    --no-cache               This action skips the cache check.
    --clean                  Clean before build. This will remove
                             output pdf and the build intermediate steps.
EOF
}

parse_args() {
  if [[ $# = 0 ]]; then
    printf "error: no input file\n"
    help
    exit 1
  fi

  while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
      --help | -h)
        help
        exit 0
        ;;
      --dry-run)
        is_dry_run=true
        ;;
      --build-dir=*)
        build_dir="${key#*=}"
        ;;
      --skip-bibtex)
        is_skip_bitex=true
        ;;
      --no-cache)
        is_no_cache=true
        ;;
      --no-spin)
        is_no_spin=true
        ;;
      --clean)
        is_clean=true
        ;;
      *)
        if [[ $has_input = true ]]; then
          printf "Only one input file is allowed!\n"
          exit 1
        fi
        # Assume any other argument is a filename
        input_file=$key
        has_input=true
      ;;
    esac
    shift
  done
}

recursive_index() {
  # Check if file exist before we analyze it
  if ! [[ -e "$1" ]]; then
    return 0
  fi

  _grep_regex='((input)|(includegraphics\[.*\])|(addbibresource))\{.+\}'
  _replace_regex='s/\\((input)|(includegraphics\[.*\])|(addbibresource))\{(.+)\}/\5/'
  if ! [ -d "$1" ]; then
    _deps=$(cat "$1" | grep -E "$_grep_regex" | sed -r "$_replace_regex")
  else
    _deps=""
  fi

  if ! [[ -z "$_deps" ]]; then
    if ! [[ -z "$file_deps" ]]; then
      file_deps="$file_deps\n$_deps"
    else
      file_deps="$_deps"
    fi

    for file in "$_deps"; do
      filepath="$(dirname $1)/$file"
      recursive_index $filepath
    done
  fi
}

prebuild() {
  if ! [[ -e $input_file ]]; then
    printf "File $input_file does not exist!\n"
    exit 1
  fi

  filepath="$(realpath $input_file)"
  filename="$(basename "$input_file")"
  name="${filename%.*}"
  ext="${filename##*.}"
  rel_location="$(dirname $input_file)"
  latex_build_dir="$build_dir/tex/$rel_location"
  pdf_dir="$build_dir/pdf/$rel_location"

  if ! [[ -e $build_dir ]]; then
    mkdir -p $build_dir
  fi

  if ! [[ -e $latex_build_dir ]]; then
    mkdir -p $latex_build_dir
  elif [[ -e $latex_build_dir ]] && [[ $is_clean = true ]]; then
    rm -rf $latex_build_dir
    mkdir -p $latex_build_dir
  fi

  if ! [[ -e $pdf_dir ]]; then
    mkdir -p $pdf_dir
  elif [[ -e $pdf_dir ]] && [[ $is_clean = true ]]; then
    rm -rf $pdf_dir
    mkdir -p $pdf_dir
  fi

  # Convert output path to absolute
  abs_latex_build_dir=$(realpath "$build_dir/tex/$rel_location")
  abs_pdf_dir=$(realpath "$build_dir/pdf/$rel_location")
  pdf_latex_dir="$abs_pdf_dir/$name"

  if ! [[ -e "$pdf_latex_dir" ]]; then
    mkdir -p "$pdf_latex_dir"
  elif [[ -e $pdf_latex_dir ]] && [[ $is_clean = true ]]; then
    rm -rf $pdf_latex_dir
    mkdir -p "$pdf_latex_dir"
  fi

  # Generate local registry for dependencies
  recursive_index $filepath
  file_deps=$(echo "$file_deps" | sed -r "s/[ %]*//" | sort -u)
}

parse_info() {
  if [ $1 -ne 0 ]; then
    printf "\r$2: failed, check $latex_build_dir/$2.log\n"
    cat $abs_latex_build_dir/$2.log | awk 'BEGIN{IGNORECASE = 1}/warning|!|Runaway argument\?/,/^$/;'
    exit 1
  fi
}

exec_build_cmd() {
  exec_name=$1
  cmd=$2
  log_file="$abs_latex_build_dir/$exec_name.log"

  $cmd > $log_file
  exit_code=$?
  parse_info $exit_code "$exec_name"
}

check_cache() {
  is_cached=false

  if ! [[ -e "$abs_pdf_dir/$name.pdf" ]] || ! [[ -e "$pdf_latex_dir/$filename" ]]; then
    return 0
  fi

  input_check_sum=$(sha256sum $input_file | cut -d ' ' -f 1)
  output_check_sum=$(sha256sum "$pdf_latex_dir/$filename" | cut -d ' ' -f 1)
  if ! [[ $input_check_sum = $output_check_sum ]]; then
    return 0
  fi

  for file in $file_deps; do
    if [[ -e $rel_location/$file ]] && [[ -e $pdf_latex_dir/$file ]]; then
      asum=$(sha256sum $rel_location/$file  | cut -d ' ' -f 1)
      bsum=$(sha256sum $pdf_latex_dir/$file | cut -d ' ' -f 1)

      if ! [[ $asum = $bsum ]]; then
        return 0
      fi
    else
      # Special case for inline bibtex addbibresource{}
      if ! [[ "${file##*.}" = "bib" ]]; then
        return 0
      fi
    fi
  done

  is_cached=true
}

build() {
  if [[ $is_cached = true ]] && [[ $is_no_cache = false ]]; then
    printf "$input_file is cached.\n"
    return 0
  fi

  printf "compiling $input_file..."

  current_dir=$(pwd)
  cd $rel_location
  exec_build_cmd "stage1" "pdflatex -halt-on-error --interaction=nonstopmode -output-directory=$abs_latex_build_dir $filename"
  exec_build_cmd "stage2" "biber $abs_latex_build_dir/$name"
  exec_build_cmd "stage3" "pdflatex -halt-on-error --interaction=nonstopmode -output-directory=$abs_latex_build_dir $filename"
  cd $current_dir

  printf "done!\n"
}

postbuild() {
  if [[ $is_cached = true ]] && [[ $is_no_cache = false ]]; then
    return 0
  fi

  if ! [[ -e $abs_pdf_dir ]]; then
    printf "PDF output path does not exist!\n"
    return 1
  fi

  if [[ -e "$abs_latex_build_dir/$name.pdf" ]]; then
    cp "$abs_latex_build_dir/$name.pdf" $abs_pdf_dir
  fi

  # Copy LaTeX and dependency files
  cp $input_file $pdf_latex_dir
  for file in $file_deps; do
    file_dir=$(dirname $file)
    if ! [[ $file_dir = '.' ]]; then
      mkdir -p "$pdf_latex_dir/$file_dir"
    else
      file_dir=""
    fi
    if [[ -e "$rel_location/$file" ]]; then
      cp "$rel_location/$file" "$pdf_latex_dir/$file_dir"
    fi
    file_dir=""
  done
}

parse_args $@
prebuild
check_cache
build
postbuild
