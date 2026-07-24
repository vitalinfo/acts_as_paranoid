# frozen_string_literal: true

require "test_helper"

class DependentDestroyTest < ActiveSupport::TestCase
  class ParanoidPolymorphicOwner < ActiveRecord::Base
    acts_as_paranoid
    belongs_to :owned, polymorphic: true, dependent: :destroy, optional: true
  end

  def setup
    ActiveRecord::Schema.define(version: 1) do
      create_table :paranoid_polymorphic_owners do |t|
        t.string   :owned_type
        t.integer  :owned_id
        t.datetime :deleted_at

        timestamps t
      end
    end
  end

  def teardown
    teardown_db
  end

  # A polymorphic `belongs_to ..., dependent: :destroy` with no target resolves to
  # a nil klass. `destroy_dependent_associations!` must skip it rather than call
  # `.paranoid?` on nil, mirroring the guard in `recover_dependent_association`.
  def test_destroy_fully_with_nil_polymorphic_dependent_association
    owner = ParanoidPolymorphicOwner.create!

    assert_nil owner.owned

    assert_nothing_raised { owner.destroy_fully! }
    assert_equal 0, ParanoidPolymorphicOwner.count
  end
end
