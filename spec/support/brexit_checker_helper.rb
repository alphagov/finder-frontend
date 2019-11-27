module BrexitCheckerHelper
  def answer_question(key, *options)
    question = BrexitChecker::Question.find_by_key(key)
    expect(page).to have_content(question.text)
    options.each { |o| find_field(o).click }
    click_on "Continue"
  end
end
