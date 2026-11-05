# spec/support/matchers/redirect_to_slug_matcher.rb
RSpec::Matchers.define :redirect_to_slug_of do |event|
  match do |response|
    response.location.include?(event.slug_url) &&
      !response.location.match?(%r{/organizer/events/\d+$})
  end

  failure_message do |response|
    "expected redirect to include slug '#{event.slug_url}' " \
    "but location was '#{response.location}'"
  end
end