# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

require 'minitest/autorun'
require 'rack/test'
require_relative '../email_server'

class EmailServerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_health_check
    get '/health'
    assert_equal 200, last_response.status
  end

  def test_send_order_confirmation_missing_params
    post '/send_order_confirmation'
    assert_equal 400, last_response.status
  end

  def test_send_order_confirmation_with_valid_params
    params = {
      'email' => 'test@example.com',
      'order' => {
        'order_id' => '12345',
        'shipping_address' => {
          'street' => '123 Test St',
          'city' => 'Test City',
          'state' => 'TS',
          'country' => 'Test Country',
          'zip_code' => '12345'
        },
        'items' => [
          {
            'item' => {
              'product_id' => 'product1',
              'quantity' => 1
            },
            'cost' => {
              'currency_code' => 'USD',
              'units' => 10,
              'nanos' => 0
            }
          }
        ]
      }
    }

    post '/send_order_confirmation', params.to_json, 'CONTENT_TYPE' => 'application/json'
    assert_equal 200, last_response.status
  end
end