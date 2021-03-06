# coding: UTF-8
class BookReference < UnmissingReference
  belongs_to :publisher
  validates_presence_of :publisher, :pagination
  attr_accessible :year, :publisher, :doi
end
