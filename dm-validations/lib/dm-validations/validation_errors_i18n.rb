module DataMapper
  module Validate
    class ValidationErrors
      class << self
        alias_method :original_default_error_message, :default_error_message
      end

      def self.i18n_present?
        return true if I18n rescue false
      end

      def self.default_error_message(key, field, *values)
        extra = values.last.is_a?(::Hash) ? values.pop : {}
        if extra[:target] and i18n_present? then
          klass = extra[:target].class.to_s.underscore.to_sym
          field = find_translation( field, [
                                    [:data_mapper, :models, klass, :properties],
                                    [:data_mapper, :models, :_default, :properties],
                                    [:models, klass, :properties],
                                    [:models, :_default, :properties]
                                  ])
        end
        original_default_error_message key, field, values
      end

      private
        def self.find_translation(field, scopes)
          result = nil
          scopes.each {|scope|
            begin
              result = I18n.translate field, { :raise => true, :scope => scope }
              break
            rescue I18n::MissingTranslationData
              next
            end
          }
          result || field
        end
    end
  end
end

