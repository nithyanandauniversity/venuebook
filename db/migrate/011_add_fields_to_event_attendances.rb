Sequel.migration do
  up do
    alter_table :event_attendances do
      add_column :created_by, Integer
    end
  end

  down do
    alter_table :event_attendances do
      drop_column :created_by
    end
  end
end
