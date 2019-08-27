CHECKLISTS_CONFIG_PATH = Rails.root.join('lib/checklists/')

CHECKLISTS_QUESTIONS = YAML.load_file(CHECKLISTS_CONFIG_PATH + "questions.yaml")['questions']
CHECKLISTS_CRITERIA = YAML.load_file(CHECKLISTS_CONFIG_PATH + "criteria.yaml")['criteria']
CHECKLISTS_ACTIONS = YAML.load_file(CHECKLISTS_CONFIG_PATH + "actions.yaml")['actions']
