#!/usr/bin/env ruby
#############################################################################
# A custom fact to return the uid of a user called opscenter if that user
# exits.
#############################################################################
require 'etc'

begin
  u = Etc.getpwnam('opscenter')
  puts u.name + '_uid=' + u.uid.to_s
rescue
  nil
end
