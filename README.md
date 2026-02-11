# ModelPark CLI

Command-line tool for publishing and managing ML models on [ModelPark](https://modelpark.app).

## Installation

### Quick Install (Linux / macOS)

```bash
curl -fsSL https://raw.githubusercontent.com/model-park cli/master/install.sh | sh
```

### Debian / Ubuntu

Download the `.deb` package from the [latest release](https://github.com/model-park cli/releases/latest):

```bash
# amd64
curl -fsSLO https://github.com/model-park cli/releases/latest/download/modelpark_amd64.deb
sudo dpkg -i modelpark_amd64.deb

# arm64
curl -fsSLO https://github.com/model-park cli/releases/latest/download/modelpark_arm64.deb
sudo dpkg -i modelpark_arm64.deb
```

### RHEL / Fedora

```bash
curl -fsSLO https://github.com/model-park cli/releases/latest/download/modelpark_amd64.rpm
sudo rpm -i modelpark_amd64.rpm
```

### Manual Download

Download the archive for your platform from the [releases page](https://github.com/model-park cli/releases/latest), extract it, and place the `modelpark` binary in your `PATH`.

| Platform | Archive |
|----------|---------|
| Linux (x86_64) | `modelpark-linux-amd64.tar.gz` |
| Linux (ARM64) | `modelpark-linux-arm64.tar.gz` |
| macOS (Intel) | `modelpark-darwin-amd64.tar.gz` |
| macOS (Apple Silicon) | `modelpark-darwin-arm64.tar.gz` |
| Windows (x86_64) | `modelpark-windows-amd64.zip` |

### Verify Checksums

Each release includes a `checksums.txt` file with SHA256 hashes:

```bash
sha256sum -c checksums.txt
```

## Quick Start

```bash
# Authenticate with your ModelPark account
modelpark login

# Start an app and publish it (port auto-detected for known frameworks)
modelpark run --name myapp -- streamlit run app.py

# Or tunnel an already-running local port
modelpark serve --name myapp --port 8000

# Check status
modelpark status

# View version
modelpark version
```

### Supported Frameworks (auto-detect)

| Framework | Default Port |
|-----------|-------------|
| Streamlit | 8501 |
| Gradio | 7860 |
| FastAPI / Uvicorn | 8000 |
| Flask / MLflow | 5000 |
| Chainlit | 8000 |
| Panel | 5006 |
| Voila | 8866 |
| Jupyter | 8888 |
| Ollama | 11434 |

Use `--port` to override or for unlisted frameworks.

## Usage

```
modelpark [command] [flags]

Commands:
  login       Authenticate with ModelPark
  logout      Remove stored credentials
  status      Show connection status and running apps
  run         Start an app process and tunnel it to ModelPark
  serve       Tunnel an already-running local port
  stop        Stop a running app tunnel
  version     Print version information

Flags:
  -v, --verbose   Enable verbose output
  -V, --version   Print version and exit
  -h, --help      Show help
```

## Documentation

Full documentation is available at [modelpark.app/docs](https://modelpark.app/docs).

## License

MIT License - see [LICENSE](LICENSE) for details.
