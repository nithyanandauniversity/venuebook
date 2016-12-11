Sequel.migration do
  up do
    create_table :venues do
      primary_key :id
      String :name
      String :center
      String :country
      Integer :capacity
    end
  end

  down do
    drop_table :venues
  end
end
