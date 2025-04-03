#!/bin/bash
echo " "
echo "VASA FACIT. MUNDI MUTAT"
echo " "
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <container-name> [--build] [--cluster]"
    exit 1
fi

APP_NAME="$1"
BUILD_FLAG="${2:-}"
CLUSTER="${3:-}"

BUILD_DIR="build-$APP_NAME"
DEF_FILE="$BUILD_DIR/$APP_NAME.def"  # The .def file will be created directly under build-$APP_NAME

# Create build context (without the $APP_NAME subdirectory)
mkdir -p "$BUILD_DIR"

# Create the .def file if it doesn't exist
if [[ ! -f "$DEF_FILE" ]]; then
    echo "Creating $DEF_FILE..."
    cat > "$DEF_FILE" <<EOF
# Apptainer definition file for $APP_NAME

Bootstrap: docker
From: rockylinux:9

%post
# Enable debugging to show all commands being executed
    set -x
 
     # Clean any cached repository data
    echo "Cleaning dnf cache..."
    dnf clean all
    
    # Refresh the package metadata to ensure the latest updates are available
    echo "Refreshing package metadata..."
    dnf -y --refresh update --exclude=filesystem || (echo "dnf update failed"; exit 1)
    
    # Install EPEL repository and required packages (e.g., cowsay)
    echo "Installing epel-release and cowsay..."
    dnf -y install epel-release || (echo "Failed to install epel-release"; exit 1)
    dnf -y install cowsay || (echo "Failed to install cowsay"; exit 1)
    
    # Create app directory and install software
    echo "Creating app directory..."
    mkdir -p /opt/$APP_NAME
    cd /opt/$APP_NAME

    # Additional installation commands if needed
    # dnf -y install <other-dependencies>
    
# Disable debugging
    set +x

%environment
    export PATH=/opt/$APP_NAME/bin:$PATH
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}/opt/$APP_NAME/lib  # Set default if LD_LIBRARY_PATH is unbound
    export OMP_NUM_THREADS=8

%runscript
    # Script to run when the container is started
    # Check if arguments are passed to the container, and use them in the cowsay command
    if [ $# -gt 0 ]; then
        echo "$@" | cowsay  # Pass the arguments as the message for cowsay
    else
        echo "No message provided. Using default message."
        echo "Hello, this is a cowsay container!" | cowsay
    fi

# %files: If you are not using files to be copied into the container, you can comment this section out.
# %files
#     # Copy files into the container (example)
#     ./config/settings.conf /etc/$APP_NAME/settings.conf
#     ./data/input_data.dat /data/input_data.dat

%labels
    Author: YourName
    Version: 1.0
    Description: Container for $APP_NAME scientific application

# %test: This section is used for testing the container during build. It can be commented out if not in use.
%test
    # Simple test: run cowsay to verify it's working
    echo "Testing cowsay..." | cowsay
    # Or, if you want to test a custom message:
    echo "This is a test message" | cowsay

EOF
    echo "Created base Apptainer definition file at $DEF_FILE"
else
    echo "$DEF_FILE already exists. Skipping creation."
fi

# Debug: Check if the .def file was written correctly
if [[ -s "$DEF_FILE" ]]; then
    echo "$DEF_FILE has content."
else
    echo "Error: $DEF_FILE is empty or not created properly."
    exit 1
fi

# Build the container if the --build flag is set
if [[ "$BUILD_FLAG" == "--build" ]]; then
    echo "Building container image '$APP_NAME'..."
    apptainer build "$APP_NAME.sif" "$DEF_FILE"
    echo "Image '$APP_NAME.sif' built successfully."
else
    echo "Loading $DEF_FILE for editing."
    sleep 2
    "$EDITOR" "$DEF_FILE"  # Open the .def file for editing if --build is not specified
    exit
fi

