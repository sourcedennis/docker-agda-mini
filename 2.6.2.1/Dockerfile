#
# The build stage. In this image, Cabal will build Agda.
# This image will contains all build dependencies and is
# thus rather large (~2 GB). To avoid that, there is another
# stage below.
#
FROM debian:buster-slim AS build

# Install cabal and Agda's build dependencies
RUN apt-get update &&\
    apt-get install -y --no-install-recommends cabal-install zlib1g-dev &&\
    rm -rf /var/lib/apt/lists/*


# Install Agda dependencies
RUN cabal update &&\
    cabal install alex &&\
    cabal install happy


WORKDIR /usr/local/bin

# Build Agda with Cabal (This takes a long time)
# It is installed to `/bin/agda`
RUN cabal get Agda-2.6.2.1 &&\
    cd Agda-2.6.2.1 &&\
    cabal install --prefix=/


#
# The final stage. Here we copy the previously-built Agda
# executable into a clean container. We ensure all runtime
# dependencies are present.
#
FROM debian:buster-slim

# Install Agda runtime dependencies
RUN apt-get update &&\
    apt-get install -y --no-install-recommends libatomic1 &&\
    rm -rf /var/lib/apt/lists/*


# Agda built-in library
COPY --from=build /share/x86_64-linux-ghc-8.4.4/Agda-2.6.2.1 /share/x86_64-linux-ghc-8.4.4/Agda-2.6.2.1

# Agda executable
COPY --from=build /bin/agda /bin/agda
