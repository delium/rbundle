# Rmake

A bundler for R capable of installing packages from cran

## Installation

Add this line to your application's Gemfile:

    gem 'rbundle'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rbundle

## Usage
### Defining Dependencies

Create a file named dependencies.txt like below(YAML format)
```yaml
---
- package: 'data.table'
  version: '1.9.6'

- package: 'ISOweek'
  version: '0.6-2'
```

From the folder containing the Rmake file run rbundle

```bash
    $ rbundle
```

You are done, you should now see all packages(which are not present or having older versions) being downloaded and installed on your machine.

## Known Issues / Behaviour
The base R installation cannot be automated. If unmatching R version is found, Rmake would stall requiring you to match the R version manually and then continue with package installation.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
