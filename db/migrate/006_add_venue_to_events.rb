Sequel.migration do
  up do
    alter_table :events do
      add_column :venue_id, Integer
    end
  end

  down do
    alter_table :events do
      drop_column :venue_id
    end
  end
end
