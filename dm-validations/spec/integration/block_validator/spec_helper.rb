# -*- coding: utf-8 -*-

module DataMapper
  module Validate
    module Fixtures
      class G3Concert
        #
        # Bahaviors
        #

        include ::DataMapper::Validate

        #
        # Attributes
        #

        attr_accessor :year, :participants, :city

        #
        # Validations
        #

        validates_with_block :participants do
          if self.class.known_performances.any? { |perf| perf == self }
            true
          else
            [false, "this G3 is probably yet to take place"]
          end
        end

        #
        # API
        #

        def initialize(attributes = {})
          attributes.each do |key, value|
            self.send("#{key}=", value)
          end
        end

        def ==(other)
          other.year == self.year && other.participants == self.participants && other.city == self.city
        end

        # obvisouly this is intentionally shortened list ;)
        def self.known_performances
          [
           new(:year => 2004, :participants => "Joe Satriani, Steve Vai, Yngwie Malmsteen", :city => "Denver"),
           new(:year => 1996, :participants => "Joe Satriani, Steve Vai, Eric Johnson", :city => "San Francisco"),
           new(:year => 2001, :participants => "Joe Satriani, Steve Vai, John Petrucci", :city => "Los Angeles"),
           new(:year => 2002, :participants => "Joe Satriani, Steve Vai, John Petrucci", :city => "Los Angeles")
          ]
        end
      end # G3Concert
    end # Fixtures
  end # Validate
end # DataMapper
