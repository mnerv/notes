#!/usr/bin/env sh

# Configs
registry_name="registry"
registry_path=""
build_dir="build"
dist_dir="dist"
cache_uri=""
root_dir=$(pwd)

# State flags
is_dry_run=false
is_clean=false
is_parallel=false
is_production=false
is_skip_load_cache=false

help() {
  cat << EOF
usage: $0 [options]

options:
    -h, --help          Show this menu.
    --dry-run           Dry run the commands.
    --clean             Clean the output directories build and pdfs
                        before compiling.
    --parallel          Use parallel to run the compile scripts.
    --production        Create pdf in distribution directory.
    --build-dir         Specify build directory,
                        example: --build-dir=\"build\". Default: build.
    --dist-dir          Specify dist directory,
                        example: --dist-dir=\"dist\". Default: dist.
    --cache-uri         Set cache uri to download.
    --skip-load-cache   Skip loading cache.
EOF
}

generate_file_index() {
  # Add files
  printf "" > "$registry_path"
  {
    find ./cs | grep .tex
    find ./dsp | grep .tex
    find ./ee | grep .tex
    find ./maths | grep .tex
    find ./misc | grep .tex
  } >> "$registry_path"

  # Filter out dependencies from registry database
  registry_data=$(sort < "$registry_path")
  input_deps=""

  for path in $registry_data
  do
    input_dep=$(grep -E '\\input\{.+\}' "$path" | sed -e 's/\\input{\(.*\)}/\1/g')
    if [ -n "$input_dep" ]; then
      if [ -n "$input_deps" ]; then
        input_deps="$input_deps\n$input_dep"
      else
        input_deps="$input_dep"
      fi
    fi
  done

  input_deps=$(printf "%s\n" "$input_deps" | sort -u)
  for path in $input_deps
  do
    # FIXME: Can't handle relative path ./
    esc_path=$(printf "%s\n" "$path" | sed -r 's/\//\\\//')
    registry_data=$(printf "%s\n" "$registry_data" | sed -r "s/^.*$esc_path//")
  done

  printf "%s\n" "$registry_data" | sort -u | sed -r '/^\s*$/d' > "$registry_path"
}

parse_args() {
  while [ $# -gt 0 ]; do
    key="$1"
    case $key in
      --help | -h)
        help
        exit 0
        ;;
      --dry-run)
        is_dry_run=true
        ;;
      --clean)
        is_clean=true
        ;;
      --parallel)
        is_parallel=true
        ;;
      --production)
        is_production=true
        ;;
      --build-dir=*)
        build_dir="${key#*=}"
        ;;
      --dist-dir=*)
        dist_dir="${key#*=}"
        ;;
      --cache-uri=*)
        cache_uri="${key#*=}"
        ;;
      --skip-load-cache)
        is_skip_load_cache=true
        ;;
      *)
        printf "Unsupported argument: %s\n" "$key"
        exit 1
      ;;
    esac
    shift
  done
}

prebuild() {
  # clean
  if [ $is_clean = true ] && [ -e "$build_dir" ]; then
    rm -rf "$build_dir"
  fi
  if [ $is_clean = true ] && [ $is_production = true ] && [ -e "$dist_dir/pdf" ]; then
    rm -rf "$dist_dir/pdf"
  fi

  # create path
  if ! [ -e "$build_dir" ]; then
    mkdir -p "$build_dir"
  fi

  # construct path strings
  registry_path="$build_dir/$registry_name.txt"

  # check for cache
  if [ $is_skip_load_cache = true ]; then
    return 0
  fi

  if [ -n "$cache_uri" ]; then
    cd "$build_dir" || exit 1
    wget "$cache_uri"
    cd "$root_dir" || exit 1
  fi

  # BUG: Removed LaTeX file won't be updated.
  # BUG: On Windows docker, the expanded archive can't be renamed, permission
  #      denied.
  if [ -e "$build_dir/archive.tar.gz" ]; then
    cd "$build_dir" || exit 1
    tar -xzf "./archive.tar.gz"
    cd "$root_dir" || exit 1
  fi
}

build() {
  if ! [ -e "$registry_path" ]; then
    printf "No registry file\n"
    exit 1
  fi

  files=$(cat "$registry_path")
  args="--build-dir=$build_dir"

  if [ $is_dry_run = true ]; then
    for file in $files; do
      echo "./compile.sh $args $file"
    done
    return 0
  fi

  if [ $is_parallel = true ]; then
     parallel --will-cite sh ./compile.sh "$args" ::: "$files"
  else
    for file in $files; do
      sh ./compile.sh "$args" "$file"
    done
  fi
}

postbuild() {
  cd "$build_dir" || exit 1
  tar -czf archive.tar.gz pdf
  cd "$root_dir" || exit 1

  if [ $is_production = false ]; then
    return
  fi

  if ! [ -e "$dist_dir" ]; then
    mkdir -p "$dist_dir"
  fi

  if [ -e "$dist_dir/pdf" ]; then
    rm -rf "$dist_dir/pdf"
  fi

  if [ -e "web/dist" ]; then
    cp -rf web/dist/* dist
  fi

  cp -rf "$build_dir/pdf" "$dist_dir"
  cp "$registry_path" "$dist_dir/pdf"
  cp "$build_dir/archive.tar.gz" "$dist_dir/pdf"
}

parse_args "$@"
prebuild
generate_file_index
build
postbuild

