# docker-agda-mini

Small Docker images containing Agda.

See also: https://hub.docker.com/r/sourcedennis/agda-mini

The main purpose of these images is to provide *easily reproducible* Agda executions. Existing images were often humongous, at roughly \~2 GB (uncompressed). While mine are much smaller (\~130MB uncompressed - 40MB compressed).

Tagging convention:

* There are images *without* the standard library, tagged with the Agda version number *X.Y.Z.W*.
* There are also images *with* the standard library, tagged as *X.Y.Z.W-A.B.C*, where *X.Y.Z.W* is the Agda version and *A.B.C* is the standard library version.

## Example

If you have a local directory with Agda proofs called `proofs/`, you can create a `Dockerfile` like:

```
FROM sourcedennis/agda-mini:2.6.2.1-1.7.1

WORKDIR /proofs
COPY proofs .
```

Which you then build into a Docker image with:
```
docker build . --tag=my-proofs
```

You can execute your proofs with (assuming your `proofs/` directory contains a file `Proof.agda`):
```
docker run -it --rm my-proofs agda Proof.agda
```

As Agda can render proofs to HTML, you can also run:
```
docker run -it --rm -v "$PWD/html:/proofs/html" my-proofs agda --html --html-dir=html Proof.agda
```
This creates a local `html/` directory. You can open `html/Proof.html` in any browser.

## License

Public Domain - See the `LICENSE` file
