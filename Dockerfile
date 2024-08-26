#depreciated so swapped out for stock vs
#FROM lukechannings/deno:v1.46.1
FROM denoland/deno:v1.46.1
#Get some stuff
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl gcc ca-certificates libc6-dev git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
#rustup is an installer for the systems programming language Rust    
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
#getting part 1 (obsidian-export) https://github.com/zoni/obsidian-export (Rust library and CLI to export an Obsidian vault to regular Markdown)
    # RUST
RUN /root/.cargo/bin/cargo install obsidian-export

WORKDIR /app
# Snag AMD64 vs ARM64
ARG TARGETARCH
# Updated Hugo -8/26/2024 - Docker Hugo dosen't have the extended version, AFIK
RUN curl -L -o hugo.tar.gz -O "https://github.com/gohugoio/hugo/releases/download/v0.133.1/hugo_extended_0.133.1_linux-$TARGETARCH.tar.gz" 
RUN tar fx hugo.tar.gz
# Hugo site template for Obsidian vault
RUN git clone --recursive https://github.com/vrtmrz/hugoconfig-livesync-publisher -b 0.0.2 hugosite
# A static-site-generator runner for Self-hosted LiveSync.
    # Deno
RUN git clone --recursive https://github.com/vrtmrz/livesync-subscribe-publish -b 0.0.4 subscriber

# ADD hugosite (template) ./hugosite
ADD hugo.template.toml ./hugo.template.toml
# ADD subscriber (publish) ./subscriber
RUN cd ./subscriber && deno cache main.ts

# ADD Obsidian vault to hugo script
# gets something, awks something, cd's around
ADD build.sh .
# makes some dirs, echos some vars, calls ./build.sh uses deno x 2 genconf.ts(applies the vars) + main.ts(does the deed) from publisher
ADD run.sh .
#hmmm, shouldn't this be a var?
EXPOSE 8080
ENTRYPOINT [ "/bin/sh" ]
CMD [ "/app/run.sh" ]
