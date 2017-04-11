Sequel.migration do
  up do
    alter_table(:over_under_players) do
      add_column :last_reset, Time
    end
  end

  down do

  end
end