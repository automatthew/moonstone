module Moonstone
  class Filter < Lucene::Analysis::TokenFilter
    
    def initialize(stream)
      if block_given?
        self.class.module_eval do
          define_method :process do |token|
            yield token
          end
        end
      end
      super
      @stream = stream
    end
    
    def next(token=nil)
      if token = (token ? @stream.next(token) : @stream.next)
        text = process(token.term_text)
        # skip a token if its text is empty
        if text.empty?
          token = self.next(token)
        else
          token.term_text = text
          token
        end
      end
    end
    
  end
end
