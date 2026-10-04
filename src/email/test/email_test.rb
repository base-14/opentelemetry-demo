# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

# Sinatra only enforces host authorization outside the test environment;
# rack-test sends requests as example.org, which would otherwise get a 403.
ENV['RACK_ENV'] ||= 'test'

require 'minitest/autorun'
require 'minitest/mock'
require 'rack/test'
require_relative '../email_server'

class EmailServerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    app.set :raise_errors, false
    app.set :show_exceptions, false
  end

  def order_confirmation
    {
      'email' => 'customer@example.com',
      'order' => {
        'order_id' => 'order-123',
        'shipping_tracking_id' => 'track-456',
        'shipping_cost' => { 'currency_code' => 'USD', 'units' => 5, 'nanos' => 0 },
        'shipping_address' => shipping_address,
        'items' => [
          {
            'item' => { 'product_id' => 'PRODUCT1', 'quantity' => 2 },
            'cost' => { 'currency_code' => 'USD', 'units' => 10, 'nanos' => 0 }
          }
        ]
      }
    }
  end

  def shipping_address
    {
      'street_address_1' => '1 Test St',
      'street_address_2' => '',
      'city' => 'Test City',
      'country' => 'Testland',
      'zip_code' => '12345'
    }
  end

  def post_confirmation(body)
    sent = []
    Pony.stub(:mail, ->(mail) { sent << mail }) do
      post '/send_order_confirmation', body, 'CONTENT_TYPE' => 'application/json'
    end
    sent
  end

  def test_sends_confirmation_email_for_order
    sent = post_confirmation(order_confirmation.to_json)

    assert_equal 200, last_response.status
    assert_equal 1, sent.size
    assert_equal 'customer@example.com', sent.first[:to]
    assert_includes sent.first[:body], 'order-123'
    assert_includes sent.first[:body], 'PRODUCT1'
  end

  def test_rejects_malformed_json
    sent = post_confirmation('not json')

    assert_equal 500, last_response.status
    assert_empty sent
  end

  def test_rejects_request_without_order
    sent = post_confirmation({ 'email' => 'customer@example.com' }.to_json)

    assert_equal 500, last_response.status
    assert_empty sent
  end
end
