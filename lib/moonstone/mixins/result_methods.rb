module Moonstone
  module Mixins
    
    module ResultMethods
      
      def score; @score; end
      def score=(val); @score = val; end
      
      def id; @doc_id; end
      def id=(val); @doc_id = val; end
      
      def tokens; @tokens; end
      def tokens=(val); @tokens = val; end
            
      def explanation; @explanation; end
      def explanation=(val); @explanation = val; end
            
      def self.included(klass)
        klass.module_eval do
          to_h = klass.instance_method(:to_hash)
          define_method(:to_hash) do
            to_h.bind(self).call.merge( { "id" => self.id, "score" => self.score } )
          end
        end
      end
    end
  end
end