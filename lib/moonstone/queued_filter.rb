module Moonstone
  
  class QueuedFilter < Moonstone::Filter
    
    def initialize(stream)
      @buffer = []
      super
    end
    
    def read_buffer(token=nil)
      if item = @buffer.shift
        if item.is_a? String
          token ||= Lucene::Analysis::Token.new
          token.term_text = item
          token
        else
          raise "What have you done?"
        end
      end
    end
    
    def next(token=nil)
      if t = read_buffer(token)
        t
      elsif token = (token ? @stream.next(token) : @stream.next)
        results = process(token.term_text)
        if results.is_a? Array
          text = results.shift
          results.each { |t| @buffer << t }
        else
          text = results
        end
        # skip a token if its text is empty
        if text && text.empty?
          token = self.next(token)
        else
          token.term_text = text
          token
        end
      end
    end
    
  end
  
end
