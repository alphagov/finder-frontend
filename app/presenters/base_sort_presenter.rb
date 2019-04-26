class BaseSortPresenter
  def has_options?
    raise NotImplementedError
  end

  def to_hash
    raise NotImplementedError
  end

  def default_option
    raise NotImplementedError
  end

  def default_value
    raise NotImplementedError
  end

  def selected_option
    raise NotImplementedError
  end
end
