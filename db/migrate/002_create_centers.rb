Sequel.migration do
  up do
    create_table :centers do
      primary_key :id
      String :name
      String :code
      String :category
      String :city
      String :state
      String :region
      String :country
      String :area
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :centers
  end
end
