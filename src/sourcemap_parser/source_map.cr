require "json"
require "uri"

module SourceMap
  class Parser
    include JSON::Serializable

    property previous : Hash(String, Int32) = {} of String => Int32
    getter version : Int32
    getter sources : Array(String)
    getter names : Array(String)
    getter file : String

    @[JSON::Field(key: "sourcesContent")]
    getter sources_content : Array(String) = [] of String
    getter mappings : String

    @[JSON::Field(ignore: true)]
    getter parsed_mappings : Array(Mapping) = [] of Mapping

    @[JSON::Field(ignore: true)]
    property sourcemap_uri : URI = URI.parse("")

    def initialize(@version, @sources, @names, @file, @mappings)
      parse_mappings(mappings || "")
    end

    def after_initialize
      parse_mappings(mappings || "")
    end

    def self.from_file(file : String)
      from_json(File.read(file))
    end

    def self.from_string(string : String)
      raise "No empty string" if string.empty?
      from_json(string)
    end

    # All the numbers in SourceMaps are stored as differences from each other,
    # so we need to remove the difference every time we read a number.
    def undiff(int, type)
      if previous[type]?
        previous[type] += int
      else
        previous[type] = int
      end
      previous[type]
    end

    # Parse the mapping string from a SourceMap.
    #
    # The mappings string contains one comma-separated list of segments per line
    # in the output file, these lists are joined by semi-colons.
    #
    def parse_mappings(string) : Array(Mapping)
      previous = {} of String => Int32
      @mappings.split(";").each_with_index do |line, line_idx|
        previous["generated_col"] = 0
        line.split(",").each do |segment|
          next if segment.empty?
          parsed_mappings << parse_mapping(segment, line_idx + 1)
        end
      end
      parsed_mappings.sort_by! { |x| [x.generated_line, x.generated_column] }
    end

    # Parse an individual mapping.
    #
    # This is a list of variable-length-quanitity, with 1, 4 or 5 items. See the spec
    # https://docs.google.com/document/d/1U1RGAehQwRypUTovF1KRlpiOFze0b-_2gc6fAH0KY0k/edit
    # for more details.
    def parse_mapping(segment, line_num) : Mapping
      item = VLQ.decode(segment)

      unless [1, 4, 5].includes?(item.size)
        raise Exception.new("In map for #{file}:#{line_num}: unparseable item: #{segment}")
      end

      map = if item.size == 4
              Mapping.new(
                line_num,
                undiff(item[0], "generated_column"),
                sources[undiff(item[1], "source_id")],
                undiff(item[2], "source_line") + 1,
                undiff(item[3], "source_column")
              )
            elsif item.size == 5
              Mapping.new(
                line_num,
                undiff(item[0], "generated_column"),
                sources[undiff(item[1], "source_id")],
                undiff(item[2], "source_line") + 1,
                undiff(item[3], "source_column"),
                names[undiff(item[4], "name_id")]
              )
            else
              Mapping.new(line_num, undiff(item[0], "generated_column"))
            end

      if map.source_path
         map.source_content = source_content_for(map.source_path.not_nil!)
      end

      if map.generated_column < 0
        raise Exception.new("In map for #{file}:#{line_num}: unexpected generated_column: #{map.generated_column}")
      elsif map.source_line < 1
        raise Exception.new("In map for #{file}:#{line_num}: unexpected source_line: #{map.source_line}")
      elsif map.source_column < 0
        raise Exception.new("In map for #{file}:#{line_num}: unexpected source_column: #{map.source_column}")
      end

      map
    end

    def source_content_for(source_id : String) : String?
      return nil if sources_content.empty?
      return nil if source_index_for(source_id).nil?
      sources_content[source_index_for(source_id).not_nil!]?
    end

    def source_index_for(source_id : String) : Int32?
      sources.index(source_id)
    end
  end
end
