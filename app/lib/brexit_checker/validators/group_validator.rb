class BrexitChecker::Validators::GroupValidator < ActiveModel::Validator
  CITIZEN_KEYS = %w[ visiting-eu
                     visiting-uk
                     visiting-ie
                     living-eu
                     living-ie
                     living-uk
                     working-uk
                     studying-eu
                     studying-uk
                     common-travel-area ].freeze

  BUSINESS_KEYS = %w[ placeholder-grouping-1
                      placeholder-grouping-2
                      placeholder-grouping-3
                      placeholder-grouping-4
                      placeholder-grouping-5
                      placeholder-grouping-6
                      placeholder-grouping-7
                      placeholder-grouping-8].freeze

  def validate(record)
    if record.audience.nil?
      record.errors[:audience] << "can't be blank"
    else
      validate_keys(record)
    end
  end

private

  def keys
    { "citizen" => CITIZEN_KEYS, "business" => BUSINESS_KEYS }
  end

  def validate_keys(record)
    unless keys[record.audience].include?(record.key)
      record.errors[:key] << "is not included in the list"
    end
  end
end
