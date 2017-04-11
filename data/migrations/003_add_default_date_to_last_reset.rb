Sequel.migration do
  up do
    alter_table(:over_under_players) do
      set_column_default :last_reset, Time.now - 25200
    end
  end

  down do

  end
end