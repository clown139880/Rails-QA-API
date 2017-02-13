json.question do
    json.(@question, :id, :title,:user)
end
json.answers @question.answers do |answer|
    if answer.anonymous == true
        answer.user = nil
    end
    json.(answer, :id, :body, :user)
end
