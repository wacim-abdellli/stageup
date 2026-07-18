require "test_helper"

class RackAttackTest < ActionDispatch::IntegrationTest
  setup do
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rack::Attack.cache.store.clear
  end

  test "throttles login attempts by IP" do
    11.times do
      post user_session_path, params: { user: { email: "x@x.com", password: "wrong" } },
                               headers: { "REMOTE_ADDR" => "1.2.3.4" }
    end
    assert_response 429
  end

  test "throttles password reset by IP" do
    6.times do
      post user_password_path, params: { user: { email: "x@x.com" } },
                               headers: { "REMOTE_ADDR" => "1.2.3.4" }
    end
    assert_response 429
  end

  test "throttles registration by IP" do
    6.times do
      post student_registration_path, params: { user: { email: "test@test.com", password: "test123" } },
                                      headers: { "REMOTE_ADDR" => "1.2.3.4" }
    end
    assert_response 429
  end
end
