class Api::V1::QuestionsController < ApplicationController
    before_action :authenticate!


    def show
        @question = Question.find(params[:id])
        if @question.private == true
            api_error(message:"没有访问该问题的权限",status: 403)
        end

    end

    def index
        @questions = Question.where("private=? AND title LIKE ?","f","%#{params[:key]}%")
        if @questions.count == 0
            api_error(message:"查询结果为0" ,status: 404)
        end

    end


    private

        def api_error(opts = {})
            render status: opts[:status],json: {errors: opts[:message]}
        end

        def authenticate!
            api_key = if request.headers['Authorization'].present?
                      request.headers['Authorization'].split(' ').last
                    end

            tenant = Tenant.find_by(api_key:api_key)

            if tenant.nil?
                unauthenticated!
            else

                gdbm = GDBM.new("tmp/limits.db")
                gdbm[tenant.name] = Time.now.to_s if gdbm[tenant.name].nil?
                if Time.now.at_beginning_of_day > gdbm[tenant.name].to_time
                    limits = 1
                    gdbm[tenant.name] = Time.now.to_s
                else
                    limits = gdbm[api_key].to_i + 1
                end
                gdbm[api_key] = limits.to_s
                gdbm.close

            end

        end

        def unauthenticated!
            api_error(message:"无效的API_KEY",status:401)
        end

end
