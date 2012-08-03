$: << File.expand_path(File.dirname(__FILE__) + '/lib')

STDOUT.sync = true

require 'vroom'
run Vroom
