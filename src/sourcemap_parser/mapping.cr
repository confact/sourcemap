module SourceMap
  struct Mapping
    getter generated_line : Int32 = 0
    getter generated_column : Int32 = 0
    getter source_line : Int32 = 0
    getter source_column : Int32 = 0
    getter name : String?
    getter source_path : String?
    property source_content : String?

    # Using default values to reduce the number of initializers
    def initialize(
      @generated_line : Int32, 
      @generated_column : Int32,
      @source_path : String? = nil,
      @source_line : Int32 = 0,
      @source_column : Int32 = 0,
      @name : String? = nil
    )
    end

    def source_line_content : String?
      return nil if source_path.nil?
      return nil if source_content.nil?
      source_code_splitted[source_line - 1]?
    end

    def pre_context(context_line_no : Int32)
      content = source_code_splitted
      return nil if content.empty?
      start_no = [0, context_line_no - 4].max
      end_no = [content.size - 1, context_line_no - 1].min
      source_code(start_no, end_no)
    end

    def post_context(context_line_no : Int32)
      content = source_code_splitted
      return nil if content.empty?
      start_no = [0, context_line_no + 1].max
      end_no = [content.size - 1, context_line_no + 4].min
      source_code(start_no, end_no)
    end

    def context_line(context_line_no : Int32) : String?
      return nil if source_code_splitted.empty?
      source_code_splitted[context_line_no]?
    end

    def source_code(from : Int32, to : Int32)
      source_code_splitted[from..to]
    end

    def source_code_length : Int32
      source_code_splitted.size
    end

    def source_code_splitted : Array(String)
      @split_content ||= (@source_content || "").split("\n")
    end
  end
end
