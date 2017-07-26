Sequel.migration do
  up do
    alter_table :events do
      add_column :created_by, Integer
    end
  end

  down do
    alter_table :events do
      drop_column :created_by
    end
  end
end
