module Lucene
  module Index
    include_package "org.apache.lucene.index"
    
    IndexWriter.module_eval do
      MaxFieldLength = self::MaxFieldLength
      
      def self.open(*args)
        args << MaxFieldLength::UNLIMITED unless args.include? MaxFieldLength
        writer = new(*args)
        begin
          result = yield(writer)
        ensure
          writer.close
        end
        result
      end
      
      def add_documents(docs)
        docs.each { |doc| add_document(doc) }
      end
      
      
    end
    
    TermEnum.module_eval do
      include Enumerable
      
      def each
        while self.next do
          yield term
        end
      end
      
      def for_field(field_name)
        select { |t| t.field == field_name }.map { |t| t.text }
      end
      
    end
    
    # Mention classes so they can be referenced elsewhere
    [
      IndexReader,
      Payload,
      Term,
      ]
  end
end