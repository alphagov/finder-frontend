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

  def validate(record)
    validate_citizen_group(record)
  end

private

  def validate_citizen_group(record)
    unless CITIZEN_KEYS.include?(record.key)
      record.errors[:key] << "is not included in the list"
    end
  end
end
