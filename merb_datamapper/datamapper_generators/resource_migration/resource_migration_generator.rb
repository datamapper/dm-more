# require 'merb'
class ResourceMigrationGenerator < RubiGen::Base

  # these define datamapper specific properties, not general database concepts
  UNWANTED_PROPERTIES = [:public, :protected, :private, :accessor,
                         :reader, :writer, :lazy, :lock, :field, :ordinal,
                         :track, :auto_validation, :validates]

  default_options :author => nil

  attr_reader :name, :klass

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @name = args.shift
    extract_options
  end

  def manifest
    unless @name
      puts banner
      exit 1
    end

    # first see if we can find our model file where it should be!
    model_file = File.join(Dir.pwd, "app/models","#{@name.snake_case}.rb")
    unless File.exist?(model_file)
      puts "Couldn't find the model file for #{@name}"
      exit 1
    end

    # next, check we actually have a class!
    require model_file
    @klass = Module.const_get(@name.camel_case)
    if @klass.nil?
      puts "File didn't seem to include the model #{@name.camel_case}"
      exit 1
    end




    record do |m|
      # Ensure appropriate folders exists
      m.directory 'schema/migrations'

      @migration_name = "create_%s_table" % @name.snake_case.pluralize

      filename = format("%03d_%s", (highest_migration+1), @migration_name)

      m.template "class_migration.erb", "schema/migrations/#{filename}.rb",
      :assigns => {
        :migration_name => @migration_name ,
        :number => (highest_migration+1),
        :klass_name => klass.storage_name,
        :properties => properties_as_strings
      }

    end
  end

  protected
    def banner
      <<-EOS
Creates a new migration for merb using DataMapper

USAGE: #{$0} #{spec.name} ResourceClass

Example:
  #{$0} #{spec.name} Post

  If you already have 3 migrations, this will create the Post migration in
  schema/migration/004_create_posts_table.rb

NB: Currently the generator doesn't make any columns for 'belongs_to'-type
associations.
EOS
    end

    def add_options!(opts)
      # opts.separator ''
      # opts.separator 'Options:'
      # For each option below, place the default
      # at the top of the file next to "default_options"
      # opts.on("-a", "--author=\"Your Name\"", String,
      #         "Some comment about this option",
      #         "Default: none") { |options[:author]| }
      # opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end

    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
    end

    def highest_migration
      @highest_migration ||= Dir[Dir.pwd+'/schema/migrations/*'].map{ |f|
        File.basename(f) =~ /^(\d+)/
        $1}.max.to_i
    end

    def property_as_string(p)
      name = p.field
      type = p.type.to_s
      # clear out non-db related properties
      options = p.options.reject { |key, value| UNWANTED_PROPERTIES.include? key }
      options_as_array = []
      options.each do |key, value|
        options_as_array << ":#{key} => #{value}"
      end

      (options_as_array.empty?) ? ":#{name}, #{type}" :
        ":#{name}, #{type}, #{options_as_array.join(', ')}"
    end

    def properties_as_strings
      @properties_as_strings ||= klass.properties.map {|p| property_as_string(p) }
    end
end
