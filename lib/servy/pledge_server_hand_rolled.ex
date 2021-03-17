defmodule Servy.PledgeServerHandRolled do

  alias Servy.GenericServer

  @process_name __MODULE__

  # Client interface

  def start(initial_state \\ []) do
    IO.puts "Starting the pledge server..."
    GenericServer.start(__MODULE__, initial_state, @process_name)
  end

  def create_pledge(name, amount) do
    GenericServer.call(@process_name, {:create_pledge, name, amount})
  end

  def recent_pledges do
    GenericServer.call(@process_name, :recent_pledges)
  end

  def total_pledged do
    GenericServer.call(@process_name, :total_pledged)
  end

  def clear do
    GenericServer.cast(@process_name, :clear)
  end

  # Server

  def handle_cast(:clear, _state) do
    []
  end

  def handle_info(message, state) do
    IO.puts "Unexpected message: #{inspect message}"
    state
  end

  def handle_call(:total_pledged, state) do
    total = Enum.map(state, &elem(&1, 1)) |> Enum.sum
    
    {total, state}
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state, 2)
    new_state = [{name, amount} | most_recent_pledges]

    {id, new_state}
  end

  defp send_pledge_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

#pid = Servy.PledgeServerHandRolled.start()

#send pid, {:stop, "uga buga"}

#IO.inspect Servy.PledgeServerHandRolled.create_pledge("larry", 10)
#IO.inspect Servy.PledgeServerHandRolled.create_pledge("moe", 20)
#IO.inspect Servy.PledgeServerHandRolled.create_pledge("homer", 30)
#IO.inspect Servy.PledgeServerHandRolled.create_pledge("lisa", 40)
#IO.inspect Servy.PledgeServerHandRolled.create_pledge("harry o potter", 50)

#Servy.PledgeServerHandRolled.clear()

#IO.inspect Servy.PledgeServerHandRolled.recent_pledges()

#IO.inspect Servy.PledgeServerHandRolled.total_pledged()
