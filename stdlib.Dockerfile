# Set this as a build arg
# Example: `docker build --build-arg AGDA_VERSION=2.6.2.2`
ARG AGDA_VERSION
ARG STDLIB_VERSION
# We need a Cabal version that still supports the `v1-install`,
# which generates no hashes in its paths
ARG CABAL_VERSION=2.4.1.0
# We need a GHC version our Cabal version is tested with,
# and that Agda is tested with.
ARG GHC_VERSION=8.6.5


#
# The build stage. In this image, Cabal will build Agda.
# This image will contains all build dependencies and is
# thus rather large (~2 GB). To avoid that, there is another
# stage below.
#
FROM debian:buster-slim AS build

# reclaim arguments from outer scope
ARG AGDA_VERSION
ARG GHC_VERSION
ARG CABAL_VERSION
ARG STDLIB_VERSION

# Install Agda's build dependencies
RUN apt-get update &&\
    apt-get install -y --no-install-recommends zlib1g-dev build-essential curl wget libffi-dev libffi6 libgmp-dev libgmp10 libncurses-dev libncurses5 libtinfo5 ca-certificates &&\
    rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | BOOTSTRAP_HASKELL_NONINTERACTIVE=1 BOOTSTRAP_HASKELL_MINIMAL=1 sh

ENV PATH=/root/.ghcup/bin:/root/.cabal/bin:${PATH}

RUN ghcup install ghc ${GHC_VERSION} --set
RUN ghcup install cabal ${CABAL_VERSION} --set

# Install Agda dependencies
RUN cabal v2-update &&\
    cabal v2-install alex &&\
    cabal v2-install happy

WORKDIR /usr/local/bin

# Build Agda with Cabal (This takes a long time)
# It is installed to `/bin/agda`
# We specifically use the `v1-install`,
# as it does /not/ generate a hash in the path
RUN cabal get Agda-${AGDA_VERSION} &&\
    cd Agda-${AGDA_VERSION} &&\
    cabal v1-install --prefix=/ -O2

# Download and unpack the standard library
RUN wget -O agda-stdlib.tar.gz https://github.com/agda/agda-stdlib/archive/v${STDLIB_VERSION}.tar.gz &&\
    tar -zxvf agda-stdlib.tar.gz &&\
    rm agda-stdlib.tar.gz


#
# The final stage. Here we copy the previously-built Agda
# executable into a clean container. We ensure all runtime
# dependencies are present.
#
FROM debian:buster-slim

# reclaim arguments from outer scope
ARG AGDA_VERSION
ARG GHC_VERSION
ARG STDLIB_VERSION

# Install Agda runtime dependencies
RUN apt-get update &&\
    apt-get install -y --no-install-recommends libatomic1 &&\
    apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /var/lib/log/* /tmp/* /var/tmp/*

# Agda built-in library
COPY --from=build /share/x86_64-linux-ghc-${GHC_VERSION}/Agda-${AGDA_VERSION} /share/x86_64-linux-ghc-${GHC_VERSION}/Agda-${AGDA_VERSION}

# Agda executable
COPY --from=build /bin/agda /bin/agda

# Agda stdlib
COPY --from=build /usr/local/bin/agda-stdlib-${STDLIB_VERSION} /usr/local/bin/agda-stdlib-${STDLIB_VERSION}

# Make sure Agda can find the stdlib
RUN mkdir /root/.agda &&\
    echo "/usr/local/bin/agda-stdlib-${STDLIB_VERSION}/standard-library.agda-lib" > /root/.agda/libraries
