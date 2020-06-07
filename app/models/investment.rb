class Investment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :investment, type: Integer
  field :shares, type: Integer
  field :name, type: String
end
