class Analysis < ApplicationRecord
  belongs_to :activity, touch: true

  broadcasts_refreshes_to :activity
end
