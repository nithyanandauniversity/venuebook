Sequel.migration do
  up do
    create_table :event_attendances do
      primary_key :id
      Integer :event_id
      Integer :venue_id
      String :member_id
      Integer :attendance
      Date :attendance_date
      DateTime :created_at
      DateTime :updated_at
      Integer :confirmation_status
      Integer :payment_status
      Integer :payment_method
      String :amount
      String :payment_note
    end
  end

  down do
    drop_table :event_attendances
  end
end
