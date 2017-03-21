Sequel.migration do
  up do
    alter_table :event_attendances do
      add_column :confirmation_status, Integer
      add_column :payment_status, Integer
      add_column :payment_method, Integer
      add_column :amount, String
      add_column :payment_note, String
    end
  end

  down do
    alter_table :event_attendances do
      drop_column :confirmation_status
      drop_column :payment_status
      drop_column :payment_method
      drop_column :amount
      drop_column :payment_note
    end
  end
end
