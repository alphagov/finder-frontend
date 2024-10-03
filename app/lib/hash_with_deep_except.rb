module HashWithDeepExcept
  refine Hash do
    # Allows removing arbitarily nested params from a hash, used for clearing specific filters from
    # a user's search.
    #
    # For example, given:
    #   { a: 1, b: { c: 2, d: 3 } }
    # Removing
    #   { b: { c: 2 } }
    # would result in
    #   { a: 1, b: { d: 3 } }
    def deep_except(other)
      each_with_object({}) do |(key, value), result|
        if other.key?(key)
          child = other[key]

          if value.is_a?(Hash) && child.is_a?(Hash)
            # Recursively remove nested values
            nested_result = value.deep_except(child)
            result[key] = nested_result unless nested_result.empty?
          elsif value.is_a?(Array) && child.is_a?(Array)
            result[key] = value - child
          elsif child.is_a?(Array) && child == [value]
            # Some parameters can be given both as an array and a single value (e.g. `organisation`),
            # and should be removed if a single value is present that's equal to the only array
            # element
            #
            # Skip this key-value pair, effectively removing it
          elsif value != child
            result[key] = value
          end
        else
          result[key] = value
        end
      end
    end
  end
end
