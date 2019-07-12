require 'test_helper'

class ActiveResource::Dirty::Test < Minitest::Test
  def setup
    setup_response
    @person = Person.find(1)
  end

  def test_changes
    @person.age = UPDATED_AGE
    assert_equal({ 'age' => [INITIAL_AGE, UPDATED_AGE] },
                 @person.changes)
  end

  def test_changes_back_to_original_value
    @person.age = UPDATED_AGE
    @person.age = INITIAL_AGE
    assert_equal({},
                 @person.changes)
  end

  def test_reload_clear_changes
    @person.age = UPDATED_AGE
    @person.reload
    assert_equal({},
                 @person.changes)
  end

  def test_save_changes_applied
    @person.age = UPDATED_AGE
    @person.save
    assert_equal({},
                 @person.changes)
    assert_equal({ 'age' => [INITIAL_AGE, UPDATED_AGE] },
                 @person.previous_changes)
  end

  def test_reload_clear_previous_changes
    @person.age = UPDATED_AGE
    @person.save
    @person.reload
    assert_equal({},
                 @person.previous_changes)
  end

  def test_use_patch_request
    Person.with_custom_patch_flag(true) do
      @person.age = UPDATED_AGE
      @person.save
    end

    last_request = ActiveResource::HttpMock.requests.last
    assert_equal(:patch,
                 last_request.method)
  end

  def test_patch_request_send_only_changes
    Person.with_custom_patch_flag(true) do
      @person.age = UPDATED_AGE
      @person.save
    end

    last_request = ActiveResource::HttpMock.requests.last
    assert_equal({ 'age' => UPDATED_AGE },
                 JSON.parse(last_request.body))
  end

  def test_patch_request_not_send_if_no_changes
    Person.with_custom_patch_flag(true) do
      @person.save
    end

    assert_equal(1,
                ActiveResource::HttpMock.requests.size)
  end

  def test_use_put_request
    Person.with_custom_patch_flag(false) do
      @person.age = UPDATED_AGE
      @person.save
    end

    last_request = ActiveResource::HttpMock.requests.last
    assert_equal(:put,
                 last_request.method)
  end

  def test_put_request_send_all_attributes
    Person.with_custom_patch_flag(false) do
      @person.age = UPDATED_AGE
      @person.save
    end

    last_request = ActiveResource::HttpMock.requests.last
    assert_equal({ 'id' => 1, 'name' => 'Frank', 'age' => UPDATED_AGE },
                 JSON.parse(last_request.body))
  end
end
