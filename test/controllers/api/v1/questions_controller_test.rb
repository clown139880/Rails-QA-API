require 'test_helper'

class Api::V1::QuestionsControllerTest < ActionDispatch::IntegrationTest

    def setup
        @question = questions(:Quest1)
    end

    test "should return 401 when request without API_KEY " do
        get '/api/v1/questions'
        assert_response 401
        get '/api/v1/questions/1'
        assert_response 401
    end


end
