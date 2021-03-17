defmodule Servy.Handler do
  @moduledoc "Handles HTTP requests."

  require Logger

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.VideoCam

  # @pages_path Path.expand("../../pages", __DIR__)
  @pages_path Path.expand("pages", File.cwd!)

  import Servy.Plugins
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  @doc "Transforms requests in responses."
  def handle(request) do  
    request 
    |> parse
    |> rewrite_path 
    |> log
    |> route 
    |> track
    |> emojify
    |> put_content_length
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/404s"} = conv) do
    counts = Servy.FourOhFourCounter.get_counts()
  
    %{ conv | status: 200, resp_body: inspect counts }
  end

  def route(%Conv{ method: "GET", path: "/api/bears" } = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servy.Api.BearController.create(conv, conv.params)
  end

  def route(%Conv{ method: "GET", path: "/kaboom" } = conv) do
    raise "Kaboom!"
  end

  def route(%Conv{ method: "GET", path: "/sensors" } = conv) do
    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots = 
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> Servy.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await(&1))

    where_is_bigfoot = Task.await(task)

    %{ conv | status: 200, resp_body: inspect {snapshots, where_is_bigfoot}}
  end

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    Servy.PledgeController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    Servy.PledgeController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/hibernate/" <> time } = conv) do
    time |> String.to_integer |> :timer.sleep
  
    %{ conv | status: 200, resp_body: "Awake!" }
  end
  
  def route(%Conv{ method: "GET", path: "/wildthings" } = conv) do
    %{ conv | status: 200, resp_body: "Bears, Lions, Tigers" }
  end

  def route(%Conv{ method: "GET", path: "/bears" } = conv) do
    BearController.index(conv)
  end

  def route(%Conv{ method: "POST", path: "/bears" } = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{ method: "GET", path: "/bears/new" } = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{ method: "GET", path: "/bears/" <> id } = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{ method: "DELETE", path: "/bears" <> id } = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.destroy(conv, params)
  end

  def route(%Conv{ method: "GET", path: "/pages/" <> page } = conv) do
    @pages_path
    |> Path.join("#{page}.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{ path: path } = conv) do
    msg = "#{path} not found."
    Logger.warn(msg)
    %{ conv | status: 404, resp_body: msg }
  end

  def format_response(%Conv{resp_headers: resp_headers} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{resp_headers["Content-Type"]}\r
    Content-Length: #{resp_headers["Content-Length"]}\r
    \r
    #{conv.resp_body}
    """
  end

  defp put_content_length(conv) do
    headers = Map.put(conv.resp_headers, "Content-Length", byte_size(conv.resp_body))
    %{ conv | resp_headers: headers }
  end
end
