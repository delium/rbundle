# Rmake

A bundler for R capable of installing packages from cran and git

## Installation

Add this line to your application's Gemfile:

    gem 'rmake'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rmake

## Usage
Create a file called Rmake in the following structure:

```
{
    "r_version": {
        "major": 3,
        "minor": 0.1
    },
    "packages": [
        {
            "name": "data.table",
            "version": "1.8.10"
        },{
  			    "name": "RJSONIO"
        },{
  			    "name": "RCurl"
        },{
  			    "name": "Rook"
        },{
  			    "name": "multicore"
        },{
  			    "name": "R.cache"
        },{
            "name": "rmocks",
            "git":{
                "url": "https://github.com/jpsimonroy/rmocks.git"
            }
        }

    ]
}
```
From the folder containing the Rmake file run rmake

You are done, you should now see all packages(which are not present or having older versions) being downloaded and installed on your machine.

## Known Issues
1. You cannot downgrade packages or even install packages which are older in version. If a new system is being bootstrapped with rmake, you would be assured to get packages with version greater than or equal to the version specified in your Rmake file.
2. The base R installation cannot be automated. If unmatching R version is found, Rmake would stall requiring you to match the R version manually and then continue with package installation.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
