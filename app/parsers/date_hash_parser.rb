# Parses a hash of date parts as generated by the GOV.UK Publishing Components `date_input` into a
# Ruby `Date`.
#
# This parser is designed to be forgiving of partial inputs similar to the legacy
# `DateStringParser`. We're willing to accept most subsets of partial values:
#  - year, month, and day (obviously)
#  - year and month (assume from beginning of month)
#  - year only (assume from beginning of year)
#  - day and month only (assume from this date in current year)
#  - month only (assume from beginning of month in current year)
#
# For hashes that do not include any of day/month/year, subsets where we cannot make a reasonable
# assumption as to user intent (day given but no month), or values that fail to be parsed by `Date`
# (e.g. invalid dates or non-numeric values), returns `nil` to signify an invalid date (like
# `DateStringParser`).
class DateHashParser
  # Two digit years higher than this will be assumed to be 19xx, lower will be 20xx.
  MILLENNIUM_CUTOFF = 80

  def initialize(date_hash)
    @date_hash = date_hash
      .slice(:day, :month, :year)
      .compact_blank
      .transform_values(&:to_i)
  end

  def parse
    return if date_hash.empty? || any_non_positive_values? || day_without_month?

    Date.new(year, month, day)
  rescue Date::Error
    nil
  end

private

  attr_reader :date_hash

  def day_without_month?
    date_hash.key?(:day) && !date_hash.key?(:month)
  end

  def any_non_positive_values?
    # If the user enters a zero or negative value, or a string that `#to_i` converts to zero, we
    # consider the whole date invalid
    !date_hash.values.all?(&:positive?)
  end

  def day
    date_hash.fetch(:day, 1)
  end

  def month
    date_hash.fetch(:month, 1)
  end

  def year
    value = date_hash.fetch(:year, Date.current.year)

    case value
    when 0..MILLENNIUM_CUTOFF
      2000 + value
    when MILLENNIUM_CUTOFF..99
      1900 + value
    else
      value
    end
  end
end
