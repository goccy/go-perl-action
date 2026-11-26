# go-perl-action

GitHub Actions for [go-perl](https://github.com/goccy/go-perl).

## setup

Installs `gperl` from a go-perl release and puts it on `PATH`. The release
archive is checked against the release's `checksums.txt`, and
`checksums.txt` against the build provenance the go-perl release workflow
attested (`gh attestation verify`), before it is installed.

```yaml
steps:
  - uses: actions/checkout@v7
  - uses: goccy/go-perl-action/setup@v1
  - run: gperl test
```

### Inputs

| Name | Default | Description |
|---|---|---|
| `gperl-version` | `latest` | The release to install, as a tag (`v0.3.4`, or `0.3.4`) or `latest`. |
| `cache` | `true` | Cache the module directory (`GPERLMODCACHE` as an absolute path, default `~/gperl/pkg/mod`), keyed by the runner's platform, the gperl release and the hash of every `cpanfile` and `cpanfile.snapshot`. |
| `install-toolchain` | `false` | Run `gperl install toolchain`, which installs the Go and Zig toolchains gperl builds binaries and native modules with into `GPERLTOOLCHAIN` (as an absolute path, default `~/gperl/toolchain`), and cache them. |
| `token` | `${{ github.token }}` | The token that downloads the release and verifies its build provenance. |

### Outputs

| Name | Description |
|---|---|
| `gperl-version` | The tag of the installed release. |
| `cache-hit` | Whether the module directory was restored from a cache of the same key. |

### Building a binary

```yaml
steps:
  - uses: actions/checkout@v7
  - uses: goccy/go-perl-action/setup@v1
    with:
      install-toolchain: true
  - run: gperl build -o app app.pl
```

### Runners

Linux and macOS runners, on x64 and ARM64.
Dependencies that build with `Makefile.PL` also need `make` on the runner.
