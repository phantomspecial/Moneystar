class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  enum kari_kasi: { karikata: 1, kasikata: 2 }
end
