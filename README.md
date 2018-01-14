# xgboost Online Installer

This is Laurae's xgboost online installer: it allows to install xgboost from source directly from your R terminal.

## Installation

```r
devtools::install_github("Laurae2/xgbdl")
```

## Usage

You need to define the proper compiler to use. It could be:

* gcc (if using Linux or Rtools/MinGW)
* Visual Studio 15 2017 Win64 (Rtools/Visual Studio)
* Visual Studio 14 2015 Win64 (Rtools/Visual Studio)

It is as simple as this:

```r
xgbdl::xgb.dl(compiler = "Visual Studio 15 2017 Win64")
```

For GPU installation in R:

```r
xgbdl::xgb.dl(compiler = "Visual Studio 15 2017 Win64", use_gpu = TRUE)
```

For AVX support in R:

```r
xgbdl::xgb.dl(compiler = "Visual Studio 15 2017 Win64", use_avx = TRUE)
```

Make sure to have the necessary pre-requisites:

- git (Windows: http://gitforwindows.org/)
- cmake (https://cmake.org/download/)
- any of those: gcc (Linux), Rtools + MinGW (Windows), Rtools + Visual Studio 2015 or 2017 (Windows)
- for GPU xgboost: CUDA

Tested working on:

- Visual Studio 2015
- Visual Studio 2017
- MinGW

Make sure also to provide a version older than the v0.7: commit dmlc/xgboost@8d35c09 on Dec 30 2017, otherwise you will get funny stuff.
