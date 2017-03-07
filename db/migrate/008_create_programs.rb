Sequel.migration do
  up do
    create_table :programs do
      primary_key :id
      String :program_name
      String :program_type
      Integer :center_id
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :programs
  end
end
