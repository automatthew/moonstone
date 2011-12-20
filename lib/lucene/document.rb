module Lucene
  module Document
    include_package "org.apache.lucene.document"

    # avoid naming problems with Lucene::Document::Document
    Doc = Lucene::Document::Document

    # I spit on final class
    Doc.module_eval do
      attr_accessor :score, :id, :tokens, :explanation

      self::Field = Lucene::Document::Field

      @@field_store = {
        nil => Field::Store::YES,
        false => Field::Store::NO,
        :NO => Field::Store::NO,
        :no => Field::Store::NO,
        true => Field::Store::YES,
        :YES => Field::Store::YES,
        :yes => Field::Store::YES,
        :compress => Field::Store::COMPRESS,
        :COMPRESS => Field::Store::COMPRESS
      }
      @@field_index = {
        nil => Field::Index::ANALYZED,
        false => Field::Index::NO,
        :NO => Field::Index::NO,
        :no => Field::Index::NO,
        true => Field::Index::ANALYZED,
        :analyzed => Field::Index::ANALYZED,
        :ANALYZED => Field::Index::ANALYZED,
        :not_analyzed => Field::Index::NOT_ANALYZED,
        :NOT_ANALYZED => Field::Index::NOT_ANALYZED,
        :analyzed_no_norms => Field::Index::ANALYZED_NO_NORMS,
        :ANALYZED_NO_NORMS => Field::Index::ANALYZED_NO_NORMS,
        :not_analyzed_no_norms => Field::Index::NOT_ANALYZED_NO_NORMS,
        :NOT_ANALYZED_NO_NORMS => Field::Index::NOT_ANALYZED_NO_NORMS
      }

      @@field_term_vector = {
        nil => Field::TermVector::NO,
        :NO => Field::TermVector::NO,
        :no => Field::TermVector::NO,
        false => Field::TermVector::NO,
        :YES => Field::TermVector::YES,
        :yes => Field::TermVector::YES,
        true => Field::TermVector::YES,
        :WITH_POSITIONS => Field::TermVector::WITH_POSITIONS,
        :with_positions => Field::TermVector::WITH_POSITIONS,
        :WITH_OFFSETS => Field::TermVector::WITH_OFFSETS,
        :with_offsets => Field::TermVector::WITH_OFFSETS,
        :WITH_POSITIONS_OFFSETS => Field::TermVector::WITH_POSITIONS_OFFSETS,
        :with_positions_offsets => Field::TermVector::WITH_POSITIONS_OFFSETS
      }

      def self.new
        doc = super()
        yield doc if block_given?
        doc
      end

      def self.create(fields)
        doc = self.new
        fields.each { |field| doc.add_field(*field) }
        doc
      end

      def add_field(name, value, options={})
        field = if value.is_a? java.io.Reader
          Field.new(name, value, @@field_term_vector[options[:term_vector]])
        else
          store = @@field_store[options[:store]]
          index = @@field_index[options[:index]]
          term_vector = @@field_term_vector[options[:term_vector]]
          params = [name, value, store, index]
          params << term_vector if term_vector
          Field.new(*params)
        end
        add(field)
      end

      # specialty field adders
      def stored(name, value)
        add_field(name, value, :store => true, :index => false)
      end

      def analyzed(name, value)
        add_field(name, value, :store => true, :index => :tokenized)
      end

      def unanalyzed(name, value)
        add_field(name, value, :store => true, :index => :not_analyzed)
      end

      alias_method :[], :get

      def get_all(field_name)
        fields.select { |f| f.name == field_name }.map { |f| f.string_value }
      end

      def field_names
        fields.map { |f| f.name }.uniq
      end

      alias_method :keys, :field_names

      def to_hash
        hash = {}
        hash["id"] = @id if @id
        hash["score"] = @score if @score
        hash["explanation"] = @explanation.toString(1) if @explanation
        fields = {}
        hash["fields"] = fields
        keys.each do|k|
          values = self.get_all(k)
          # fields[k] = values.size == 1 ? values.first : values
          fields[k] = values
        end
        hash["tokens"] = @tokens if @tokens
        hash
      end

      def to_json
        to_hash.to_json
      end

    end

    Field.module_eval do

      alias_method :stored?, :is_stored
      alias_method :indexed?, :is_indexed
      alias_method :tokenized?, :is_tokenized
      alias_method :analyzed?, :is_tokenized
      alias_method :compressed?, :is_compressed

      def unanalyzed?; indexed? && !analyzed?; end
      def unindexed?; stored? && !indexed?; end

    end

    # Biggie Smalls, Biggie Smalls, Biggie Smalls
    [
      DateField,
      DateTools
      ]
  end
end
