module Moonstone
    
  module Filters
    
    class Synonymer < Moonstone::QueuedFilter
      
      def initialize(stream, synonym_hash)
        @synonym_hash = synonym_hash
        super(stream)
      end

      def process(text)
        if syns = @synonym_hash[text]
          if syns.is_a?(String)
            [text, syns]
          elsif syns.is_a?(Array)
            [text].concat syns
          end
        else
          text
        end
      end
      
    end
  end
end
