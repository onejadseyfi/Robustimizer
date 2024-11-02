# Robustimizer

## Description

Robustimizer is a Matlab-based application for surrogate-model-based robust optimization.

[TOC]

## Main Features

- Analytical propagation of noise via surrogate models
- Performing principal component analysis (PCA) on the input noise
- Automatic update of the initial design of experiments (DoE) based on multiple criteria
- Communication with user-defined scripts

## Requirements

To run this project in its source form, you will need the following software installed on your system:

- Matlab R2022b or later

## Installation

When running from source, clone the repository to your local machine. After starting Matlab, change to the `src` directory and run the `filepaths.m` script to set up the required paths:

```matlab
filepaths
```

Then, you can run the `Robustimizer2024.mlapp` app to start the application:.

```matlab
Robustimizer2024
```

## Usage

See the relevant chapters in the [Technical details (Word) document](<documentation/Technical details.docx>).

## Contributing

Contributions are welcome! Please see the [contributing guidelines](CONTRIBUTING.md) for more information.

## License

For license information, please see the [licence](LICENSE.md) file.
