# coding: UTF-8
class ReferenceFormatterCache
  include Singleton

  def invalidate reference
    return unless reference.formatted_cache?
    set reference, nil unless reference.new_record?
    Reference.where("nesting_reference_id = ?", reference.id).each do |nestee|
      self.class.instance.invalidate nestee
    end
  end

  def get reference
    Reference.find(reference.id).formatted_cache
  end

  def set reference, value
    return value if reference.formatted_cache == value
    reference.update_column :formatted_cache, value
    value
  end

  def populate reference
    set reference, Formatters::ReferenceFormatter.format!(reference)
  end

end
