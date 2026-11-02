# Sources

Every source the build uses, and where it comes from.

The build uses only what is in this repository, plus the download below, checked against its sha256
before it is used. The patches carry their origin themselves: each names its author, and
[surface-rt/PROVENANCE.md](surface-rt/PROVENANCE.md) cites the tree, commit and file it comes from.
No file is copied from another tree as it is.

## Downloaded, checked by sha256

| What | From | sha256 |
| --- | --- | --- |
| Linux 7.2.13 | cdn.kernel.org, `linux-7.2.13.tar.xz` | `08e7b0c4f2dd1971f972da274b5e589a98989390ac56acd7a1a5af922363ea6c` |

The build container (`docker/Dockerfile`) starts from Debian's `debian:trixie-slim` image and
installs the compiler and tools from Debian's packages. Neither is pinned by digest; the kernel
artifacts' sums are what pins a build.
