class AddAnonymousToAnswers < ActiveRecord::Migration[5.0]
  def change
    add_column :answers, :anonymous, :boolen, default:false
  end
end
