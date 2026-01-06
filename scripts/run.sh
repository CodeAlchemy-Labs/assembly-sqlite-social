#!/bin/bash

# Run the Assembly-SQLite application

# Check if built
if [ ! -f "bin/social_network" ]; then
    echo "Application not built. Running build first..."
    ./scripts/build.sh
fi

# Run the application
echo "Starting Social Network Database Manager..."
echo "=========================================="
cd bin && ./social_network