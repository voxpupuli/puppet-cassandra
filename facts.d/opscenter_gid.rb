#!/usr/bin/env ruby
#############################################################################
# A custom fact to return the gid of a user called opscenter if that user
# exits.
#############################################################################
require 'etc'

begin
  u = Etc.getpwnam('opscenter')
  puts u.name + '_gid=' + u.gid.to_s
rescue
  nil
end
