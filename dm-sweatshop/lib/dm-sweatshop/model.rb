module DataMapper
  module Model
    def fixture(name = default_fauxture_name, &blk)
      Sweatshop.add(self, name, &blk)
    end

    alias_method :fix, :fixture

    def generate(name = default_fauxture_name, attributes = {})
      name, attributes = default_fauxture_name, name if name.is_a? Hash
      Sweatshop.create(self, name, attributes)
    end

    alias_method :gen, :generate

    def generate_attributes(name = default_fauxture_name)
      Sweatshop.attributes(self, name)
    end

    alias_method :gen_attrs, :generate_attributes

    def make(name = default_fauxture_name, attributes = {})
      name, attributes = default_fauxture_name, name if name.is_a? Hash
      Sweatshop.make(self, name, attributes)
    end

    def pick(name = default_fauxture_name)
      Sweatshop.pick(self, name)
    end

    def default_fauxture_name
      :default
    end
  end
end
