class HiddenFacet < FilterableFacet
  def sentence_fragment
    return nil unless value
    { 'values' => [value] }
  end
end
