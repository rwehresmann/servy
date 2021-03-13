defmodule Servy.Handler do
  @moduledoc "Handles HTTP requests."

  require Logger

  alias Servy.Conv
  alias Servy.BearController

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
    |> format_response
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

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: text/html\r
    Content-Length: #{byte_size(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end
end
