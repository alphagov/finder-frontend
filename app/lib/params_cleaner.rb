# typed: true
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
class ParamsCleaner
  def initialize(params)
    @params = params
  end

  def cleaned
    @params.each do |k, v|
      next unless v.is_a?(Hash) && v.keys.all? { |d| d.match(/\A\d+\Z/) }

      @params[k] = v.values
    end

    @params
  end
end
