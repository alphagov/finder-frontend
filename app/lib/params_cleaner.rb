# In some cases requests come in to this app with a mangled query string in
# this form:
#
#   foo[0]=bar&foo[1]=baz
#
# Which translates in Rails as:
#
#   foo: { 0: "bar", 1: "baz" }
#
# While we want:
#
#   foo: ["bar", "baz"]
#
# We also sometimes get parameters with leading or trailing whitespace
# in facet values (trailing whitespace in the last facet is common for
# the business readiness finder), strip those so that searches work.
#
class ParamsCleaner
  attr_reader :cleaned

  def initialize(params)
    @cleaned = cleanup(params)
  end

  def fetch(key, default)
    value = cleaned[key]
    value.is_a?(default.class) ? value : default
  end

private

  def cleanup(params)
    param_pairs = params.to_unsafe_hash
      .map { |k, v| [k, cleanup_value(v)] }

    Hash[param_pairs]
      .delete_if { |_, value| value.blank? }
      .with_indifferent_access
  end

  def cleanup_value(value)
    return value.strip if value.is_a?(String)

    if value.is_a? Array
      return value.map { |x| x.is_a?(String) ? x.strip : x }
    end

    if value.respond_to?(:keys) && value.keys.all? { |d| d.match(/\A\d+\Z/) }
      return value.values
    end

    value
  end
end
