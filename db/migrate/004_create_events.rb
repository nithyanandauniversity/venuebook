Sequel.migration do
  up do
    create_table :events do
      primary_key :id
      String :name
      Date :start_date
      Date :end_date
      Integer :center_id
      String :program_donation
      Text :notes
      String :uuid
      String :registration_code
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :events
  end
end
