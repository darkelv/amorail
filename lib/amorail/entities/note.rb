# frozen_string_literal: true

require 'amorail/entities/elementable'

module Amorail
  # AmoCRM note entity
  class Note < Amorail::Entity
    include Elementable

    amo_names 'notes'

    amo_field :note_type, :text

    validates :note_type, :text,
              presence: true

    validates :element_type, inclusion: ELEMENT_TYPES.values
  end
end
