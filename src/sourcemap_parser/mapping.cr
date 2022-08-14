module SourceMap
  struct Mapping
    getter generated_line : Int32 = 0
    getter generated_column : Int32 = 0
    getter source_line : Int32 = 0
    getter source_column : Int32 = 0
    getter name : String?
    getter source_path : String?
    property source_content : String?

    def initialize(generated_line, generated_column, source_path, source_line, source_column, name)
      @generated_line = generated_line
      @generated_column = generated_column
      @source_line = source_line
      @source_column = source_column
      @name = name
      @source_path = source_path
    end

    def initialize(generated_line, generated_column, source_path, source_line, source_column)
      @generated_line = generated_line
      @generated_column = generated_column
      @source_line = source_line
      @source_column = source_column
      @source_path = source_path
    end

    def initialize(generated_line, generated_column)
      @generated_line = generated_line
      @generated_column = generated_column
    end

    def pre_context(context_line_no : Int32)
      return nil if @source_content.nil?
      start_no = context_line_no - 4
      start_no = 0 if start_no < 0
      end_no = context_line_no - 1
      end_no = source_code_length - 1 if end_no > source_code_length - 1
      source_code(start_no, end_no)
    end

    def post_context(context_line_no : Int32)
      return nil if source_code_splitted.empty?
      start_no = context_line_no + 1
      start_no = 0 if start_no < 0
      end_no = context_line_no + 4
      end_no = source_code_length - 1 if end_no > source_code_length - 1
      source_code(start_no, end_no)
    end

    def context_line(context_line_no : Int32) : String?
      return nil if source_code_splitted.empty?
      source_code_splitted[context_line_no]
    end

    def source_code(from : Int32, to : Int32)
      return nil if source_code_splitted.empty?
      source_code_splitted[from..to]
    end

    def source_code_length
      return 0 if @source_content.nil?
      source_code_splitted.size
    end

    def source_code_splitted : Array(String)
      return [] of String if @source_content.nil?
      @source_content.not_nil!.split("\n")
    end
  end
end
