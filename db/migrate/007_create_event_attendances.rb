Sequel.migration do
  up do
    create_table :event_attendances do
      primary_key :id
      Integer :event_id
      Integer :venue_id
      Integer :participant_id
      Integer :attendance
      DateTime :attendance_date
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :event_attendances
  end
end
