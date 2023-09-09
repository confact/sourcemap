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

    def undiff(int, type)
      previous[type] = (previous[type]? || 0) + int
    end

    def parse_mappings(string) : Array(Mapping)
      previous.clear
      string.split(";").each_with_index do |line, line_idx|
        previous["generated_col"] = 0
        line.split(",").each do |segment|
          next if segment.empty?
          parsed_mappings << parse_mapping(segment, line_idx + 1)
        end
      end
      parsed_mappings.sort_by! { |x| [x.generated_line, x.generated_column] }
    end

    def parse_mapping(segment, line_num) : Mapping
      item = VLQ.decode(segment)

      unless [1, 4, 5].includes?(item.size)
        raise Exception.new("In map for #{file}:#{line_num}: unparseable item: #{segment}")
      end

      case item.size
      when 4
        source_idx = undiff(item[1], "source_id")
        map = Mapping.new(
          line_num,
          undiff(item[0], "generated_column"),
          sources[source_idx],
          undiff(item[2], "source_line") + 1,
          undiff(item[3], "source_column")
        )
      when 5
        source_idx = undiff(item[1], "source_id")
        name_idx = undiff(item[4], "name_id")
        map = Mapping.new(
          line_num,
          undiff(item[0], "generated_column"),
          sources[source_idx],
          undiff(item[2], "source_line") + 1,
          undiff(item[3], "source_column"),
          names[name_idx]
        )
      else
        map = Mapping.new(line_num, undiff(item[0], "generated_column"))
      end

      if map.source_path
         map.source_content = source_content_for(map.source_path.not_nil!)
      end

      raise Exception.new("In map for #{file}:#{line_num}: unexpected generated_column: #{map.generated_column}") if map.generated_column < 0
      raise Exception.new("In map for #{file}:#{line_num}: unexpected source_line: #{map.source_line}") if map.source_line < 1
      raise Exception.new("In map for #{file}:#{line_num}: unexpected source_column: #{map.source_column}") if map.source_column < 0

      map
    end

    # Retrieve a Mapping for a specific line and column in the generated code
    def mapping_for(generated_line : Int32, generated_column : Int32) : Mapping?
      parsed_mappings.find do |mapping|
        mapping.generated_line == generated_line && mapping.generated_column == generated_column
      end
    end

    # Retrieve a mapping for a specific line in the generated code and with source_path
    def mapping_with_source_path_for(generated_line : Int32, source_path : String) : Mapping?
      parsed_mappings.find do |mapping|
        next if mapping.source_path.blank?
        mapping.generated_line == generated_line && mapping.generated_column == generated_column
      end
    end

    def mapping_with_less_column_for(generated_line : Int32, generated_column : Int32?, start_column : Int32 = 1) : Mapping?
      mapping_with_source_path_for(generated_line, (generated_column || start_column) - 1)
    end

    # Retrieve all mappings for a specific source path
    def mappings_for_source(source_path : String) : Array(Mapping)
      parsed_mappings.select { |mapping| mapping.source_path == source_path }
    end

    private def source_content_for(source_id : String) : String?
      idx = source_index_for(source_id)
      idx ? sources_content[idx] : nil
    end

    private def source_index_for(source_id : String) : Int32?
      sources.index(source_id)
    end
  end
end

