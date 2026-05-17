# Use Kali Linux as the base image for a rich security toolset
FROM kalilinux/kali-rolling

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install system dependencies
RUN apt-get update && apt-get install -y \
    nmap \
    bettercap \
    macchanger \
    arp-scan \
    libimage-exiftool-perl \
    whois \
    dnsutils \
    curl \
    jq \
    yara \
    python3 \
    python3-pip \
    golang-go \
    git \
    sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip3 install --no-cache-dir \
    cloudscraper \
    beautifulsoup4 \
    holehe \
    sherlock-project \
    --break-system-packages

# Set up working directory
WORKDIR /app

# Copy the tool files
COPY lol_osint.sh lol-dist.sh MANUAL.md ./

# Make scripts executable
RUN chmod +x lol_osint.sh lol-dist.sh

# Create a symlink for easy access
RUN ln -s /app/lol_osint.sh /usr/local/bin/lol

# Create volume for reports and wordlists
VOLUME ["/app/reports", "/app/wordlists", "/app/yara-rules"]

# Set default command
ENTRYPOINT ["/app/lol_osint.sh"]
CMD ["help"]
