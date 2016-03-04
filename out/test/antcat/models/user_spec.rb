# coding: UTF-8
require 'spec_helper'
describe User do

  specify "A user is not necessarily an editor" do
    expect(User.new.is_editor?).not_to be_truthy
  end

  it "knows whether it can edit the catalog" do
    expect(User.new.can_edit).to be_falsey
    expect(User.new(can_edit: true).can_edit).to be_truthy
  end

  it "knows whether it can review changes" do
    expect(User.new.can_review_changes?).to be_falsey
    expect(User.new(can_edit: true).can_review_changes?).to be_truthy
  end

  it "knows whether it can approve changes" do
    expect(User.new.can_approve_changes?).to be_falsey
    expect(User.new(can_edit: true).can_approve_changes?).to be_truthy
  end

end