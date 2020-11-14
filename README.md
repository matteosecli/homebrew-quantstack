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


## :warning: Warning :warning:

- Since I do not provide bottles, things are installed from source. That could take a while.
- If you want to avoid messing up with packages from other taps, always install via `brew install matteosecli/quantstack/<package>`
