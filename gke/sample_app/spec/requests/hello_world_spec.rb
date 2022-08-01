require 'rails_helper'

RSpec.describe "HelloWorlds", type: :request do
  describe "GET /hello_worlds" do
    it "is Http Status OK with correct request" do
      get "/hello_worlds"
      expect(response).to have_http_status 200
    end

    it "is valid with a sentence, Hello World" do
      get "/hello_worlds"
      expect(response.body).to include("Hello World")
    end
  end
end
