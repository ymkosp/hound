class RuboCopMapper
  def initialize(rules)
    @rules = rules
  end

  def convert
    rules.each_with_object({}) do |(rule_name, chosen_options), converted_rules|
      converted_rules[convert_key(rule_name)] = {
        rule_key_for(rule_name) => chosen_options[:value]
      }
    end
  end

  private

  attr_reader :rules

  def convert_key(name)
    rule_mapping[name][:name]
  end

  def rule_key_for(name)
    rule_mapping[name][:value]
  end

  def rule_mapping
    {
      line_length: { name: "LineLength", value: "Max" },
      string_literals: { name: "StringLiterals", value: "EnforcedStyle" },
      hash_syntax: { name: "HashSyntax", value: "EnforcedStyle" },
      ignore_paths: { name: "AllCops", value: "Exclude"}
    }
  end
end
