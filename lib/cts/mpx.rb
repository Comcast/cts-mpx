require 'base64'
require 'creatable'
require 'excon'
require 'oj'
require 'uri'
require 'cts/mpx/version'

# ring 1 (driver)
require 'cts/mpx/driver'
require 'cts/mpx/driver/assemblers'
require 'cts/mpx/driver/connections'
require 'cts/mpx/driver/exceptions'
require 'cts/mpx/driver/helpers'
require 'cts/mpx/driver/page'
require 'cts/mpx/driver/response'
require 'cts/mpx/driver/request'

# ring 2 (depends on driver)
require 'cts/mpx/validators'
require 'cts/mpx/user'
require 'cts/mpx/registry'
require 'cts/mpx/service'
require 'cts/mpx/services'
require 'cts/mpx/services/data'
require 'cts/mpx/services/web'
require 'cts/mpx/services/ingest'

# ring 3 (depends on ring 2 services)
require 'cts/mpx/field'
require 'cts/mpx/fields'
require 'cts/mpx/entry'
require 'cts/mpx/entries'
require 'cts/mpx/query'

# Comcast Technical Solutions - Mpx
module Cts::Mpx
  Services.initialize
  Registry.initialize
  Driver::Connections.initialize
end
