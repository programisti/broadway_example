defmodule ExampleWeb.PageController do
  use ExampleWeb, :controller
  alias AMQP.{Connection, Channel, Basic, Queue}

  def index(conn, _params) do
    {:ok, connection} = Connection.open
    {:ok, channel} = Channel.open(connection)
    Queue.declare(channel, "my_queue", durable: true)

    # Enum.each(1..5000, fn i ->
    #   Basic.publish(channel, "", "my_queue", "#{i}")
    # end)
    Basic.publish(channel, "", "my_queue", Jason.encode!(%{a: 1}))
    Connection.close(connection)
    # Producer.dispatch()
    render(conn, "index.html")
  end
end
