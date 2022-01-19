# frozen_string_literal: true

class FooController < ApplicationController
  skip_before_action :authenticate
  skip_before_action :verify_authenticity_token

  def index
    render json: { bar: 'example' }
  end
end
