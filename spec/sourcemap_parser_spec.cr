require "./spec_helper"

describe SourceMap::Parser do
  it "find mapping for error" do
    function = "t"
    line = 1
    column = 3697

    sourcemap_file = File.read("spec/support/fixtures/members-51db324e3c861052.js.map")

    sourcemap = SourceMap::Parser.from_string(sourcemap_file)

    mapping = sourcemap.mapping_for(line, column)

    mapping.should_not be_nil
    mapping.should be_a SourceMap::Mapping
    mapping.not_nil!.name.should eq("find")
    mapping.not_nil!.source_path.should eq("webpack://_N_E/./pages/[team_slug]/members.js")
    mapping.not_nil!.source_line.should eq(19)
    mapping.not_nil!.source_column.should eq(73)
    (mapping.not_nil!.source_content || "").should_not be_empty
    mapping.not_nil!.source_line_content.should eq("  const currentUserRole = members?.find(member => member.id === session?.user.id)?.role")
  end
end
