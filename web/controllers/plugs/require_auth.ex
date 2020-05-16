defmodule Discuss.Plugs.RequireAuth do
  import Phoenix.Controller
  import Plug.Conn
  alias Discuss.Router.Helpers

  def init(_paramas) do
  end

  def call(conn, _params) do
    if conn.assigns[:user] do
      conn
    else
      conn
      |> put_flash(:error, "you must login!")
      |> redirect(to: Helpers.topic_path(conn, :index))
      |> halt()
    end
  end
end
