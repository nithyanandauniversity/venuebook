Sequel.migration do
  up do
    create_table :users do
      primary_key :id
      String :first_name
      String :last_name
      String :email
      String :encrypted_password
      Integer :role
      Integer :center_id
      Text :permissions
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :users
  end
end
