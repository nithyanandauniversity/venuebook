Sequel.migration do
  up do
    alter_table :addresses do
      add_column :center_id, Integer
    end
  end

  down do
    alter_table :addresses do
      drop_column :center_id
    end
  end
end
