Sequel.migration do
  up do
    create_table :participants do
      primary_key :id
      String :first_name
      String :last_name
      String :gender
      Date :dob
      String :email
      String :member_id
      String :other_names
      Integer :parent_id
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :participants
  end
end
