require "rmake/version"
require "rinruby"
require 'yaml'
R.quit

class RBundler
  def self.bundle
    puts "Reading system requirements from Rmake\n"
    system_requirements = YAML.load(File.open(Dir.pwd + '/Rmake'))
    r_version = system_requirements['r_version']
    bundle_env = runtime_env
    packages = system_requirements[bundle_env]
    validate(bundle_env, packages)
    RPackageManager.new([{'name' => 'devtools'},{'name' => 'RCurl'}], r_version).resolve
    RPackageManager.new(packages.flatten, r_version).install_dependencies.resolve
  end

  def self.deptree
    system_requirements = YAML.load(File.open(Dir.pwd + '/Rmake'))
    bundle_env = runtime_env
    packages = system_requirements[bundle_env]
    validate(bundle_env, packages)
    packages = packages.flatten
    RPackageManager.new(packages, nil).dep_tree packages
  end

  def self.validate(bundle_env, packages)
    raise "Unknown environment: #{bundle_env.upcase}" if packages.nil? or packages.empty?
  end

  def self.runtime_env
    ENV['R_ENV'].nil? ? "test" : ENV['R_ENV'].downcase
  end
end

class RPackageManager
  SOURCES = %w(git local url)

  def initialize (packages, r_version)
    @declared_dependencies = packages
    @expected_r_version = r_version
  end

  def dep_tree (packages)
    packages.each_with_object({}) do |theoretical_dependency, acc|
      acc[theoretical_dependency['name']] = dependencies(theoretical_dependency)
    end
  end

  def all_dependencies(packages)
    (dep_tree(packages).map { |_, b| b }).flatten.uniq
  end

  def dependencies(theoretical_dependency)
    r_evaluator.pull "tools::package_dependencies('#{theoretical_dependency['name']}', available.packages(), which=c('Depends', 'Imports'), recursive=TRUE)[['#{theoretical_dependency['name']}']]"
  rescue
    puts "WARNING: Unable to fetch dependencies for #{theoretical_dependency}. Will be assumed as none.\n"
    []
  end

  def resolve
    validate_r_version
    puts 'Indexing Current System State'
    packages_on_system = installed_packages
    @declared_dependencies.each do |package|
      if (source(package) == 'local' || !match_version_verbatim?(package, packages_on_system))
        remove_package(package) if packages_on_system.key?(package['name'])
        install_package(package)
        packages_on_system = installed_packages
        raise("Could not install package #{package['name']}, version #{package['version']}") if (install_required?(package, packages_on_system))
      else
        puts "Using package: #{package['name']}:#{packages_on_system[package['name']]}"
      end
    end
    @r_evaluator.quit
  end

  def remove_package(package_name)
    package_name=package_name['name']
    puts "Removing package: #{package_name}"
    r_evaluator.eval "remove.packages('#{package_name}')"
  end

  def install_required?(package, packages_on_system)
    packages_on_system[package['name']].nil? || ((!package['version'].nil?) && packages_on_system[package['name']] != package['version'])
  end

  def match_version_verbatim?(package, packages_on_system)
    packages_on_system.key?(package['name']) && (package['version'].nil? || packages_on_system[package['name']] == package['version'])
  end

  def validate_r_version
    return if installed_r_version['major'] == @expected_r_version['major'].to_s && installed_r_version['minor'] >= @expected_r_version['minor'].to_s
    raise("Please install R version #{@expected_r_version['major']}.#{@expected_r_version['minor']} manually before continuing")
  end

  def installed_r_version
    {
        'major' => r_evaluator.pull('as.character(version$major)'),
        'minor' => r_evaluator.pull('as.character(version$minor)')
    }
  end

  def install_package(package_name)
    puts "Installing package: #{package_name['name']}"
    case source(package_name)
      when 'git'
        install_from_git package_name
      when 'local'
        install_local package_name
      when 'url'
        install_url package_name
      else
        install_from_cran package_name
    end

  end

  def source(package_name)
    (package_name.keys & SOURCES).first
  end

  def install_dependencies
    puts 'Indexing packaging dependencies'
    packages_on_system = installed_packages
    all_dependencies(@declared_dependencies).each do |dep|
      dependency = {'name' => dep}
      install_required?(dependency, packages_on_system) ? install_package(dependency) : puts("Using #{dep}")
    end
    @r_evaluator.quit
    self
  end

  def install_from_cran(package_name)
    package_name['version'] ? install_specific_version(package_name) : install_latest_version(package_name)
  end

  def install_latest_version(package_name)
    r_evaluator.eval("install.packages('#{package_name['name']}')")
    r_evaluator.eval("update.packages(oldPkgs='#{package_name['name']}')")
  end

  def install_specific_version(package_name)
    r_evaluator.eval("library(devtools); install_version('#{package_name['name']}', '#{package_name['version']}')")
  end

  def install_local(package_name)
    r_evaluator.eval "library(devtools); install_local('#{package_name['local']}')"
  end

  def install_url(package_name)
    r_evaluator.eval "library(devtools); install_url('#{package_name['url']}')"
  end

  def install_from_git(package_name)
    command = git_command package_name
    r_evaluator.eval "library(devtools); #{command}"
  end

  def git_handle package_name
    "#{package_name['git']['author']}/#{package_name['git']['repo']}"
  end

  def git_command package_name
    package_name['version'].nil? ? "install_github('#{git_handle(package_name)}')" : "install_github('#{git_handle(package_name)}', ref='#{package_name['version']}')"
  end


  def installed_packages
    installed_packages=r_evaluator.pull 'as.character(data.frame(installed.packages(lib.loc = NULL, priority = NULL, noCache = FALSE, fields = NULL,subarch = .Platform$r_arch))$Package)'
    installed_versions=r_evaluator.pull 'as.character(data.frame(installed.packages(lib.loc = NULL, priority = NULL, noCache = FALSE, fields = NULL,subarch = .Platform$r_arch))$Version)'
    installed_packages.each_with_index.each_with_object({}) do |with_index, acc|
      acc[with_index.at(0)] = installed_versions[with_index.at(1)]
    end
  end

  def r_evaluator
    begin
      @r_evaluator.quit
    rescue

    ensure
      @r_evaluator = RinRuby.new(false)
      @r_evaluator.eval 'local({r <- getOption("repos"); r["CRAN"] <- "http://cran.us.r-project.org"; options(repos = r)})'
    end
    @r_evaluator
  end
end
