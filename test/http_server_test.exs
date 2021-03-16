defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer
  alias Servy.HttpClient

  test "accepts a request on a socket and sends back a response (HttpClient)" do
    spawn(HttpServer, :start, [4000])

    request = """
    POST /api/bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    Content-Type: application/json\r
    Content-Length: 21\r
    \r
    {"name": "Breezly", "type": "Polar"}
    """

    response = HttpClient.send_request(request)

    assert response == """
    HTTP/1.1 201 Created\r
    Content-Type: text/html\r
    Content-Length: 35\r
    \r
    Created a Polar bear named Breezly.
    """
  end

  test "accepts a request on a socket and sends back a response (HTTPoison)" do
    spawn(HttpServer, :start, [4000])

    {:ok, response} = HTTPoison.get "http://localhost:4000/wildthings"

    assert response.status_code == 200
    assert response.body == "🎉\n\nBears, Lions, Tigers\n\n🎉"
  end

  test "accepts a request on a socket and sends back a response handling concurrent requests" do
    spawn(HttpServer, :start, [4000])
  
    caller = self()
  
    max_concurrent_requests = 5
  
    # Spawn the client processes
    for _ <- 1..max_concurrent_requests do
      spawn(fn ->
        # Send the request
        {:ok, response} = HTTPoison.get "http://localhost:4000/wildthings"
  
        # Send the response back to the caller
        send(caller, {:ok, response})
      end)
    end
  
    # Await all {:handled, response} messages from spawned processes.
    for _ <- 1..max_concurrent_requests do
      receive do
        {:ok, response} ->
          assert response.status_code == 200
          assert response.body == "🎉\n\nBears, Lions, Tigers\n\n🎉"
      end
    end
  end
end
