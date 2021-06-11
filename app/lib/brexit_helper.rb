module BrexitHelper
  BREXIT_CHILD_TAXON_IDS = {
    business: "91cd6143-69d5-4f27-99ff-a52fb0d51c78",
    individuals: "6555e0bf-c270-4cf9-a0c5-d20b95fab7f1",
  }.freeze

  def brexit_child_taxon_description
    child_taxon_descriptions[document.content_id]
  end

private

  def child_taxon_descriptions
    {
      BREXIT_CHILD_TAXON_IDS[:business] => business_description,
      BREXIT_CHILD_TAXON_IDS[:individuals] => individuals_description,
    }
  end

  def business_description
    I18n.t("finders.brexit_child_taxons.business_description")
  end

  def individuals_description
    I18n.t("finders.brexit_child_taxons.individuals_description")
  end
end
