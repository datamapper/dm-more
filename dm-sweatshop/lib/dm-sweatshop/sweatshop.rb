module DataMapper
  class Sweatshop
    class << self
      attr_accessor :model_map
      attr_accessor :record_map
    end

    self.model_map = Hash.new {|h,k| h[k] = Hash.new {|h,k| h[k] = []}}
    self.record_map = Hash.new {|h,k| h[k] = Hash.new {|h,k| h[k] = []}}

    def self.add(klass, name, &proc)
      self.model_map[klass][name.to_sym] << proc
    end

    def self.record(klass, name, instance)
      self.record_map[klass][name.to_sym] << instance
      instance
    end

    def self.create(klass, name, attributes = {})
      begin
        record(klass, name, klass.create(attributes(klass, name).merge(attributes)))
      rescue StandardError => e
        retry if e.message =~ /^column \w+ is not unique$/
        raise e
      end
    end

    def self.make(klass, name, attributes = {})
      record(klass, name, klass.new(attributes(klass, name).merge(attributes)))
    end

    def self.pick(klass, name)
      self.record_map[klass][name.to_sym].pick || raise(NoFixturesExist, "no #{name} context fixtures have been generated for the #{klass} class")
    end

    def self.attributes(klass, name)
      proc = model_map[klass][name.to_sym].pick

      if not proc.nil?
        proc.call
      elsif klass.superclass.is_a?(DataMapper::Model)
        attributes(klass.superclass, name)
      else
        raise "#{name} fixture was not found"
      end
    end
  end
end
