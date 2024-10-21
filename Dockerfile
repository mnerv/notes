FROM alpine:latest

# Set environment variables for UID and GID (can be passed at runtime)
ARG USER_ID=1000
ARG GROUP_ID=1000

# Update packages and add required utilities
RUN apk update && apk upgrade; \
    apk add doas; \
    addgroup -g ${GROUP_ID} porter; \
    adduser -D -u ${USER_ID} -G porter -g 'Porter' porter; \
    echo "porter:" | chpasswd; \
    addgroup porter wheel; \
    echo "permit persist :wheel" > "/etc/doas.d/doas.conf"

# Run system config script
COPY .docker/config.sh /root/config.sh
RUN sh /root/config.sh

# Neovim config
RUN mkdir -p /root/.config/nvim
COPY .docker/mini.lua /root/.config/nvim/init.lua

# Install LaTeX full distribution, use texmf-dist for smaller size
RUN apk add texmf-dist-full texlive biber

# Copy and change owner of setup scripts
COPY .docker /home/porter/.docker
COPY compile.sh /home/porter
RUN chown -R porter /home/porter/.docker &&\
    chown porter /home/porter/compile.sh

RUN mkdir -p /app
RUN chown -R porter /app

USER porter
WORKDIR /home/porter

# Run setup.sh as porter
RUN sh .docker/setup.sh

# Set final working directory
WORKDIR /app

CMD ["zsh"]

