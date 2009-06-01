module Lucene
  module Analysis
    include_package "org.apache.lucene.analysis"
    
    module Standard
      include_package "org.apache.lucene.analysis.standard"
      [
        StandardAnalyzer,
        StandardFilter,
        StandardTokenizer,
      ]
    end
    include Standard
    
    TokenStream.module_eval do
      include Enumerable
      def each
        token = Token.new
        while token = self.next(token) do
          yield token
        end
      end
    end
    
    Analyzer.module_eval do
      def tokenize(field, text)
        token_stream(field, java.io.StringReader.new(text)).map { |token| token.term_text }
      end
    end
    
    # Biggie Smalls, Biggie Smalls, Biggie Smalls
    [ 
      CachingTokenFilter,
      CharTokenizer,
      ISOLatin1AccentFilter,
      KeywordAnalyzer,
      KeywordTokenizer,
      LengthFilter,
      LetterTokenizer,
      LowerCaseFilter,
      LowerCaseTokenizer,
      PerFieldAnalyzerWrapper,
      PorterStemFilter,
      PorterStemmer,
      SimpleAnalyzer,
      SinkTokenizer,
      StopAnalyzer,
      StopFilter,
      TeeTokenFilter,
      Token,
      TokenFilter,
      Tokenizer,
      WhitespaceAnalyzer,
      WhitespaceTokenizer,
      WordlistLoader
      ]
  end
end