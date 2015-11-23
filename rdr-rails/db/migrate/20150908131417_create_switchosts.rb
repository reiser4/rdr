class CreateSwitchosts < ActiveRecord::Migration
  def change
    create_table :switchosts do |t|
      t.string :switch
      t.string :mac
      t.string :port
      t.bigint :timeout

      t.timestamps null: false
    end
  end
end
