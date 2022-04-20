# frozen_string_literal: true

require 'rails_helper'
require 'fitbit/response'

RSpec.describe DhpConnectedDevices::Fitbit::Response do
  describe 'response' do
    it 'has a status code' do
      body_string = JSON.generate({ body: "body" })
      response = DhpConnectedDevices::Fitbit::Response.new({status: 200, body: body_string})
      expect(response.status).to eq(200)
    end

    it 'has a response body when given body' do
      body_string = JSON.generate({ body: "body" })
      response = DhpConnectedDevices::Fitbit::Response.new(
        {
          status: 200,
          body: body_string})
      expect(response.body).to eq(body_string)
    end

    it 'has a response data when given data in body' do
      body_string = JSON.generate({ data: "data" })
      response = DhpConnectedDevices::Fitbit::Response.new(
        {
          status: 200,
          body: body_string})
      expect(response.data).to eq("data")
    end

    it 'response data is empty if body is empty' do
      body_string = JSON.generate({data: {}})
      response = DhpConnectedDevices::Fitbit::Response.new(
        {
          status: 200,
          body: body_string})
      expect(response.data).to eq({})
    end
  end
end