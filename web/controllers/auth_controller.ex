defmodule Discuss.AuthController do
  use Discuss.Web, :controller
  plug(Ueberauth)

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
# user = auth.extra.raw_info.user
# %{"avatar_url" => profile_image } = user

    user_params = %{token: auth.credentials.token, email: auth.info.email, provider: "github"}
    changeset = Discuss.User.changeset(%Discuss.User{}, user_params)

    sign_in(conn, changeset)
  end
def signout(conn,_params) do
  conn
  |> configure_session(drop: true)
  |> redirect(to: topic_path(conn, :index))
end
  defp sign_in(conn, changeset) do
    case insert_and_udpate_user(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome Back!")
        |> put_session(:user_id, user.id)
        |> redirect(to: topic_path(conn, :index))

      {:error, _reson} ->
        conn
        |> put_flash(:info, "Error in Singing in!")
        |> redirect(to: topic_path(conn, :index))
    end
  end

  defp insert_and_udpate_user(changseset) do
    case Repo.get_by(Discuss.User, email: changseset.changes.email) do
      nil ->
        Repo.insert(changseset)


      user ->
        {:ok, user}
    end
  end
end
