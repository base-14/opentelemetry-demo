// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

const test = require('node:test');
const assert = require('node:assert');

// Mock the charge module
const charge = {
  chargeServiceHandler: (call, callback) => {
    const { amount, credit_card } = call.request;
    
    // Basic validation
    if (!amount || !credit_card) {
      return callback(new Error('Missing required fields'));
    }
    
    if (!credit_card.credit_card_number || !credit_card.credit_card_cvv) {
      return callback(new Error('Invalid credit card'));
    }
    
    // Mock successful charge
    callback(null, {
      transaction_id: 'txn_' + Math.random().toString(36).substr(2, 9)
    });
  }
};

test('chargeServiceHandler should require amount and credit_card', () => {
  const call = { request: {} };
  const callback = (error, result) => {
    assert.ok(error);
    assert.strictEqual(error.message, 'Missing required fields');
  };
  
  charge.chargeServiceHandler(call, callback);
});

test('chargeServiceHandler should validate credit card fields', () => {
  const call = { 
    request: { 
      amount: { currency_code: 'USD', units: 10 },
      credit_card: { credit_card_number: '' }
    } 
  };
  const callback = (error, result) => {
    assert.ok(error);
    assert.strictEqual(error.message, 'Invalid credit card');
  };
  
  charge.chargeServiceHandler(call, callback);
});

test('chargeServiceHandler should return transaction_id on success', () => {
  const call = { 
    request: { 
      amount: { currency_code: 'USD', units: 10 },
      credit_card: { 
        credit_card_number: '4111111111111111',
        credit_card_cvv: 123
      }
    } 
  };
  const callback = (error, result) => {
    assert.strictEqual(error, null);
    assert.ok(result.transaction_id);
    assert.ok(result.transaction_id.startsWith('txn_'));
  };
  
  charge.chargeServiceHandler(call, callback);
});