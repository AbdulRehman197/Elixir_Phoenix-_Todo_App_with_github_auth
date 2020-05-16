defmodule Discuss.TopicController do
  use Discuss.Web, :controller

  plug(Discuss.Plugs.RequireAuth when action in [:new, :create, :update, :edit, :delete])
  plug(:check_post_owner when action in [:update, :edit, :delete])

  def index(conn, _params) do
    topics = Repo.all(Discuss.Topic)
    render(conn, "index.html", topics: topics)
  end

  def new(conn, _params) do
    # render conn, "index.html"
    # Auomatically genrate changeset args,params
    # changeset = %Discuss.Topic{}
    # params = %{}
    changeset = Discuss.Topic.changeset(%Discuss.Topic{}, %{})

    render(conn, "new.html", changeset: changeset)
  end

  # create(conn,params)
  def create(conn, %{"topic" => topic}) do
    changeset =
      conn.assigns.user
      |> build_assoc(:topics)
      |> Discuss.Topic.changeset(topic)

    case Repo.insert(changeset) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Topic Created")
        |> redirect(to: topic_path(conn, :index))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => topic_id}) do
    topic = Repo.get(Discuss.Topic, topic_id)
    changeset = Discuss.Topic.changeset(topic)

    render(conn, "edit.html", changeset: changeset, topic: topic)
  end

  def update(conn, %{"id" => topic_id, "topic" => topic}) do
    old_topic = Repo.get(Discuss.Topic, topic_id)
    changeset = Discuss.Topic.changeset(old_topic, topic)

    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic Updated")
        |> redirect(to: topic_path(conn, :index))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset, topic: old_topic)
    end
  end

  def delete(conn, %{"id" => topic_id}) do
    Repo.get(Discuss.Topic, topic_id) |> Repo.delete!()

    conn
    |> put_flash(:info, "Topic Deleted")
    |> redirect(to: topic_path(conn, :index))
  end

  def check_post_owner(conn, _params) do
    %{params: %{"id" => topic_id}} = conn

    if Repo.get(Discuss.Topic, topic_id).user_id == conn.assigns.user.id do
      conn
    else
      conn
      |> put_flash(:error, "You Dont Edit Topic")
      |> redirect(to: topic_path(conn, :index))
      |> halt()
    end
  end
end
