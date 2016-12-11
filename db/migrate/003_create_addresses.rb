Sequel.migration do
  up do
    create_table :addresses do
      primary_key :id
      String :address
      String :street
      String :city
      String :state
      String :zip_postal
      String :country
    end
  end

  down do
    drop_table :addresses
  end
end
