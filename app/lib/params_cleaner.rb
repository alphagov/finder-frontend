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
#
# The query parameters sometimes include 'q' and sometimes 'keywords'.
# This change standardises them to use 'keywords' consistently.
#

class ParamsCleaner
  def self.call(params)
    result_params = params.except(:controller, :action, :slug, :format)
    if result_params.key?("q")
      result_params["keywords"] = result_params.delete("q")
    end

    result_params.transform_values! { cleanup_value(_1) }
    result_params.reject! { |_, value| value.blank? }
    result_params.to_unsafe_hash.with_indifferent_access
  end

  def self.cleanup_value(value)
    return value.strip if value.is_a?(String)

    return value.map { |element| element.try(:strip) || element } if value.is_a? Array

    if value.respond_to?(:keys) && value.keys.all? { |d| d.match(/\A\d+\Z/) }
      return value.values
    end

    value
  end
end
