Sequel.migration do
  up do
    create_table :event_attendances do
      primary_key :id
      Integer :event_id
      Integer, :participant_id
      Integer :attendance
    end
  end

  down do
    drop_table :event_attendances
  end
end
