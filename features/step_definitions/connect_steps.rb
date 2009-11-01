Then /^I should see the profile of "([^\"]*)"$/ do |name|
  profile = Profile.find_by_first_name(name)
  response.should contain(profile.full_name)
end

Then /^I should not see the profile of "([^\"]*)"$/ do |name|
  profile = Profile.find_by_first_name(name)
  response.should_not contain(profile.full_name)
end

When /^I follow the "([^\"]*)" link for the profile of "([^\"]*)"$/ do |link, user|
  profile = Profile.find_by_first_name(user)
  within("#profile_#{profile.id}") do
    click_link "#{link.downcase!}_link"
  end  
end

Then /^I should see the profile details of "([^\"]*)"$/ do |user|
  profile = Profile.find_by_first_name(user)
  #within("#profile_details_container") do |content|
    response.should contain(profile.motivation)
  #end
end

