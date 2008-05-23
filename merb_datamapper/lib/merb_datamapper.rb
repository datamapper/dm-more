
require File.join(File.dirname(__FILE__) / "merb" / "orms" / "data_mapper" / "connection")
require File.join(File.dirname(__FILE__) / "merb" / "orms" / "data_mapper" / "resource")

Merb::Orms::DataMapper.connect
Merb::Orms::DataMapper.register_session_type

if defined?(Merb::Plugins)
  Merb::Plugins.add_rakefiles "merb_datamapper" / "merbtasks"
end
