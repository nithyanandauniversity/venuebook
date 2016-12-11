Sequel.migration do
  up do
    create_table :events do
      primary_key :id
      Date :start_date
      Date :end_date
    end
  end

  down do
    drop_table :events
  end
end
