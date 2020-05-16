defmodule Discuss.Repo.Migrations.AddImage do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :user_image, references(:users)
    end
  end
end
