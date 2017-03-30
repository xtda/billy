Sequel.migration do
  up do
    create_table(:over_under_players) do
      primary_key :id
      Integer :discord_id
      Integer :balance, default: 100_000
    end
  end

  down do
    drop_table(:over_under_players)
  end
end