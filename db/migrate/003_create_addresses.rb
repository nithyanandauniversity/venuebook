Sequel.migration do
  up do
    create_table :addresses do
      primary_key :id
      String :street
      String :city
      String :state
      String :zip_postal
      String :country
      Integer :venue_id
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :addresses
  end
end
