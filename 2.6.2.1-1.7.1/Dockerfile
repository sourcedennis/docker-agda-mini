#
# The build stage. In this image, Cabal will build Agda.
# This image will contains all build dependencies and is
# thus rather large (~2 GB). To avoid that, there is another
# stage below.
#
FROM debian:buster-slim AS build

# Install cabal and other build dependencies
# * cabal-install and zlib1g-dev are for building Agda
# * wget and ca-certificates are for downloading Agda's stdlib
RUN apt-get update &&\
    apt-get install -y --no-install-recommends cabal-install zlib1g-dev wget ca-certificates &&\
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

# Download and unpack the standard library
RUN wget -O agda-stdlib.tar https://github.com/agda/agda-stdlib/archive/v1.7.1.tar.gz &&\
    tar -zxvf agda-stdlib.tar &&\
    rm agda-stdlib.tar


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

# Agda stdlib
COPY --from=build /usr/local/bin/agda-stdlib-1.7.1 /usr/local/bin/agda-stdlib-1.7.1

# Agda executable
COPY --from=build /bin/agda /bin/agda

# Make sure Agda can find the stdlib
COPY libraries /root/.agda/
