require "rmake/version"
require "rinruby"
require 'json'

class Bundler
  def self.bundle
    print "Reading system requirements from Rmake\n"
    system_requirements = JSON.parse(File.read(Dir.pwd + '/Rmake'))
    r_version = system_requirements['r_version']
    packages = system_requirements['packages']
    PackageManager.new(packages, r_version).resolve
  end
end

class PackageManager
  def initialize (packages, r_version)
    @packages_to_install = packages
    @expected_r_version = r_version
  end

  def resolve
    validate_r_version
    packages_on_system = installed_packages
    @packages_to_install.each do |package|
      if(packages_on_system[package['name']].nil? || ((!package['version'].nil?) && packages_on_system[package['name']] < package['version']))
        install_package(package)
        packages_on_system = installed_packages
        raise("Could not install package #{package['name']}, version #{package['version']}") if (packages_on_system[package['name']].nil? || packages_on_system[package['version']].to_s < package['version'])
      else
        puts "Using package: #{package['name']}:#{packages_on_system[package['name']]}"
      end

    end
  end

  def validate_r_version
    return if installed_r_version['major'] == @expected_r_version['major'].to_s && installed_r_version['minor'] == @expected_r_version['minor'].to_s
    raise("Please install R version #{@expected_r_version['major']}.#{@expected_r_version['minor']} manually before continuing")
  end

  def installed_r_version
    {
        'major' => R.pull('as.character(version$major)'),
        'minor'=> R.pull('as.character(version$minor)')
    }
  end

  def install_package(package_name)
    puts "Installing package: #{package_name['name']}"
    R.eval("install.packages('#{package_name['name']}', dependencies=T,  repos='http://cran.us.r-project.org')")
  end

  def installed_packages
    installed_packages=R.pull 'as.character(data.frame(installed.packages(lib.loc = NULL, priority = NULL, noCache = FALSE, fields = NULL,subarch = .Platform$r_arch))$Package)'
    installed_versions=R.pull 'as.character(data.frame(installed.packages(lib.loc = NULL, priority = NULL, noCache = FALSE, fields = NULL,subarch = .Platform$r_arch))$Version)'
    installed_packages.each_with_index.each_with_object({}) do |with_index, acc|
      acc[with_index.at(0)] = installed_versions[with_index.at(1)]
    end
  end
end
