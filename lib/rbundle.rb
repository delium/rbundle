require "rbundle/version"
require "yaml"

def with_retries(retries = 3, back_off = 60, args,  &block)
  counter = 1
  until counter > retries do
    begin
      block.call(*args)
      break
    rescue Exception => e
      raise e if counter == retries
      counter = counter + 1
      p "Sleeping #{counter * back_off} seconds"
      sleep counter * back_off;
    end
  end
end

class RBundler
  def self.bundle(parallels)
    install_installer(parallels)
    self.read_requirements.each {|d| install(d, parallels)}
  end

  def self.read_requirements
    dependencies_definitions = "#{Dir.pwd}/dependencies.txt"
    puts "Reading Dependencies to install from #{Dir.pwd}/dependencies.txt"
    YAML.load(File.open(dependencies_definitions))
  end

  def self.command_inspector(exit_code)
    throw 'Installation failed.' if exit_code != 0
  end

  def self.install_installer(parallels)
    with_retries(args=[parallels]) do |parallels|
      puts "Installing devtools"
      command = %{
        R --vanilla --slave -e "options("Ncpus=#{parallels}L"); if (! ('devtools' %in% installed.packages()[,'Package'])) install.packages(pkgs='devtools', repos=c('https://cloud.r-project.org'), INSTALL_opts=c('--no-docs'), quiet=F)"
      }
      puts "Executing #{command}"
      `#{command}`
      `R --slave --vanilla -e "library(devtools)"`
      command_inspector($?.exitstatus)
    end
  end

  def self.install(dependency, parallels)
    with_retries(args = [dependency, parallels]) do |dependency, parallels|
      puts "Installing #{dependency['package']}"
      command = %{
       R --slave --vanilla -e "options(warn=2); options("Ncpus=#{parallels}L"); library(devtools); if ((!'#{dependency['package']}' %in% installed.packages()[,'Package']) || packageVersion('#{dependency['package']}') < '#{dependency['version']}') install_version('#{dependency['package']}', version='#{dependency['version']}', repos=c('https://cloud.r-project.org'), INSTALL_opts=c('--no-docs'), quiet=F)"
      }
      puts "Executing #{command}"
      `#{command}`
      command_inspector($?.exitstatus)
    end
  end
end