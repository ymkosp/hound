require "spec_helper"

feature "Landing page split testing" do
  scenario "user sees original landing page" do
    visit landing_page(:original)

    expect(page).to have_content(original_landing_page_content)
    # expect(segment).to have_received(landing_analytics_event(:original))
  end

  scenario "user sees a new landing page" do
    visit landing_page(:new)

    expect(page).to have_content(new_landing_page_content)
    # expect(segment).to have_received(landing_analytics_event(:new))
  end

  def landing_page(alternative)
    "/?landing_page=#{alternative}"
  end

  def original_landing_page_content
    "Review your JavaScript, CoffeeScript, and Ruby code for style guide violations with a trusty hound."
  end

  def new_landing_page_content
    "Hound catches style violations before they get merged"
  end
end
