# Set this as a build arg
# Example: `docker build --build-arg AGDA_VERSION=2.6.2.2`
ARG AGDA_VERSION
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
FROM alpine:3.20 AS build

# reclaim arguments from outer scope
ARG AGDA_VERSION
ARG GHC_VERSION
ARG CABAL_VERSION

# Install Agda's build dependencies
RUN apk upgrade --no-cache &&\
    apk add --no-cache alpine-sdk curl ncurses-dev gmp-dev perl zlib-dev cabal

# Download Haskell
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | BOOTSTRAP_HASKELL_NONINTERACTIVE=1 BOOTSTRAP_HASKELL_MINIMAL=1 sh

ENV PATH=/root/.ghcup/bin:/root/.cabal/bin:${PATH}

RUN ghcup install ghc ${GHC_VERSION} --set

WORKDIR /usr/local/bin

RUN git clone --depth 1 --branch cabal-install-v${CABAL_VERSION} https://github.com/haskell/cabal.git

RUN cd cabal/cabal-install &&\
    ./bootstrap.sh

# Install Agda dependencies
# 
# Note that "cpphs" is not needed for newer versions of Agda.
# But it is needed for the older versions, so we include it.
# This is only the build stage anyway.
RUN cabal v1-update
RUN cabal v1-install alex happy cpphs

# Build Agda with Cabal (This takes a long time)
# It is installed to `/bin/agda`
# We specifically use the `v1-install`,
# as it does /not/ generate a hash in the path
RUN cabal get Agda-${AGDA_VERSION} &&\
    cd Agda-${AGDA_VERSION} &&\
    cabal v1-install -f optimise-heavily --enable-split-sections --prefix=/ --enable-static -O2


#
# The final stage. Here we copy the previously-built Agda
# executable into a clean container. We ensure all runtime
# dependencies are present.
#
FROM alpine:3.20

# reclaim arguments from outer scope
ARG AGDA_VERSION
ARG GHC_VERSION

# Install Agda runtime dependencies
RUN apk add --no-cache libatomic ncurses gmp


# Agda built-in library
COPY --from=build /share/x86_64-linux-ghc-${GHC_VERSION}/Agda-${AGDA_VERSION} /share/x86_64-linux-ghc-${GHC_VERSION}/Agda-${AGDA_VERSION}

# The "proof" user needs write permissions to write the *.agdai files.
RUN chmod -R a+w /share/x86_64-linux-ghc-${GHC_VERSION}/Agda-${AGDA_VERSION}/lib

# Agda executable
COPY --from=build /bin/agda /bin/agda

RUN addgroup -S proof && adduser -S proof -G proof
USER proof
WORKDIR /home/proof
