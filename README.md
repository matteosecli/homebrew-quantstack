# homebrew-quantstack
🍺 Homebrew tap for QuantStack packages


## Installation

### How to add this tap

Add this tap to your Homebrew installation via:

```bash
brew tap matteosecli/quantstack
```


### How to install packages

After having added this tap, you can install the package you want via:

```bash
brew install matteosecli/quantstack/<package>
```

or (**only** if `<package>` is not already in some other tap)

```bash
brew install <package>
```

#### xeus-cling

To install `xeus-cling`, use:

```bash
brew install xeus-cling
```

#### xtensor

To install `xtensor`, use:

```bash
brew install matteosecli/quantstack/xtensor
```

:warning: **do not** install `xtensor` or `xsimd` via `brew install xtensor|xsimd`, you **have to** always specify the **`matteosecli/quantstack/`** bit! Otherwise, those packages get installed from `homebrew/core` and mess up with this tap.

#### xwidgets

To install `xwidgets`, use:

```bash
brew install xwidgets
```

Note that in order to actually use `xwidgets` in Jupyter, you have to install the corresponding front-end extension in Jupyter itself; the `xwidgets` package does not install Jupyter, but it tries to install a Jupyter Classic Notebook front-end extension that another or a future installation of Jupyter can find.

It's highly recommended that you install Jupyter as well, e.g. via Homebrew:

```bash
brew install jupyterlab
```

and check that the command `jupyter nbextension list` outputs somethink like (assuming that Homebrew links in `/usr/local/`):

```console
$ jupyter nbextension list
Known nbextensions:
  [...]
  config dir: /usr/local/etc/jupyter/nbconfig
    notebook section
      jupyter-js-widgets/extension  enabled 
      - Validating: OK
  [...]
```

If that's not the case, you have to manually install the extension (use `brew info xwidgets` for instructions).

If instead you already have `jupyter-js-widgets/extension` enabled in your Jupyter because maybe you already use something like `ipywidgets` in Classic Notebook, then you should be set-up as well and you can ignore the brew link warnings about the extension files.

If instead you prefer JupyterLab over Classic Notebook, install the "@jupyter-widgets/jupyterlab-manager" extension in JupyterLab's graphical extension manager or via the command line:

```bash
jupyter labextension install @jupyter-widgets/jupyterlab-manager
```


## :warning: Warning :warning:

- Since I do not provide bottles, things are installed from source. That could take a while.
- If you want to avoid messing up with packages from other taps, always install via `brew install matteosecli/quantstack/<package>`
