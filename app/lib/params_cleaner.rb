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
  def initialize(params)
    @params = params
  end

  def cleaned
    @params.each do |k, v|
      if v.is_a?(String)
        @params[k] = v.strip
      elsif v.is_a?(Array)
        @params[k] = v.map { |x| x.is_a?(String) ? x.strip : x }
      elsif v.is_a?(Hash) && v.keys.all? { |d| d.match(/\A\d+\Z/) }
        @params[k] = v.values
      end
    end

    @params
  end
end
