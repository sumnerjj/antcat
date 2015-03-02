# coding: UTF-8
require_relative '../../lib/workflow_external_table'
class Taxon < ActiveRecord::Base
  include Workflow
  include Workflow::ExternalTable
  has_one :taxon_state


  workflow do
    state :old
    state :waiting do
      event :approve, transitions_to: :approved
    end
    state :approved
  end

  delegate :approver, :approved_at, to: :last_change

  #
  #


  def can_be_edited_by? user
    return false unless $Milieu.user_can_edit?(user)
    return true if old?
    return true if approved?
    raise unless waiting?
    true
  end

  def can_be_reviewed_by? user
    $Milieu.user_can_review_changes?(user) && waiting?
  end

  def can_be_approved_by? change_id, user
    user != added_by(change_id) && waiting? && $Milieu.user_can_approve_changes?(user)
  end

  # Returns the ID of the most recent change that touches this taxon.
  # Query that looks at all transactions and picks the latest one that has this
  # change ID.
  def last_change change_id
    Change.joins(:paper_trail_versions).where('versions.item_id = ? AND versions.item_type = ? AND changes.id = ?', id, 'Taxon', change_id).last
  end

  # Returns the ID of the most recent change that touches this taxon.
  # Query that looks at all transactions and picks the latest one
  def latest_change
    Change.joins(:paper_trail_versions).where('versions.item_id = ? AND versions.item_type = ?', id, 'Taxon').last
  end

  def last_version
    # it seems to be necessary to reload the association and get its last element
    versions(true).last
  end

  def added_by change_id
    puts "joe: Loading change id: " + change_id.to_s
    last_change(change_id).user
  end

end
