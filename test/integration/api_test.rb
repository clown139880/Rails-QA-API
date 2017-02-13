require 'test_helper'

class ApiTest < ActionDispatch::IntegrationTest

    def setup
        @question = questions(:Quest1)
        @tenant = tenants(:one)
        gdbm = GDBM.new("tmp/limits.db")
        set_limits(@tenant.api_key, "0")
        gdbm.close
    end

    test "should get home page and data " do
        get root_path
        assert_template "welcome/home"

    end



    test "questions API test " do
        #需要API_KEY才能访问API，返回401
        get api_v1_questions_path
        assert_response 401
        #传递无效的API_KEY，返回401
        get api_v1_questions_path,{}, {"Authorization":"1111111111",
                                    'HTTP_ACCEPT':"application/json"}
        assert_response 401

        #传递有效的API_KEY，返回200
        get api_v1_questions_path,{}, {"Authorization":@tenant.api_key,
                                    'HTTP_ACCEPT':"application/json"}
        assert_response 200
        #检查是否返回了所有非私有问题
        json = JSON.parse(response.body)
        assert_equal json.count,Question.where(private:"f").count
        #检查@question问题是否在API请求的结果中
        assert_equal json[0]['question']['title'], @question.title
        #检查是否包含所有答案
        assert_equal json[0]['answers'].count,@question.answers.count
        #检查匿名用户的答案是否匿名
        assert_equal json[0]['answers'][0]['user']['name'],@question.answers.first.user.name
        #检查非匿名用户的答案是否匿名
        assert_nil json[0]['answers'][-1]['user']
        #将问题设置为私有，确认结果中不在含有该问题
        @question.update_attributes(private:"t")
        get api_v1_questions_path,{}, {"Authorization":@tenant.api_key,
                                    'HTTP_ACCEPT':"application/json"}
        json = JSON.parse(response.body)
        assert_not_equal json[0]['question']['title'], @question.title
        #检测API使用次数变成了两次
        @tenant.reload
        assert_equal @tenant.limits, 2

    end

    test "questions API with a key word" do
        #在API中传入可选参数key，返回问题标题中有key的结果
        get api_v1_questions_path,{key:'dota2'}, {"Authorization":@tenant.api_key,
                                    'HTTP_ACCEPT':"application/json"}
        assert_response 200
        json = JSON.parse(response.body)
        assert_match "DOTA2",json[0]['question']['title']
    end

    test "API should have rate limits" do
        #设置调用次数达到100次
        set_limits(@tenant.api_key, "100")
        #第101次成功访问调用API
        get api_v1_questions_path,{key:'dota2'}, {"Authorization":@tenant.api_key,
                                    'HTTP_ACCEPT':"application/json"}
        assert_response 200
        assert_equal @tenant.limits, 101
        #下一次访问403，因为10秒内只能访问一次
        get api_v1_questions_path,{key:'dota2'}, {"Authorization":@tenant.api_key,
                                    'HTTP_ACCEPT':"application/json"}
        assert_response 403
        assert_equal @tenant.limits, 101
        #等待十秒后，进行下一次成功访问
        sleep 10
        get api_v1_questions_path,{key:'dota2'}, {"Authorization":@tenant.api_key,
                                    'HTTP_ACCEPT':"application/json"}
        assert_response 200
        assert_equal @tenant.limits, 102
    end

end
