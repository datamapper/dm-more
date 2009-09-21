gem 'hoe', '~>2.3'
require 'hoe'

@config_file = '~/.rubyforge/user-config.yml'
@config = nil
RUBYFORGE_USERNAME = 'unknown'
def rubyforge_username
  unless @config
    begin
      @config = YAML.load(File.read(File.expand_path(@config_file)))
    rescue
      puts <<-EOS
ERROR: No rubyforge config file found: #{@config_file}
Run 'rubyforge setup' to prepare your env for access to Rubyforge
 - See http://newgem.rubyforge.org/rubyforge.html for more details
      EOS
      exit
    end
  end
  RUBYFORGE_USERNAME.replace @config['username']
end

# Remove hoe dependency
class Hoe
  def extra_dev_deps
    @extra_dev_deps.reject! { |dep| dep[0] == 'hoe' }
    @extra_dev_deps
  end
end

# remove the hoe test task
# (we have our own, with custom spec.opts file reading)
Hoe.plugins.delete(:test)

Hoe.spec(GEM_NAME) do
  developer(AUTHOR, EMAIL)

  self.version      = GEM_VERSION
  self.description  = PROJECT_DESCRIPTION
  self.summary      = PROJECT_SUMMARY
  self.url          = PROJECT_URL
  self.readme_file  = 'README.rdoc'
  self.history_file = 'History.rdoc'

  self.rubyforge_name = PROJECT_NAME if PROJECT_NAME

  self.clean_globs |= GEM_CLEAN
  self.extra_deps  |= GEM_DEPENDENCIES

  self.spec_extras = GEM_EXTRAS if GEM_EXTRAS
end
