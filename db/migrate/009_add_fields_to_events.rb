Sequel.migration do
  up do
    alter_table :events do
      add_column :program_id, Integer
    end
  end

  down do
    alter_table :events do
      drop_column :program_id
    end
  end
end
