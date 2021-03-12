defmodule Servy.Handler do
  @moduledoc "Handles HTTP requests."

  require Logger

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
  
  def route(%{ method: "GET", path: "/wildthings" } = conv) do
    %{ conv | status: 200, resp_body: "Bears, Lions, Tigers" }
  end

  def route(%{ method: "GET", path: "/bears" } = conv) do
    %{ conv | status: 200, resp_body: "Teddy, Smokey, Zé Colmeia" }
  end

  def route(%{ method: "GET", path: "/bears/new" } = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%{ method: "GET", path: "/bears/" <> id } = conv) do
    %{ conv | status: 200, resp_body: "Bear #{id}" }
  end

  def route(%{ method: "DELETE", path: "/bears" <> _id } = conv) do
    msg = "Deleting a bear is forbidden."
    Logger.warn(msg)
    %{ conv | status: 403, resp_body: "Deleting a bear is forbidden." }
  end

  def route(%{ method: "GET", path: "/pages/" <> page } = conv) do
    @pages_path
    |> Path.join("#{page}.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%{ path: path } = conv) do
    msg = "#{path} not found."
    Logger.warn(msg)
    %{ conv | status: 404, resp_body: msg }
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}
  
    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end

request = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts Servy.Handler.handle(request)

