require "rmake/version"
require "yaml"

class RBundler
  def self.bundle
    install_installer
    self.read_requirements.each {|d| install(d)}
  end

  def self.read_requirements
    dependencies_definitions = "#{Dir.pwd}/dependencies.txt"
    puts "Reading Dependencies to install from #{Dir.pwd}/dependencies.txt"
    YAML.load(File.open(dependencies_definitions))
  end

  def self.command_inspector(exit_code)
    if(exit_code != 0) 
      puts("Installation failed")
      exit(exit_code)
    end
  end

  def self.install_installer
    puts "Installing devtools"
    command = %{
      R --vanilla --slave -e "if (! ('devtools' %in% installed.packages()[,'Package'])) install.packages(pkgs='devtools', repos=c('https://cloud.r-project.org'))"
    }
    puts "Executing #{command}"
    `#{command}`
    command_inspector($?.exitstatus)
  end

  def self.install(dependency)
    puts "Installing #{dependency['package']}"
    command = %{
     R --slave --vanilla -e "options(warn=2); library(devtools); if ((!'#{dependency['package']}' %in% installed.packages()[,'Package']) || packageVersion('#{dependency['package']}') < '#{dependency['version']}') install_version('#{dependency['package']}', version='#{dependency['version']}', repos=c('https://cloud.r-project.org'))"
    }
    puts "Executing #{command}"
    `#{command}`
    command_inspector($?.exitstatus)
  end
end