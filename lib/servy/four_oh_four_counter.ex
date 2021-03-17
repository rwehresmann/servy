defmodule Servy.FourOhFourCounter do
  
  use GenServer

  @process_name __MODULE__

  # Client

  def start do
    IO.puts "Starting 404 counter..."
    GenServer.start(__MODULE__, %{}, name: @process_name)
  end

  def bump_count(path) do
    GenServer.call @process_name, {:bump_count, path}
  end

  def get_count(path) do
    GenServer.call @process_name, {:get_count, path}
  end

  def get_counts do
    GenServer.call @process_name, :get_counts
  end

  def clear do
    GenServer.all @process_name, :reset
  end

  # Server

  def handle_call({:bump_count, path}, _from, state) do
    new_state = Map.update(state, path, 1, &(&1 + 1))
    
    {:reply, :ok, new_state}
  end

  def handle_call({:get_count, path}, _from, state) do
    count = Map.get(state, path, 0)

    {:reply, count, state}
  end

  def handle_call(:get_counts, _from, state) do
    {:reply, state, state}
  end

  def handle_cast(:clear, _from, _message) do
    {:noreply, %{}}
  end
end
