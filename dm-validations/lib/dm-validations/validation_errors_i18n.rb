module DataMapper
  module Validate
    class ValidationErrors
      class << self
        alias_method :original_default_error_message, :default_error_message

        @@translations_loaded_to_i18n = false
      end

      def self.default_error_message(key, field, *values)
        extra = values.last.is_a?(::Hash) ? values.pop : {}
        if extra[:target] and defined?(I18n) then
          load_default_translations
          klass = Extlib::Inflection.underscore(extra[:target].class.to_s)
          translated_field = find_translation( field, [
                                    ["data_mapper.models.#{klass}.properties"],
                                    ["data_mapper.models._default.properties"],
                                    ["models.#{klass}.properties"],
                                    ["models._default.properties"]
                                  ])

          return find_translation( key, [
                                    ["data_mapper.errors.#{klass}.properties.#{field}"],
                                    ["data_mapper.errors.#{klass}"],
                                    ["data_mapper.errors.messages"]
                                  ], {:field => translated_field}.merge(extra) )
        else
          original_default_error_message key, field, values
        end
      end

      private
        def self.find_translation(field, scopes, options = {})
          result = nil
          scopes.each {|scope|
            begin
              result = I18n.translate field, options.merge({ :raise => true, :scope => scope })
              break
            rescue I18n::MissingTranslationData
              next
            end
          }
          result || field
        end
        
        def self.load_default_translations
          return if @@translations_loaded_to_i18n
          I18n.load_path.insert(0, Dir[File.join(File.dirname(__FILE__), 'locale', '*.{rb,yml}')]).flatten!
          I18n.reload! if I18n.backend.initialized?
          @@translations_loaded_to_i18n = true
        end
    end
  end
end

