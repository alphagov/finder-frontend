require 'ripper'

class Checklists::CriteriaLogic
  def initialize(string, selected_options)
    @string = string.to_s.underscore
    @selected_options = selected_options.map(&:underscore)
  end

  def valid?
    tokens = Ripper.lex(string)
    return true if tokens.empty?

    tokens.all? do |(_, type, value, _)|
      next true unless type == :on_ident

      all_options.include?(value)
    end
  end

  def applies?
    return true if string.blank?

    eval(string, context) # rubocop:disable Security/Eval
  end

private

  attr_reader :string, :selected_options

  def all_options
    @all_options ||= Checklists::Criterion.load_all.map(&:key).map(&:underscore)
  end

  def context
    all_options_hash = all_options.each_with_object({}) do |key, hash|
      hash[key] = false
    end

    options_hash = selected_options.each_with_object(all_options_hash) do |key, hash|
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
