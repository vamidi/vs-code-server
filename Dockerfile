FROM lscr.io/linuxserver/code-server:latest
LABEL authors="AUTHOR_NAME"

# Environment variables for Debian frontend (noninteractive install)
ENV DEBIAN_FRONTEND=noninteractive

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# Enable pnpm
RUN corepack enable

# Install tools: curl, gnupg, unzip, and other dependencies
RUN apt-get update && \
    apt-get install -y \
        curl \
        gnupg \
        unzip \
        software-properties-common \
        ca-certificates \
        lsb-release \
        apt-transport-https \
        build-essential \
        # pupeteer and pa11y dependencies
        gnupg2 \
        xvfb \
        libnspr4 \
        libnss3 \
        libasound2t64 \
        libatk-bridge2.0-0 \
        libxcomposite1 \
        libxrandr2 \
        libxss1 \
        libgtk-3-0 \
        libxdamage1 \
        libxext6 \
        libgbm1 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libcups2 \
        libdrm2 && \
    rm -rf /var/lib/apt/lists/*

### Install Terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && \
    apt-get install -y terraform && \
    terraform -install-autocomplete

### Install Node.js (LTS) and npm
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm

### Install ESLint globally
RUN npm install -g eslint

### Install Yarn globally
RUN npm install -g yarn

### Create alias's because I am lazy
RUN echo "alias tf='terraform'" >> /root/.bashrc && \
    echo "alias yr='yarn run'" >> /root/.bashrc && \
    echo "alias nr='npm run'" >> /root/.bashrc && \
    echo "alias gts='git status'" >> /root/.bashrc

# Clean up to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
