require 'ripper'

class Checklists::CriteriaLogic
  def initialize(string, selected_options)
    @string = string.to_s.underscore
    @selected_options = selected_options.map(&:underscore)
  end

  def valid?
    tokens = Ripper.lex(string)
    return true if tokens.empty?

    allowed_values = {
      on_ident: self.class.all_options,
      on_sp: [" "],
      on_op: %w(&& ||),
      on_lparen: ["("],
      on_rparen: [")"],
    }

    allowed_types = allowed_values.keys

    tokens.all? do |(_, type, value, _)|
      allowed_types.include?(type) && allowed_values[type].include?(value)
    end
  end

  def applies?
    return true if string.blank?

    eval(string, context) # rubocop:disable Security/Eval
  end

  def self.all_options
    @all_options ||= Checklists::Criterion.load_all.map(&:key_underscored)
  end

  def self.all_options_hash
    @all_options_hash ||= all_options.each_with_object({}) do |key, hash|
      hash[key] = false
    end
  end

private

  attr_reader :string, :selected_options

  def context
    options_hash = selected_options.each_with_object(self.class.all_options_hash.dup) do |key, hash|
      hash[key] = true
    end

    HashBinding.new(options_hash).context
  end

  class HashBinding
    def initialize(hash)
      hash.each do |key, value|
        singleton_class.send(:define_method, key) { value }
      end
    end

    def context
      binding
    end
  end
end
