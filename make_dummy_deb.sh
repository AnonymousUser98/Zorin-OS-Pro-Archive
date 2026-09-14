#!/usr/bin/env bash

set -euo pipefail

# Minimal script to build a dummy package that satisfies a dependency
# without installing files.
# Requires: equivs (equivs-build)

usage() {
	echo "Usage: $0 -n package_name -v version -o output_path [-w work_dir]" >&2
	echo "  -n  Package name to provide (required)" >&2
	echo "  -v  Version number (required)" >&2
	echo "  -o  Output path for .deb - can be a directory or full file path (required)" >&2
	echo "  -w  Working directory for build (optional, defaults to mktemp)" >&2
}

PKG_NAME=""
PKG_VERSION=""
OUT_PATH=""
WORK_DIR=""

while getopts ":n:v:o:w:h" opt; do
	case "$opt" in
		n) PKG_NAME="$OPTARG" ;;
		v) PKG_VERSION="$OPTARG" ;;
		o) OUT_PATH="$OPTARG" ;;
		w) WORK_DIR="$OPTARG" ;;
		h)
			usage
			exit 0
			;;
		:)
			echo "Option -$OPTARG requires an argument" >&2
			usage
			exit 2
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			usage
			exit 2
			;;
	esac
done

if [[ -z "$PKG_NAME" || -z "$PKG_VERSION" || -z "$OUT_PATH" ]]; then
	echo "Error: all options -n, -v, and -o are required." >&2
	usage
	exit 2
fi

if ! command -v equivs-build >/dev/null 2>&1; then
	echo "Installing 'equivs' (requires sudo)..."
	sudo apt-get update -y
	sudo apt-get install -y equivs
fi

# Determine output directory and filename
if [[ "$OUT_PATH" == */ ]]; then
	# OUT_PATH is a directory path (ends with /)
	OUT_DIR="$OUT_PATH"
	OUT_FILE="${PKG_NAME}_${PKG_VERSION}_all.deb"
else
	# OUT_PATH might be a full file path or directory without trailing /
	# Check if it has a file extension
	if [[ "$OUT_PATH" == *.deb ]]; then
		# It's a full file path
		OUT_DIR="$(dirname "$OUT_PATH")"
		OUT_FILE="$(basename "$OUT_PATH")"
	else
		# It's a directory without trailing slash
		OUT_DIR="$OUT_PATH"
		OUT_FILE="${PKG_NAME}_${PKG_VERSION}_all.deb"
	fi
fi

mkdir -p "$OUT_DIR"

# Use provided work directory or create temporary one
if [[ -z "$WORK_DIR" ]]; then
	WORKDIR="$(mktemp -d)"
	CLEANUP_WORKDIR=true
else
	WORKDIR="$WORK_DIR"
	CLEANUP_WORKDIR=false
	mkdir -p "$WORKDIR"
fi

# Build in the working directory
{
	CONTROL="$WORKDIR/control"
	ARCH="all"
	MAINTAINER="Dummy <dummy@dummy.invalid>"
	DESCRIPTION="Dummy package to satisfy dependency for $PKG_NAME."

	cat >"$CONTROL" <<EOF
Section: misc
Priority: optional
Standards-Version: 3.9.2

Package: $PKG_NAME
Version: $PKG_VERSION
Maintainer: $MAINTAINER
Architecture: $ARCH
Provides: $PKG_NAME
Description: $DESCRIPTION
 This package intentionally contains no files. It only exists
 to satisfy dependencies on $PKG_NAME.
EOF

	# Build the .deb
	if ! (cd "$WORKDIR" && equivs-build control); then
		[[ "$CLEANUP_WORKDIR" == true ]] && rm -rf "$WORKDIR"
		echo "Error: equivs-build failed, no package created." >&2
		exit 1
	fi

	# Move result to requested output directory
	mapfile -t DEB_FILES < <(find "$WORKDIR" -maxdepth 1 -type f -name "*.deb" | sort)
	if [[ ${#DEB_FILES[@]} -eq 0 ]]; then
		[[ "$CLEANUP_WORKDIR" == true ]] && rm -rf "$WORKDIR"
		echo "Error: No .deb file produced in $WORKDIR." >&2
		exit 1
	fi
	if [[ ${#DEB_FILES[@]} -gt 1 ]]; then
		echo "Warning: Multiple .deb files found; using ${DEB_FILES[0]}." >&2
	fi
	mv "${DEB_FILES[0]}" "$OUT_DIR/$OUT_FILE"

	# Clean up temporary directory only if we created it
	if [[ "$CLEANUP_WORKDIR" == true ]]; then
		rm -rf "$WORKDIR"
	fi
}

echo "Built dummy package: $OUT_DIR/$OUT_FILE"
echo "Install with: sudo apt install $OUT_DIR/$OUT_FILE"
