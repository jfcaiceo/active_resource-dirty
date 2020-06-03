require 'bundler/setup'
Bundler.setup

require 'minitest/autorun'
require 'active_support'
require 'active_support/test_case'
require 'active_resource'
require 'active_resource/dirty'
require_relative './fixtures/person'

INITIAL_AGE = 30
UPDATED_AGE = 20
UPDATED_WRITE_ONLY = 'new_value'.freeze

def setup_response
  @frank = { id: 1, name: 'Frank', age: INITIAL_AGE }.to_json
  @updated_frank = { id: 1, name: 'Frank', age: UPDATED_AGE }.to_json

  ActiveResource::HttpMock.respond_to do |mock|
    mock.get('/people/1.json', {}, @frank)
    mock.put('/people/1.json', {}, @updated_frank)
    mock.patch('/people/1.json', {}, @updated_frank)
  end
end
