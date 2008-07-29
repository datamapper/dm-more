module DataMapper
  module Is
    module Remixable
      
      #==============================INCLUSION METHODS==============================#
      
      # Adds remixer methods to DataMapper::Resource
      def self.included(base)
        base.send(:include,RemixerClassMethods)
        base.send(:include,RemixerInstanceMethods)
      end
      
      # - is_remixable
      # ==== Description
      #   Adds RemixeeClassMethods and RemixeeInstanceMethods to any model that is: remixable
      # ==== Examples
      # class User #Remixer
      #   remixes Commentable
      #   remixes Vote
      # end
      #
      # module Commentable #Remixable
      #   include DataMapper::Resource
      #
      #   is :remixable,
      #     :suffix => "comment"
      # end
      #
      # module Vote #Remixable
      #   include DataMapper::Resource
      #
      #   is :remixable
      # 
      # ==== Notes
      #   These options are just available for whatever reason your Remixable Module name
      #   might not be what you'd like to see the table name and property accessor named.
      #   These are just configurable defaults, upon remixing the class_name and accessor there
      #   take precedence over the defaults set here 
      # ==== Options
      #   :suffix   <String> 
      #             Table suffix, defaults to YourModule.name.downcase.singular
      #             Yields table name of remixer_suffix; ie user_comments, user_votes
      def is_remixable(options={})
        extend  DataMapper::Is::Remixable::RemixeeClassMethods        
        include DataMapper::Is::Remixable::RemixeeInstanceMethods
               
        suffix(options.delete(:suffix) || self.name.downcase.singular)
      end
      
      
      #==============================CLASS METHODS==============================#
      
      # - RemixerClassMethods
      # ==== Description
      #   Methods available to all DataMapper::Resources
      module RemixerClassMethods
        def self.included(base);end;
        
        # - remixables
        # ==== Description
        #   Returns a hash of the remixables used by this class
        # ==== Returns
        #   <Hash> Remixable Class Name => Remixed Class Name
        def remixables
          @remixables
        end
        
        # - remix 
        # ==== Description
        #   Remixes a Remixable Module
        # ==== Parameters
        #   cardinality <~Fixnum> 1, n, x ...
        #   remixable   <Module> Module to remix
        #   options     <Hash>   options hash
        #                       :class_name <String> Remixed Model name (Also creates a storage_name as tableize(:class_name))
        #                                   The storage_name can be changed via 'enhance' in the class that is remixing
        #                                   Default: self.name.downcase + "_" + remixable.suffix.pluralize
        #                       :accessor   <String> Alias to access associated data
        #                                   Default: tableize(:class_name)
        #                       :for|:on    <Module|Array<Module>> M:M Relationships
        # ==== Examples
        # Given: User (Class), Addressable (Module)
        #   
        #   One-To-Many; Class-To-Remixable
        #
        #   remix n, Addressable,
        #     :class_name => "UserAddress", 
        #     :accessor   => "addresses"       
        #   
        #   Tables: users, user_addresses
        #   Classes: User, UserAddress
        #     User.user_addresses << UserAddress.new
        #     User.addresses << UserAddress.new
        #   --------------------------------------------
        #
        #   Many-To-Many; Class-To-Remixable :through => Resource || "intermediate_of_choice"
        #
        #   remix n, Addressable,
        #     :class_name => "UserAddress", 
        #     :accessor   => "addresses"       
        #     :through    => Resource
        #   
        #   Tables:   ...
        #   Classes:  ...
        #     User.   ...
        #   --------------------------------------------
        # 
        # Given: User (Class), Video (Class), Profile(Class), Blog(Class), Commentable (Module)
        #
        #   Many-To-Many; Class-To-Class :through => RemixableIntermediate (User => Videos :through UserVideos)
        # 
        #   remix n, Commentable
        #     :for        => Video    #:for & :on have same effect, just a choice of wording...
        def remix(cardinality, remixable, options={})
          
          #Merge defaults/options
          options = {
            :accessor   => nil,
            :class_name => Extlib::Inflection.classify(self.name + "_" + remixable.suffix.pluralize),
            :through    => nil,
            :for        => nil,
            :on         => nil
          }.merge(options)
          
          #Other model to mix with in case of M:M through Remixable
          options[:table_name] = Extlib::Inflection.tableize(options[:class_name])
          options[:other_model] = options[:for] || options[:on]
          
          puts " ~ Generating Remixed Model: #{options[:class_name]}"
          
          if options[:through] && options[:other_model]
            raise Exception, ":through and :for|:on should not be specified together for #remix"
          end
          
          #Create Remixed Model          
          klass = Class.new Object do
            include DataMapper::Resource
          end
          
          #Give remixed model a name and create its constant
          model = Object.const_set options[:class_name], klass

          #Get instance methods & validators
          model.send(:include,remixable)

          #port the properties over...
          remixable.properties.each do |prop|
            model.property(prop.name, prop.type, prop.options)
          end
                                     
          #Create relationships between Remixer and remixed class          
          if options[:through].is_a?(Symbol)
            # M:M Class-To-Remixable :through => :model
            #has n, :through (or One-To-Many-Through)

            raise Exception, ":through is not currently supported"
            #self.has  cardinality, options[:table_name].intern, :through => options[:through]
            #model.has cardinality, Extlib::Inflection.tableize(self.name).intern, :through => options[:through]
            
          elsif options[:through].is_a?(Module)
            # M:M Class-To-Remixable :through => Resource
            # Has, and belongs to, many (Or Many-To-Many)
            
            raise Exception, ":through is not currently supported"
            #self.has  cardinality, options[:table_name].intern, :through => options[:through]
            #model.has cardinality, Extlib::Inflection.tableize(self.name).intern, :through => options[:through]
            
          elsif options[:other_model] 
            # M:M Class-To-Class w/ Remixable Module as intermediate table
            # has n and belongs_to (or One-To-Many)
            
            self.has cardinality, options[:table_name].intern
            options[:other_model].has cardinality, options[:table_name].intern
            
            model.belongs_to  Extlib::Inflection.tableize(self.name).intern
            model.belongs_to  Extlib::Inflection.tableize(options[:other_model].name).intern
            
          else 
            # 1:M Class-To-Remixable
            # has n and belongs_to (or One-To-Many)
            
            self.has cardinality, options[:table_name].intern
            model.belongs_to Extlib::Inflection.tableize(self.name).intern

          end

          #Add accessor alias
          unless options[:accessor].nil?
            self.class_eval(<<-EOS, __FILE__, __LINE__ + 1)
              alias #{options[:accessor].intern} #{options[:table_name].intern}
              alias #{options[:accessor].intern}= #{options[:table_name].intern}=
            EOS
          end
          
          #Add the remixed model to the remixables list
          @remixables = {} if @remixables.nil?
          @remixables[remixable] = model
        end
        
        # - enhance
        # ==== Description
        #   Enhance a remix; allows nesting remixables, adding columns & functions to a remixed resource
        # ==== Examples
        #   class Video
        #     include DataMapper::Resource
        #     remix Comment
        #
        #     enhance Comment do
        #       remix Vote        #This would result in something like YouTubes Voting comments up/down
        #       
        #       property :updated_at, DateTime
        #
        #       def backwards; self.test.reverse; end;
        #     end
        def enhance(remixable,&block)
          model = @remixables[remixable]
          
          unless model.nil?
            model.class_eval &block
          else
            raise Exception, "#{remixable} must be remixed before it can be enhanced"
          end
        end
                 
      end # RemixerClassMethods
      
      # - RemixeeClassMethods
      # ==== Description
      #   Methods available to any model that is :remixable
      module RemixeeClassMethods
        def suffix(sfx=nil)
          @suffix = sfx unless sfx.nil?
          @suffix
        end
        
        #Squash auto_migrate!
        def auto_migrate!(args=nil)
          DataMapper.logger.warn("Remixable modules (#{self.name}) cannot be auto migrated")
        end
        
        #Squash auto_upgrade!
        def auto_upgrade!(args=nil)
          DataMapper.logger.warn("Remixable modules (#{self.name}) cannot be auto updated")          
        end
      end # RemixeeClassMethods
      
      
      #==============================INSTANCE METHODS==============================#
            
      module RemixeeInstanceMethods
        def self.included(base);end;
      end # RemixeeInstanceMethods
      
      module RemixerInstanceMethods
        def self.included(base);end;
      end # RemixerInstanceMethods
      
    end # Example
  end # Is
end # DataMapper
