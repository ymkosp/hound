class RuboCopMapper
  def initialize(rules)
    @rules = rules
  end

  def convert
    rules.each_with_object({}) do |(rule_name, chosen_options), converted_rules|
      if rule_name == :collection_methods
        rule_values = {
          collect: chosen_options[:value][:map],
          collect!: chosen_options[:value][:map] + "!",
          inject: chosen_options[:value][:reduce],
          detect: chosen_options[:value][:find],
          find_all: chosen_options[:value][:filter],
        }
      else
        rule_values = chosen_options[:value]
      end

      converted_rules[convert_key(rule_name)] = {
        rule_key_for(rule_name) => rule_values
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
      ignore_paths: { name: "AllCops", value: "Exclude"},
      collection_methods: { name: "CollectionMethods", value: "PreferredMethods" }
    }
  end
end
