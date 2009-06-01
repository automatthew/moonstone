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
require 'lucene/store'

require 'moonstone/engine'
require 'moonstone/tokenizer'
require 'moonstone/filter'
require 'moonstone/queued_filter'
require 'moonstone/analyzer'
require 'moonstone/multi_analyzer'
require 'moonstone/index_inspection'

require 'moonstone/mixins/result_methods.rb'
require 'moonstone/filters/synonymer.rb'

Moonstone::Logger = Logger.new($stderr) unless defined? Moonstone::Logger
Lucene::Document::Document.send(:include, Moonstone::Mixins::ResultMethods)
