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

# Check Python
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
else
    echo "❌ Python not found. Please install Python 3.8+ first"
    exit 1
fi

# Clean up any existing workshop environment
if [ -d "venv-lwt-style-is-everything" ]; then
    echo "🧹 Removing existing virtual environment..."
    rm -rf venv-lwt-style-is-everything
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

# Create activation script
cat > activate.sh << EOF
#!/bin/bash
source $VENV_ACTIVATE
export DBT_PROFILES_DIR=\$(pwd)
echo "✅ Workshop environment activated!"
echo "📍 Location: \$(pwd)"
echo "🔧 Using local profiles.yml"
echo "💻 Platform: $OS_NAME"
echo "📦 Next step: dbt deps"
EOF
chmod +x activate.sh

echo "✅ Setup complete!"
echo "🚀 To activate: source activate.sh"
echo "📦 Then run: dbt deps"