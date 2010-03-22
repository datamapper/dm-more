require 'dm-core'

begin
  require 'active_support/core_ext/date_time/conversions'
rescue LoadError
  require 'extlib/datetime'
end

module DataMapper
  module Types

    autoload :BCryptHash,         'dm-types/bcrypt_hash'
    autoload :CommaSeparatedList, 'dm-types/comma_separated_list'
    autoload :Csv,                'dm-types/csv'
    autoload :Enum,               'dm-types/enum'
    autoload :EpochTime,          'dm-types/epoch_time'
    autoload :FilePath,           'dm-types/file_path'
    autoload :Flag,               'dm-types/flag'
    autoload :IPAddress,          'dm-types/ip_address'
    autoload :Json,               'dm-types/json'
    autoload :Regexp,             'dm-types/regexp'
    autoload :Serial,             'dm-types/serial'
    autoload :Slug,               'dm-types/slug'
    autoload :URI,                'dm-types/uri'
    autoload :UUID,               'dm-types/uuid'
    autoload :Yaml,               'dm-types/yaml'

  end
end
