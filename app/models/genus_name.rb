class GenusName < Name

  def self.get_name data
    data[:genus_name]
  end

  def self.make_attributes name, data
    html_name = "<i>#{name}</i>"
    {
      name:         name,
      html_name:    html_name,
      epithet:      name,
      html_epithet: html_name,
    }
  end

end
