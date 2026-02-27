#!/bin/bash

echo "📦 Installing Social Media Downloader..."

# Update packages
pkg update -y
pkg upgrade -y

# Install required packages
echo "Installing dependencies..."
pkg install -y python ffmpeg wget

# Install yt-dlp
echo "Installing yt-dlp..."
pip install yt-dlp

# Make downloader executable
chmod +x downloader.sh

# Create desktop shortcut (optional)
echo "#!/bin/bash
cd $(pwd)
./downloader.sh" > $PREFIX/bin/social-dl
chmod +x $PREFIX/bin/social-dl

echo "✅ Installation complete!"
echo "Run: ./downloader.sh or 'social-dl' from anywhere"
