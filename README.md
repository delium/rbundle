# Rmake

A bundler for R capable of installing packages from cran, git and local

## Installation

Add this line to your application's Gemfile:

    gem 'rmake'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rmake

## Usage
# Defining Dependencies

Create a file named Rmake like below(YAML format)

From the folder containing the Rmake file run rbundle

```
    $ rbundle install
        or
    $ rbundle
```

You are done, you should now see all packages(which are not present or having older versions) being downloaded and installed on your machine.

# Visualizing a dependency tree

```
    $ rbundle deptree
```

This produces a dependency tree as below

{
    "data.table" => [
        [ 0] "methods",
        [ 1] "reshape2",
        [ 2] "plyr",
        [ 3] "stringr",
        [ 4] "lattice",
        [ 5] "grid",
        [ 6] "grDevices",
        [ 7] "graphics",
        [ 8] "stats",
        [ 9] "utils",
        [10] "Rcpp"
    ],
       "RJSONIO" => "methods",
         "RCurl" => [
        [0] "methods",
        [1] "bitops"
    ],
          "Rook" => [
        [0] "utils",
        [1] "tools",
        [2] "methods",
        [3] "brew"
    ],
     "multicore" => [],
       "R.cache" => [
        [0] "utils",
        [1] "R.methodsS3",
        [2] "R.oo",
        [3] "R.utils",
        [4] "methods"
    ],
        "rmocks" => []
}


## Known Issues / Behaviour
1. No dependencies are assumed if the system cannot be queried for dependencies or there is not network. Dependencies are only resolved for packages available in cran.
2. The base R installation cannot be automated. If unmatching R version is found, Rmake would stall requiring you to match the R version manually and then continue with package installation.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
