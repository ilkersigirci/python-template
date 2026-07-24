This site contains the project documentation for the
`{{cookiecutter.project_slug}}` project.

## Table Of Contents

The documentation follows the best practice for
project documentation as described by Daniele Procida
in the [Diátaxis documentation framework](https://diataxis.fr/)
and consists of four separate parts:

1. [Tutorials](tutorials.md)
2. [How-To Guides](how-to-guides.md)
3. [Reference](reference.md)
4. [Explanation](explanation.md)

Quickly find what you're looking for depending on
your use case by looking at the different pages.

## Documentation workflow

The site uses [Zensical](https://zensical.org/) with its modern theme.

```bash
# Start the live-reloading documentation server.
make doc-serve

# Run a clean, strict documentation build.
make doc-build
```
