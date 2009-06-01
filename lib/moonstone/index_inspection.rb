#Methods to assist in index analysis
module Moonstone
  class Engine
    
    #Return a hash of tokens, keyed on field name, for the given doc.
    # Doc can be either a Document, or the integer document id.
    # Note that if it is a Document, doc.id cannot be nil
    def tokens_for_doc(doc, fields = nil)
      tokens = {}
      self.reader do |reader|
        unless doc.kind_of?(Lucene::Document::Doc)
          doc_id = doc
          doc = reader.document(doc)
          doc.id = doc_id
        end
        fields = doc.keys if fields.nil?
        fields.each do |field|
          tokens[field] = []
          tfv = reader.getTermFreqVector(doc.id, field)
          if tfv && tfv.size > 0 && tfv.respond_to?(:getTermPositions)
            tv = tfv.getTerms
            tv.length.times do |i|
              positions = tfv.getTermPositions(i) || []
              positions.each { |pos| tokens[field][pos] = tv[i]}
            end
          end 
        end
      end
      tokens
    end
    
    #Helper, delegates to tokens_for_doc
    def tokens_for_field(doc, field)
      tokens_for_doc(doc, [field])[field]
    end
                
  end
end