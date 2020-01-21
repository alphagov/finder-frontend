require "spec_helper"

describe Cid do
  describe "ineligible?" do
    it "Works as expected" do
      # TODO: Break this up!

      Eligibility.delete_all
      StudyRequirement.delete_all
      AgeRequirement.delete_all
      ResidencyRequirement.delete_all
      OrRequirementGroup.delete_all
      AndRequirementGroup.delete_all
      Cid.find_by(contentID: "f4b96a38-5247-4afd-b554-8a258a0e8c93").eligibilities.delete_all
      Cid.find_by(contentID: "33f9d8a1-2a3c-4b71-abda-b67b38bf0d67").eligibilities.delete_all

      eligibility = Eligibility.create
      content_page = Cid.find_by(contentID: "f4b96a38-5247-4afd-b554-8a258a0e8c93")
      content_page.eligibilities << eligibility

      base_requirement = AndRequirementGroup.create
      eligibility.requirement = base_requirement

      # be at least 16 and under 19 on 31 August 2019
      age_requirement = AgeRequirement.create(min_age: 16, max_age: 18)
      base_requirement.requirements << age_requirement

      # study at a publicly funded school or college, or be on an unpaid training course
      study_requirement = OrRequirementGroup.create
      base_requirement.requirements << study_requirement
      publicly_funded_school_requirement = StudyRequirement.create(at_publicly_funded_school: true)
      publicly_funded_college_requirement = StudyRequirement.create(at_publicly_funded_college: true)
      on_unpaid_training_course_requirement = StudyRequirement.create(on_unpaid_training_course: true)
      study_requirement.requirements += [publicly_funded_school_requirement, publicly_funded_college_requirement, on_unpaid_training_course_requirement]

      # meet the residency requirements
      residency_requirement = ResidencyRequirement.create(meet_residency_requirement: true)
      base_requirement.requirements << residency_requirement

      # Let's do some testing of the OrRequirement
      expect(study_requirement.ineligible?({})).to eql(false)
      expect(study_requirement.ineligible?(at_publicly_funded_school: true, at_publicly_funded_college: true, on_unpaid_training_course: true)).to eql(false)
      expect(study_requirement.ineligible?(at_publicly_funded_school: true, at_publicly_funded_college: true, on_unpaid_training_course: false)).to eql(false)
      expect(study_requirement.ineligible?(at_publicly_funded_school: true, at_publicly_funded_college: false, on_unpaid_training_course: false)).to eql(false)
      expect(study_requirement.ineligible?(at_publicly_funded_school: false, at_publicly_funded_college: false)).to eql(false)
      expect(study_requirement.ineligible?(at_publicly_funded_school: false)).to eql(false)
      expect(study_requirement.ineligible?(at_publicly_funded_college: false, on_unpaid_training_course: false)).to eql(false)
      expect(study_requirement.ineligible?(on_unpaid_training_course: false)).to eql(false)
      expect(study_requirement.ineligible?(at_publicly_funded_college: false)).to eql(false)
      # Someone is only ineligible if they are definitely not any of those things
      expect(study_requirement.ineligible?(at_publicly_funded_school: false, at_publicly_funded_college: false, on_unpaid_training_course: false)).to eql(true)

      # Let's do some testing of the AndRequirement
      expect(base_requirement.ineligible?({})).to eql(false)
      expect(base_requirement.ineligible?(age: 17, at_publicly_funded_school: true, meet_residency_requirement: true)).to eql(false)
      expect(base_requirement.ineligible?(age: 17, at_publicly_funded_school: false, at_publicly_funded_college: false, on_unpaid_training_course: false, meet_residency_requirement: true)).to eql(true)
      expect(base_requirement.ineligible?(age: 17, at_publicly_funded_school: true, meet_residency_requirement: false)).to eql(true)
      expect(base_requirement.ineligible?(age: 15, at_publicly_funded_school: true, meet_residency_requirement: true)).to eql(true)
      expect(base_requirement.ineligible?(age: 19, at_publicly_funded_school: true, meet_residency_requirement: true)).to eql(true)

      # Let's do some testing of the Eligibilty (which is actually the same as the last)
      expect(eligibility.ineligible?({})).to eql(false)
      expect(eligibility.ineligible?(age: 17, at_publicly_funded_school: true, meet_residency_requirement: true)).to eql(false)
      expect(eligibility.ineligible?(age: 17, at_publicly_funded_school: false, at_publicly_funded_college: false, on_unpaid_training_course: false, meet_residency_requirement: true)).to eql(true)
      expect(eligibility.ineligible?(age: 17, at_publicly_funded_school: true, meet_residency_requirement: false)).to eql(true)
      expect(eligibility.ineligible?(age: 15, at_publicly_funded_school: true, meet_residency_requirement: true)).to eql(true)
      expect(eligibility.ineligible?(age: 19, at_publicly_funded_school: true, meet_residency_requirement: true)).to eql(true)


      # Let's add another Cid with slightly different eligibility criteria
      jelly_cups_content_page = Cid.find_by(contentID: "33f9d8a1-2a3c-4b71-abda-b67b38bf0d67")
      jelly_cups_eligibility = Eligibility.create
      jelly_cups_content_page.eligibilities << jelly_cups_eligibility

      jelly_cups_base_requirement = AndRequirementGroup.create
      jelly_cups_eligibility.requirement = jelly_cups_base_requirement

      jelly_cups_age_requirement = AgeRequirement.create(min_age: 3, max_age: 17)
      jelly_cups_base_requirement.requirements << jelly_cups_age_requirement
      jelly_cups_publicly_funded_school_requirement = StudyRequirement.create(at_publicly_funded_school: true)
      jelly_cups_base_requirement.requirements << jelly_cups_publicly_funded_school_requirement

      # Let's do some testing of the Cid .where_not_ineligible method to see if it work with more than one
      assert_cid_where_not_ineligibile_equals({}, [content_page, jelly_cups_content_page])
      assert_cid_where_not_ineligibile_equals({ age: 17, at_publicly_funded_school: true, meet_residency_requirement: true }, [content_page, jelly_cups_content_page])
      assert_cid_where_not_ineligibile_equals({ age: 17, at_publicly_funded_school: false, at_publicly_funded_college: false, on_unpaid_training_course: false, meet_residency_requirement: true }, [])
      assert_cid_where_not_ineligibile_equals({ age: 17, at_publicly_funded_school: true, meet_residency_requirement: false }, [jelly_cups_content_page])
      assert_cid_where_not_ineligibile_equals({ age: 17, at_publicly_funded_school: true, meet_residency_requirement: true }, [content_page, jelly_cups_content_page])
      assert_cid_where_not_ineligibile_equals({ age: 10, at_publicly_funded_school: true, meet_residency_requirement: true }, [jelly_cups_content_page])
      assert_cid_where_not_ineligibile_equals({ age: 19, at_publicly_funded_school: true, meet_residency_requirement: true }, [])
      assert_cid_where_not_ineligibile_equals({ age: 2, at_publicly_funded_school: true, meet_residency_requirement: true }, [])
    end
  end
end

def assert_cid_where_not_ineligibile_equals(attributes, expected)
  results = Cid.where_not_ineligible(attributes)
  expected.map { |expect| expect(results.include?(expect)).to eql(true) }
  expect(results.count).to eq(expected.count)
end
