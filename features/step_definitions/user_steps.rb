# coding: UTF-8
Given /this user exists/ do |table|
  table.hashes.each {|hash| User.create! hash}
end

Given /^I fill in the email field with "([^"]+)"$/ do |string|
  step %{I fill in "user_email" with "#{string}"}
end

Given /^I fill in the email field with my email address$/ do
  user = User.find_by_name 'Mark Wilden'
  step %{I fill in "user_email" with "#{user.email}"}
end

Given /^I fill in the password field with "([^"]+)"$/ do |string|
  step %{I fill in "user_password" with "#{string}"}
end

Given /^I press "([^"]+)" to log in$/ do |string|
  step %{I press "#{string}"}
end

Given /^I press the first "([^"]+)" to log in$/ do |string|
  step %{I press the first "#{string}"}
end

Given 'I am not logged in' do
end

def login can_edit, use_web_interface = false, user_name = nil, is_superadmin = false
  user_name ||= 'Mark Wilden'
  user = User.find_by_name 'user_name'
  user.destroy if user
  step 'I go to the main page'
  attributes = {email: "mark@#{rand.to_s.gsub(/\D/, '')[1..5]}example.com"}
  attributes[:can_edit] = true if can_edit
  attributes[:is_superadmin] = true if is_superadmin
  attributes[:name] = user_name if user_name
  @user = FactoryGirl.create :user, attributes

  use_web_interface ? login_through_web_page : login_programmatically
end

def login_programmatically
  login_as @user
end

def login_through_web_page
  click_link "Login"
  step %{I fill in "user_email" with "#{@user.email}"}
  step %{I fill in "user_password" with "#{@user.password}"}
  step %{I press "Go" within "#login"}
end

Given /^I log in$/ do
  login true
end
Given /^I log in as a catalog editor(?: named "([^"]+)")?$/ do |editor|
  login true, false, editor
end

Given /^I log in as a superadmin(?: named "([^"]+)")?$/ do |editor|
  login true, false, editor, true
end

Given /^I log in as a bibliography editor$/ do
  login false
end
Given /^I log in through the web interface/ do
  login true, true
end

Given 'I log out' do
  step %{I follow "Logout"}
end

Given 'I am logged in' do
  step 'I log in'
end

Given /^there should be a mailto link to the email of "([^"]+)"$/ do |user_name|
  # Problems with this are caused by having @ or : in the target of the search
  #user_email = User.find_by_name(user_name).email
  #page.should have_css user_email
end
