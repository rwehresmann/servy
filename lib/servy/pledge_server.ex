defmodule Servy.PledgeServer do

  @process_name __MODULE__

  # Client interface

  def start(initial_state \\ []) do
    IO.puts "Starting the pledge server..."
    pid = spawn(__MODULE__, :listen_loop, [initial_state])
    Process.register(pid, @process_name)
    
    pid
  end

  def create_pledge(name, amount) do
    send(@process_name, {self(), :create_pledge, name, amount})

    receive do {:response, status} -> status end
  end

  def recent_pledges do
    send(@process_name, {self(), :recent_pledges})

    receive do {:response, pledges} -> pledges end
  end

  def total_pledged do
    send(@process_name, {self(), :total_pledge})

    receive do {:response, total} -> total end
  end

  # Server

  def listen_loop(state) do
    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)
        most_recent_pledges = Enum.take(state, 2)
        new_state = [{name, amount} | most_recent_pledges]
        send(sender, {:response, id})
        listen_loop(new_state)
      {sender, :recent_pledges} ->
        send(sender, {:response, state})
        listen_loop(state)
      {sender, :total_pledge} ->
        total = Enum.map(state, &elem(&1, 1)) |> Enum.sum
        send(sender, {:response, total})
        listen_loop(state)
      unexpected ->
        IO.puts "Unexpected message: #{inspect unexpected}"
        listen_loop(state)
    end
  end

  defp send_pledge_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

#pid = Servy.PledgeServer.start()

#send pid, {:stop, "jdaskdh"}

#IO.inspect Servy.PledgeServer.create_pledge("larry", 10)
#IO.inspect Servy.PledgeServer.create_pledge("moe", 20)
#IO.inspect Servy.PledgeServer.create_pledge("homer", 30)
#IO.inspect Servy.PledgeServer.create_pledge("lisa", 40)
#IO.inspect Servy.PledgeServer.create_pledge("harry o potter", 50)

#IO.inspect Servy.PledgeServer.recent_pledges()

#IO.inspect Servy.PledgeServer.total_pledged()
