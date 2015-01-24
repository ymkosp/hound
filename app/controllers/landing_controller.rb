class LandingController < ApplicationController
  skip_before_action :authenticate, only: [:index]

  def index
    render ab_test("landing_page", "original", "new")
  end
end
