#!/bin/sh
# SPDX-License-Identifier: MIT
#
# build.sh: build the Surface RT's kernel in the build container and collect its artifacts.
#
#   ./build.sh surface-rt [OUT]
#
# OUT (default out/surface-rt) gets the artifacts and manifest.json. The kernel tree is kept in a Docker
# volume, not on the host: a tree and its objects take about 3 GB.
#
# Environment:
#   BUILD_IMAGE  the build container image (default linux-surface-rt-build, built from docker/ when it
#                is not there)
#   VOLUME       the Docker volume mounted at /src (default linux-surface-rt-src)
#   WORK         the work directory in the volume (default /src/<device>)
#   OVERLAY      a host directory to mount as the overlay (README.md, "Overlays")
#   KTREE, CACHE and JOBS are passed on to the device's build.sh when set, and so are the variables
#   PASS_ENV names (for an overlay's own settings).
set -eu
R=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
DEV=${1:?usage: build.sh surface-rt [OUT]}
[ -f "$R/$DEV/build.sh" ] || { echo "no such device: $DEV" >&2; exit 1; }
OUT=${2:-$R/out/$DEV}
mkdir -p "$OUT"
OUT=$(cd "$OUT" && pwd)
IMAGE=${BUILD_IMAGE:-linux-surface-rt-build}
VOLUME=${VOLUME:-linux-surface-rt-src}
docker image inspect "$IMAGE" >/dev/null 2>&1 ||
	docker build --platform linux/amd64 -t "$IMAGE" "$R/docker"
commit() { git -C "$1" rev-parse HEAD 2>/dev/null || true; }
set -- -e SOURCE_COMMIT="$(commit "$R")" -e WORK="${WORK:-/src/$DEV}" -e OUT=/out
if [ -n "${OVERLAY:-}" ]; then
	OVERLAY=$(cd "$OVERLAY" && pwd)
	set -- "$@" -v "$OVERLAY:/overlay:ro" -e OVERLAY=/overlay -e OVERLAY_COMMIT="$(commit "$OVERLAY")"
fi
for v in KTREE CACHE JOBS ${PASS_ENV:-}; do
	eval "x=\${$v:-}"
	[ -n "$x" ] && set -- "$@" -e "$v=$x"
done
exec docker run --rm --platform linux/amd64 \
	-v "$VOLUME:/src" -v "$R:/repo:ro" -v "$OUT:/out" "$@" -w /repo "$IMAGE" bash "/repo/$DEV/build.sh"
