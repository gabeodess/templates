class Create<%= user_name.camelcase.pluralize %> < ActiveRecord::Migration
  def self.up
    create_table :<%= user_name.underscore.pluralize %> do |t|
      t.string :email
      t.string :password_hash
      t.string :password_salt
      t.string :login

      t.timestamps
    end
  end

  def self.down
    drop_table :<%= user_name.underscore.pluralize %>
  end
end
