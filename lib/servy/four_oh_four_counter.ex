defmodule Servy.FourOhFourCounter do
  
  alias Servy.GenericServer

  @process_name __MODULE__

  # Client

  def start do
    IO.puts "Starting 404 counter..."
    GenericServer.start(__MODULE__, %{}, @process_name)
  end

  def bump_count(path) do
    GenericServer.call @process_name, {:bump_count, path}
  end

  def get_count(path) do
    GenericServer.call @process_name, {:get_count, path}
  end

  def get_counts do
    GenericServer.call @process_name, :get_counts
  end

  def clear do
    GenericServer.all @process_name, :reset
  end

  # Server

  def handle_call({:bump_count, path}, state) do
    new_state = Map.update(state, path, 1, &(&1 + 1))
    
    {:ok, new_state}
  end

  def handle_call({:get_count, path}, state) do
    count = Map.get(state, path, 0)

    {count, state}
  end

  def handle_call(:get_counts, state) do
    {state, state}
  end

  def handle_cast(:clear, _message) do
    %{}
  end
end
