#!/bin/bash

# lwt-style-is-everything dbt Workshop Setup
# Creates isolated environment directly in the project

set -e

# Clear any existing Python warning settings
unset PYTHONWARNINGS

PROJECT_NAME="lwt-style-is-everything"
DBT_VERSION="1.10.10"

echo "🚀 Setting up $PROJECT_NAME workshop environment..."

# Detect operating system for paths
OS=$(uname -s)
case $OS in
    Darwin*)  OS_NAME="macOS"; VENV_ACTIVATE="venv-lwt-style-is-everything/bin/activate";;
    Linux*)   OS_NAME="Linux"; VENV_ACTIVATE="venv-lwt-style-is-everything/bin/activate";;
    CYGWIN*|MINGW*|MSYS*) OS_NAME="Windows"; VENV_ACTIVATE="venv-lwt-style-is-everything/Scripts/activate";;
    *) echo "❌ Unsupported OS: $OS"; exit 1;;
esac

echo "✅ Detected: $OS_NAME"

# Check Python version
if command -v python3.9 &> /dev/null; then
    PYTHON_CMD="python3.9"
elif command -v python3.11 &> /dev/null; then
    PYTHON_CMD="python3.11"
elif command -v python3.10 &> /dev/null; then
    PYTHON_CMD="python3.10"
elif command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
    PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    echo "⚠️  Using Python $PYTHON_VERSION (recommend 3.9+)"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
    PYTHON_VERSION=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    echo "⚠️  Using Python $PYTHON_VERSION (recommend 3.9+)"
else
    echo "❌ Python not found. Please install Python 3.9+ first"
    exit 1
fi

echo "✅ Using Python: $PYTHON_CMD"

# Clean up any existing workshop environment
if [ -d "venv-lwt-style-is-everything" ]; then
    echo "🧹 Removing existing virtual environment..."
    # Deactivate any active venv first
    deactivate 2>/dev/null || true
    # Force remove with better permissions handling
    chmod -R +w venv-lwt-style-is-everything 2>/dev/null || true
    rm -rf venv-lwt-style-is-everything || {
        echo "⚠️  Force removing stubborn venv files..."
        sudo rm -rf venv-lwt-style-is-everything 2>/dev/null || true
    }
fi

# Create isolated Python environment
echo "📦 Creating Python virtual environment..."
$PYTHON_CMD -m venv venv-lwt-style-is-everything
source $VENV_ACTIVATE

# Install specific dbt version
echo "⬇️ Installing dbt $DBT_VERSION..."
pip install --upgrade pip --quiet
pip install "urllib3<2.0" --quiet  # Pin urllib3 to avoid SSL warnings
pip install "dbt-core==$DBT_VERSION" dbt-duckdb --quiet

# Install DuckDB CLI for data exploration
echo "🦆 Installing DuckDB CLI into virtual environment..."
pip install duckdb --quiet

# Download DuckDB CLI binary into venv
if [[ "$OS_NAME" == "macOS" ]]; then
    curl -L https://github.com/duckdb/duckdb/releases/download/v1.3.2/duckdb_cli-osx-universal.zip -o duckdb_cli.zip
    unzip -q duckdb_cli.zip
    mv duckdb venv-lwt-style-is-everything/bin/
    rm duckdb_cli.zip
elif [[ "$OS_NAME" == "Linux" ]]; then
    curl -L https://github.com/duckdb/duckdb/releases/download/v1.3.2/duckdb_cli-linux-amd64.zip -o duckdb_cli.zip
    unzip -q duckdb_cli.zip
    mv duckdb venv-lwt-style-is-everything/bin/
    rm duckdb_cli.zip
fi

# Create activation script
cat > activate.sh << EOF
#!/bin/bash
source $VENV_ACTIVATE
export DBT_PROFILES_DIR=\$(pwd)
echo "✅ Workshop environment activated!"
echo "📍 Location: \$(pwd)"
echo "🔧 Using local profiles.yml"
echo "💻 Platform: $OS_NAME"
echo "🦆 DuckDB CLI available: \$(which duckdb)"
echo "📦 Next step: dbt deps"
EOF
chmod +x activate.sh

echo "✅ Setup complete!"
echo "🚀 To activate: source activate.sh"
echo "📦 Then run: dbt deps"
echo "🌱 Then run: dbt seed"