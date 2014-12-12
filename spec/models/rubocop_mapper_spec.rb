require "fast_spec_helper"
require "app/models/rubocop_mapper"

describe RuboCopMapper do
  describe "#convert" do
    it "parses a single style guide config rules into RuboCop configs" do
      hound_rules = {
        line_length: { value: 80 }
      }
      expected_rubocop_configs = {
        "LineLength" => {
          "Max" => 80
        }
      }
      mapper = RuboCopMapper.new(hound_rules)

      rubocop_configs = mapper.convert

      expect(rubocop_configs).to eq expected_rubocop_configs
    end

    it "parses multiple style guide config rules into RuboCop configs" do
      hound_rules = {
        line_length: { value: 80 },
        string_literals: { value: "single_quotes" },
        hash_syntax: { value: "hash_rockets" }, # where did we end on this?
        ignore_paths: { value: ["vendor/**/*", "lib/assets/**/*"] }
      }
      expected_rubocop_configs = {
        "LineLength" => {
          "Max" => 80
        },
        "StringLiterals" => {
          "EnforcedStyle" => "single_quotes"
        },
        "HashSyntax" => {
          "EnforcedStyle" => "hash_rockets"
        },
        "AllCops" => {
          "Exclude" => ["vendor/**/*", "lib/assets/**/*"]
        }
      }
      mapper = RuboCopMapper.new(hound_rules)

      rubocop_configs = mapper.convert

      expect(rubocop_configs).to eq expected_rubocop_configs
    end
  end
end
