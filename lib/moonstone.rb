require 'java'
require 'logger'
require 'json'

$:.unshift(here = File.dirname(__FILE__))

Dir["#{here}/jar/*.jar"].each { |jar| require jar }
require 'lucene/analysis'
require 'lucene/document'
require 'lucene/function'
require 'lucene/index'
require 'lucene/query_parser'
require 'lucene/search'
require 'lucene/search/top_docs'
require 'lucene/store'

require 'moonstone/engine'
require 'moonstone/tokenizer'
require 'moonstone/filter'
require 'moonstone/queued_filter'
require 'moonstone/analyzer'
require 'moonstone/multi_analyzer'
require 'moonstone/index_inspection'

require 'moonstone/filters/synonymer.rb'

require 'moonstone/racker'

Moonstone::Logger = Logger.new($stderr) unless defined? Moonstone::Logger
