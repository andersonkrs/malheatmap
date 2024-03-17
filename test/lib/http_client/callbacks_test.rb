require "test_helper"

class HttpClient::CallbacksTest < ActiveSupport::TestCase
  class ApiClient < HttpClient::Base
    self.site = "https://jsonplaceholder.typicode.com"

    before_action do
      params[:tracer].callback("action", "before", action_name)
    end

    after_action do
      params[:tracer].callback("action", "after", action_name)
    end

    before_request do
      params[:tracer].callback("request", "before", action_name)
    end

    after_request do
      params[:tracer].callback("request", "after", action_name)
    end

    def todos
      get("/todos")
    end

    def users
      get("/users")
    end
  end

  test "executes the callbacks in the right order" do
    tracer = mock()
    seq = sequence("callbacks")

    tracer.expects(:callback).in_sequence(seq).with("action", "before", "todos")
    tracer.expects(:callback).in_sequence(seq).with("request", "before", "todos")
    tracer.expects(:callback).in_sequence(seq).with("request", "after", "todos")
    tracer.expects(:callback).in_sequence(seq).with("action", "after", "todos")

    tracer.expects(:callback).in_sequence(seq).with("action", "before", "users")
    tracer.expects(:callback).in_sequence(seq).with("request", "before", "users")
    tracer.expects(:callback).in_sequence(seq).with("request", "after", "users")
    tracer.expects(:callback).in_sequence(seq).with("action", "after", "users")

    VCR.use_cassette("json_placeholder_all_todos") do
      ApiClient.with(tracer: tracer).todos
    end

    VCR.use_cassette("json_placeholder_all_users") do
      ApiClient.with(tracer: tracer).users
    end
  end
end
