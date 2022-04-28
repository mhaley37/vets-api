# frozen_string_literal: true

DhpConnectedDevices::Engine.routes.draw do
  get '/fitbit', to: 'fitbit#connect'
  get 'apidocs', to: 'apidocs#index'
  get '/fitbit-callback', to: 'fitbit#callback'
  get '/veteran-device-record', to: 'veteran_device_record#record'
end
