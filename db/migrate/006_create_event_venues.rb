Sequel.migration do
  up do
    create_table :event_venues do
      primary_key :id
      Integer :event_id
      Integer :venue_id
      Integer :user_id
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :event_venues
  end
end
