Sequel.migration do
  up do
    create_table :events do
      primary_key :id
      Date :start_date
      Date :end_date
      Integer :center_id
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :events
  end
end
