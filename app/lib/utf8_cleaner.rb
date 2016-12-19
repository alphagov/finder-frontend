# In some cases requests come in to this app with invalid UTF-8 characters
# in the query string, for example:
#
#   keywords=%c0%2e%c0%2e
#
# We want to clean up these strings to remove the invalid characters
class UTF8Cleaner
  def initialize(string_to_be_cleaned)
    @string_to_be_cleaned = string_to_be_cleaned
  end

  def cleaned
    return unless @string_to_be_cleaned

    # Doesn't actually do any conversion but removes invalid characters
    @string_to_be_cleaned.encode(
      'UTF-8',
      'UTF-8',
      invalid: :replace,
      undef: :replace,
      replace: ''
    ).presence
  end
end
