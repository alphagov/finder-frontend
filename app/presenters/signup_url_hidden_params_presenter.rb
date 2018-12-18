class SignupUrlHiddenParamsPresenter
  def initialize(content_item, view_context)
    @content_item = content_item
    @view_context = view_context
  end

  def hidden_params
    @hidden_params ||= clean_filtered_params
  end

private

  attr_reader :content_item, :view_context

  def clean_filtered_params
    @clean_filtered_params ||= begin
      ParamsCleaner
        .new(filtered_params)
        .cleaned
        .delete_if { |_, value| value.blank? }
    end
  end

  def filtered_params
    facet_choices = content_item['details'].fetch('email_filter_facets', []).reject { |facet| facet.key?('facet_choices') }
    params = view_context.params.to_unsafe_hash
    filtered_params = Hash.new { |hash, key| hash[key] = []; }
    facet_choices.each do |facet_choice|
      key = facet_choice['facet_name']
      if params.key?(key) && params[key].present?
        translated_filter_key = facet_choice['filter_key'] || key
        value = params[key]
        operator = value.is_a?(Array) ? 'concat' : '<<'
        filtered_params[translated_filter_key].public_send(operator, value)
      end
    end
    filtered_params
  end
end
